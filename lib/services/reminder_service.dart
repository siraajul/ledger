import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/expense.dart';
import 'reminder_messages.dart';

/// Per-device reminder preferences. Kept in SharedPreferences, not Firestore:
/// each device schedules its own notifications (like the PIN).
class ReminderSettings {
  final bool enabled;

  /// Daily check-in times, e.g. arriving at the office, after lunch, home.
  final List<TimeOfDay> times;

  const ReminderSettings({this.enabled = false, this.times = defaultTimes});

  static const defaultTimes = [
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 14, minute: 0),
    TimeOfDay(hour: 19, minute: 0),
  ];

  ReminderSettings copyWith({bool? enabled, List<TimeOfDay>? times}) =>
      ReminderSettings(
        enabled: enabled ?? this.enabled,
        times: times ?? this.times,
      );
}

/// Check-ins to notify for, over the next [days] days.
///
/// A check-in is skipped if something was logged in the second half of the
/// gap since the previous check-in — i.e. you already logged "for" it. A log
/// right after the previous check-in counts as answering that one instead, so
/// logging at 19:30 doesn't silence tomorrow's 10:00, and logging at 11:00
/// doesn't silence the 14:00 lunch check-in.
///
/// Only [lastExpense] up to now is known, so this mostly decides the very next
/// check-in; later ones are rescheduled whenever the expenses change.
List<DateTime> reminderTimes({
  required DateTime? lastExpense,
  required DateTime now,
  required List<TimeOfDay> times,
  int days = 3,
}) {
  if (times.isEmpty) return const [];
  final daily = [...times]
    ..sort((a, b) => (a.hour * 60 + a.minute) - (b.hour * 60 + b.minute));
  // DateTime(y, m, d + n) normalizes month ends and keeps wall-clock time
  // across DST changes, unlike adding a Duration.
  final slots = [
    for (var d = -1; d <= days; d++)
      for (final t in daily)
        DateTime(now.year, now.month, now.day + d, t.hour, t.minute),
  ];
  final horizon = DateTime(now.year, now.month, now.day + days, 23, 59);
  return [
    for (var i = 1; i < slots.length; i++)
      if (slots[i].isAfter(now) &&
          !slots[i].isAfter(horizon) &&
          (lastExpense == null ||
              !lastExpense.isAfter(_midpoint(slots[i - 1], slots[i]))))
        slots[i],
  ];
}

DateTime _midpoint(DateTime a, DateTime b) =>
    a.add(Duration(microseconds: b.difference(a).inMicroseconds ~/ 2));

class ReminderService {
  static final ReminderService instance = ReminderService._();

  ReminderService._();

  static const _kEnabled = 'reminder_enabled';
  static const _kTimes = 'reminder_times'; // minutes after midnight
  static const _firstId = 100;
  static const _previewFirstId = 900;

  /// Upper bound of scheduled check-ins: 5 times a day over [_days] + 1 days.
  /// Well under iOS's 64 pending notifications.
  static const _days = 3;
  static const _maxScheduled = 5 * (_days + 1);

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  List<Expense> _expenses = const [];
  double _budget = 0;
  bool _hasExpenseData = false;

  /// Call once at startup. Does not prompt for permission.
  Future<void> init() async {
    if (kIsWeb) return;
    tzdata.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (_) {
      // Unknown zone name: fall back to UTC; reminders may be off by the offset.
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestSoundPermission: false,
          requestBadgePermission: false,
        ),
      ),
    );
    _ready = true;
  }

  Future<ReminderSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_kTimes);
    return ReminderSettings(
      enabled: prefs.getBool(_kEnabled) ?? false,
      times: stored == null
          ? ReminderSettings.defaultTimes
          : [
              for (final m in stored.map(int.parse))
                TimeOfDay(hour: m ~/ 60, minute: m % 60),
            ],
    );
  }

  /// Saves [settings] and reschedules. Returns false if the user refused the
  /// notification permission (the reminder is then saved as disabled).
  Future<bool> save(ReminderSettings settings) async {
    var granted = true;
    if (settings.enabled) granted = await _requestPermission();
    final effective = granted ? settings : settings.copyWith(enabled: false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, effective.enabled);
    await prefs.setStringList(_kTimes, [
      for (final t in effective.times) '${t.hour * 60 + t.minute}',
    ]);
    await _reschedule();
    return granted;
  }

  /// Feed the expense list whenever it changes; the messages quote today's
  /// total and what's left of the budget.
  Future<void> onExpensesChanged(List<Expense> expenses) async {
    _hasExpenseData = true;
    _expenses = expenses;
    await _reschedule();
  }

  Future<void> onBudgetChanged(double budget) async {
    if (budget == _budget) return;
    _budget = budget;
    await _reschedule();
  }

  /// On sign-out: reminders belong to the account that set them up.
  Future<void> cancelAll() async {
    _hasExpenseData = false;
    _expenses = const [];
    _budget = 0;
    if (_ready) await _plugin.cancelAll();
  }

  /// Fires one notification per message scenario, a few seconds apart, so the
  /// wording can be checked on a real device. Uses made-up figures and doesn't
  /// touch the real schedule.
  Future<bool> sendPreview() async {
    if (!_ready) return false;
    if (!await _requestPermission()) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final samples = <(CheckIn, ReminderFacts)>[
      (CheckIn.first, const ReminderFacts()), // never logged
      (
        CheckIn.first,
        ReminderFacts(lastExpense: today.subtract(const Duration(days: 4))),
      ), // long silence
      (CheckIn.first, ReminderFacts(lastExpense: today)), // morning
      (CheckIn.middle, ReminderFacts(lastExpense: today)), // midday
      (
        CheckIn.middle,
        ReminderFacts(lastExpense: today, monthTotal: 4500, budget: 5000),
      ), // budget low
      (
        CheckIn.middle,
        ReminderFacts(lastExpense: today, monthTotal: 5600, budget: 5000),
      ), // over budget
      (
        CheckIn.last,
        ReminderFacts(
          lastExpense: today,
          todayCount: 3,
          todayTotal: 845,
          monthTotal: 2100,
          budget: 5000,
        ),
      ), // evening summary
      (CheckIn.last, ReminderFacts(lastExpense: today)), // evening, nothing
    ];
    for (var i = 0; i < samples.length; i++) {
      final (position, facts) = samples[i];
      final message = reminderMessage(
        slot: now,
        now: now,
        position: position,
        facts: facts,
      );
      await _plugin.zonedSchedule(
        id: _previewFirstId + i,
        title: message.title,
        body: message.body,
        scheduledDate: tz.TZDateTime.now(tz.local)
            .add(Duration(seconds: 8 * (i + 1))),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'expense_reminders',
            'Expense reminders',
            channelDescription:
                'Check-in reminders when nothing has been logged',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
    return true;
  }

  Future<bool> _requestPermission() async {
    if (!_ready) return false;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final result =
        await android?.requestNotificationsPermission() ??
        await ios?.requestPermissions(alert: true, sound: true, badge: true);
    return result ?? true;
  }

  Future<void> _reschedule() async {
    // Wait for the expense list: scheduling from "no expenses" before the
    // first snapshot arrives would fire a reminder for a user who has some.
    if (!_ready || !_hasExpenseData) return;
    for (var i = 0; i < _maxScheduled; i++) {
      await _plugin.cancel(id: _firstId + i);
    }
    final settings = await load();
    if (!settings.enabled) return;

    final now = DateTime.now();
    final facts = ReminderFacts.from(
      expenses: _expenses,
      budget: _budget,
      now: now,
    );
    final daily = [...settings.times]
      ..sort((a, b) => (a.hour * 60 + a.minute) - (b.hour * 60 + b.minute));
    final times = reminderTimes(
      lastExpense: facts.lastExpense,
      now: now,
      times: daily,
      days: _days,
    ).take(_maxScheduled).toList();

    for (var i = 0; i < times.length; i++) {
      final slot = times[i];
      final first = daily.first;
      final last = daily.last;
      final position = slot.hour == last.hour && slot.minute == last.minute
          ? CheckIn.last
          : slot.hour == first.hour && slot.minute == first.minute
          ? CheckIn.first
          : CheckIn.middle;
      final message = reminderMessage(
        slot: slot,
        now: now,
        position: position,
        facts: facts,
      );
      await _plugin.zonedSchedule(
        id: _firstId + i,
        title: message.title,
        body: message.body,
        scheduledDate: tz.TZDateTime.from(slot, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'expense_reminders',
            'Expense reminders',
            channelDescription:
                'Check-in reminders when nothing has been logged',
            // High: a heads-up banner rather than a silent entry in the shade.
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        // Inexact: a reminder doesn't need the exact-alarm permission.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
