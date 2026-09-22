import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/models/expense.dart';
import 'package:ledger/services/reminder_service.dart';

void main() {
  const eight = TimeOfDay(hour: 20, minute: 0);

  test(
    'first reminder is N days after the newest expense, at the set time',
    () {
      final times = reminderTimes(
        lastExpense: DateTime(2026, 9, 22, 9, 30),
        now: DateTime(2026, 9, 22, 10),
        time: eight,
        everyDays: 2,
        count: 3,
      );
      expect(times, [
        DateTime(2026, 9, 24, 20),
        DateTime(2026, 9, 26, 20),
        DateTime(2026, 9, 28, 20),
      ]);
    },
  );

  test('daily: logging today moves the reminder to tomorrow', () {
    final times = reminderTimes(
      lastExpense: DateTime(2026, 9, 22),
      now: DateTime(2026, 9, 22, 21),
      time: eight,
      everyDays: 1,
      count: 1,
    );
    expect(times.single, DateTime(2026, 9, 23, 20));
  });

  test('overdue: next occurrence of the time, not a past moment', () {
    final before = reminderTimes(
      lastExpense: DateTime(2026, 9, 1),
      now: DateTime(2026, 9, 22, 19),
      time: eight,
      everyDays: 3,
      count: 1,
    );
    expect(before.single, DateTime(2026, 9, 22, 20)); // still today
    final after = reminderTimes(
      lastExpense: DateTime(2026, 9, 1),
      now: DateTime(2026, 9, 22, 20, 1),
      time: eight,
      everyDays: 3,
      count: 1,
    );
    expect(after.single, DateTime(2026, 9, 23, 20));
  });

  test('no expenses yet: remind today if the time is still ahead', () {
    final times = reminderTimes(
      lastExpense: null,
      now: DateTime(2026, 9, 22, 8),
      time: eight,
      everyDays: 7,
      count: 1,
    );
    expect(times.single, DateTime(2026, 9, 22, 20));
  });

  test('month end rolls over', () {
    final times = reminderTimes(
      lastExpense: DateTime(2026, 1, 30),
      now: DateTime(2026, 1, 30, 12),
      time: eight,
      everyDays: 3,
      count: 1,
    );
    expect(times.single, DateTime(2026, 2, 2, 20));
  });

  test('newest expense date', () {
    Expense e(DateTime d) =>
        Expense(id: '$d', title: 't', amount: 1, category: 'Food', date: d);
    expect(newestExpenseDate([]), isNull);
    expect(
      newestExpenseDate([
        e(DateTime(2026, 9, 1)),
        e(DateTime(2026, 9, 5)),
        e(DateTime(2026, 9, 3)),
      ]),
      DateTime(2026, 9, 5),
    );
  });
}
