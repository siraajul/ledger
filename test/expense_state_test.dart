import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/bloc/expense/expense_state.dart';
import 'package:ledger/models/expense.dart';

Expense _at(DateTime date, double amount) => Expense(
      id: date.toIso8601String(),
      title: 't',
      amount: amount,
      category: 'Food',
      date: date,
    );

void main() {
  final now = DateTime.now();
  final state = ExpenseState(
    status: ExpenseStatus.loaded,
    all: [
      _at(DateTime(now.year, now.month, now.day), 10), // midnight today
      _at(now.subtract(const Duration(days: 3)), 20),
      _at(now.subtract(const Duration(days: 40)), 40),
    ],
  );

  test('today filter keeps only today', () {
    final today = state.copyWith(filter: TimeFilter.today);
    expect(today.filtered.length, 1);
    expect(today.total, 10);
  });

  test('week filter keeps last 7 days', () {
    final week = state.copyWith(filter: TimeFilter.week);
    expect(week.filtered.length, 2);
    expect(week.total, 30);
  });

  test('all filter keeps everything', () {
    final all = state.copyWith(filter: TimeFilter.all);
    expect(all.filtered.length, 3);
    expect(all.total, 70);
  });

  test('category totals ignore the active filter and use this month', () {
    final today = state.copyWith(filter: TimeFilter.today);
    // The 40-day-old expense is outside the calendar month either way.
    expect(today.monthlyCategoryTotals['Food'], today.thisMonth.fold(0.0, (s, e) => s + e.amount));
    expect(today.thisMonth.length, greaterThanOrEqualTo(1));
  });
}
