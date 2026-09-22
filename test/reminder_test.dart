import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/services/reminder_service.dart';

void main() {
  const office = TimeOfDay(hour: 10, minute: 0);
  const lunch = TimeOfDay(hour: 14, minute: 0);
  const home = TimeOfDay(hour: 19, minute: 0);
  const checkIns = [home, office, lunch]; // order shouldn't matter

  List<DateTime> next(DateTime now, DateTime? last, {int days = 1}) =>
      reminderTimes(lastExpense: last, now: now, times: checkIns, days: days);

  final day = DateTime(2026, 9, 22);
  DateTime at(int h, [int m = 0, int plusDays = 0]) =>
      DateTime(day.year, day.month, day.day + plusDays, h, m);

  test('lunch log just before 14:00 skips the lunch check-in', () {
    final times = next(at(13, 45), at(13, 30));
    expect(times.first, at(19));
  });

  test('11:00 log answers the office check-in, lunch still fires', () {
    final times = next(at(11, 5), at(11));
    expect(times.first, at(14));
  });

  test('logging at home last night does not silence the office check-in', () {
    final times = next(at(8), at(19, 30, -1));
    expect(times.first, at(10));
  });

  test('logging on arrival at the office skips 10:00', () {
    final times = next(at(9, 45), at(9, 40));
    expect(times.first, at(14));
  });

  test('later check-ins are scheduled until the app reschedules them', () {
    expect(next(at(8), null, days: 1), [
      at(10),
      at(14),
      at(19),
      at(10, 0, 1),
      at(14, 0, 1),
      at(19, 0, 1),
    ]);
  });

  test('only future check-ins, none past the horizon', () {
    final times = next(at(19, 1), at(19), days: 0);
    expect(times, isEmpty); // the day's last check-in has passed
  });

  test('no times configured: nothing scheduled', () {
    expect(
      reminderTimes(lastExpense: null, now: at(8), times: const []),
      isEmpty,
    );
  });
}
