import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/expense.dart';

/// Per-device reminder preferences. Kept in SharedPreferences, not Firestore:
/// each device schedules its own notifications (like the PIN).
class ReminderSettings {
  final bool enabled;
  final TimeOfDay time;

  /// Remind once this many days pass without an expense.
  final int everyDays;

  const ReminderSettings({
    this.enabled = false,
    this.time = const TimeOfDay(hour: 20, minute: 0),
    this.everyDays = 1,
  });

  ReminderSettings copyWith({bool? enabled, TimeOfDay? time, int? everyDays}) =>
      ReminderSettings(
        enabled: enabled ?? this.enabled,
        time: time ?? this.time,
        everyDays: everyDays ?? this.everyDays,
      );
}

DateTime? newestExpenseDate(Iterable<Expense> expenses) => expenses.isEmpty
    ? null
    : expenses.map((e) => e.date).reduce((a, b) => a.isAfter(b) ? a : b);

/// When to remind, given the newest expense date.
///
/// The first reminder is [everyDays] after the day of [lastExpense] at [time]
/// (or today at [time] with no expenses). If that moment has already passed,
/// it moves to the next [time] from [now]. Further reminders follow every
/// [everyDays] in case the app isn't opened in between.
List<DateTime> reminderTimes({
  required DateTime? lastExpense,
  required DateTime now,
  required TimeOfDay time,
  required int everyDays,
  int count = 4,
}) {
  // DateTime(y, m, d + n) normalizes month ends and keeps wall-clock time
  // across DST changes, unlike adding a Duration.
  DateTime at(DateTime day, int plusDays) =>
      DateTime(day.year, day.month, day.day + plusDays, time.hour, time.minute);

  var next = lastExpense == null ? at(now, 0) : at(lastExpense, everyDays);
  while (!next.isAfter(now)) {
    next = at(next, 1);
  }
  return [for (var i = 0; i < count; i++) at(next, i * everyDays)];
}

class ReminderService {
  static final ReminderService instance = ReminderService._();

  ReminderService._();

  static const _kEnabled = 'reminder_enabled';
  static const _kMinutes = 'reminder_minutes'; // minutes after midnight
  static const _kEveryDays = 'reminder_every_days';
  static const _firstId = 100;
  static const _count = 4;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  DateTime? _lastExpense;
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
    final minutes = prefs.getInt(_kMinutes) ?? 20 * 60;
    return ReminderSettings(
      enabled: prefs.getBool(_kEnabled) ?? false,
      time: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
      everyDays: prefs.getInt(_kEveryDays) ?? 1,
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
    await prefs.setInt(
      _kMinutes,
      effective.time.hour * 60 + effective.time.minute,
    );
    await prefs.setInt(_kEveryDays, effective.everyDays);
    await _reschedule();
    return granted;
  }

  /// Feed the newest expense date whenever the expense list changes.
  Future<void> onExpensesChanged(DateTime? newest) async {
    if (_hasExpenseData && newest == _lastExpense) return;
    _hasExpenseData = true;
    _lastExpense = newest;
    await _reschedule();
  }

  /// On sign-out: reminders belong to the account that set them up.
  Future<void> cancelAll() async {
    _hasExpenseData = false;
    _lastExpense = null;
    if (_ready) await _plugin.cancelAll();
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
    for (var i = 0; i < _count; i++) {
      await _plugin.cancel(id: _firstId + i);
    }
    final settings = await load();
    if (!settings.enabled) return;

    final times = reminderTimes(
      lastExpense: _lastExpense,
      now: DateTime.now(),
      time: settings.time,
      everyDays: settings.everyDays,
      count: _count,
    );
    final body = settings.everyDays == 1
        ? 'Nothing logged today. Anything to add?'
        : 'No expenses in ${settings.everyDays} days. Anything to add?';
    for (var i = 0; i < times.length; i++) {
      await _plugin.zonedSchedule(
        id: _firstId + i,
        title: 'LEDGER',
        body: body,
        scheduledDate: tz.TZDateTime.from(times[i], tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'expense_reminders',
            'Expense reminders',
            channelDescription: 'Reminds you when no expense has been logged',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        // Inexact: a reminder doesn't need the exact-alarm permission.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
