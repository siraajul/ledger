import 'package:equatable/equatable.dart';
import '../../models/expense.dart';

enum TimeFilter { today, week, month, all }

enum ExpenseStatus { initial, loading, loaded, failure }

class ExpenseState extends Equatable {
  /// Every expense in the database, newest first. Filters are applied on top
  /// of this so Home and Stats can read different slices of one source.
  final List<Expense> all;
  final TimeFilter filter;
  final ExpenseStatus status;
  final String? error;

  const ExpenseState({
    this.all = const [],
    this.filter = TimeFilter.month,
    this.status = ExpenseStatus.initial,
    this.error,
  });

  ExpenseState copyWith({
    List<Expense>? all,
    TimeFilter? filter,
    ExpenseStatus? status,
    String? error,
  }) {
    return ExpenseState(
      all: all ?? this.all,
      filter: filter ?? this.filter,
      status: status ?? this.status,
      error: error,
    );
  }

  bool get isLoading =>
      status == ExpenseStatus.initial || status == ExpenseStatus.loading;

  /// Expenses matching the active [filter].
  List<Expense> get filtered => _since(startOf(filter));

  /// Total of [filtered].
  double get total => filtered.fold(0.0, (sum, e) => sum + e.amount);

  /// Calendar-month expenses, independent of [filter] (used by Stats).
  List<Expense> get thisMonth => _since(startOf(TimeFilter.month));

  Map<String, double> get monthlyCategoryTotals {
    final totals = <String, double>{};
    for (final expense in thisMonth) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  List<Expense> _since(DateTime? start) {
    if (start == null) return all;
    final now = DateTime.now();
    return all
        .where((e) => !e.date.isBefore(start) && !e.date.isAfter(now))
        .toList();
  }

  static DateTime? startOf(TimeFilter filter) {
    final now = DateTime.now();
    switch (filter) {
      case TimeFilter.today:
        return DateTime(now.year, now.month, now.day);
      case TimeFilter.week:
        return now.subtract(const Duration(days: 7));
      case TimeFilter.month:
        return DateTime(now.year, now.month, 1);
      case TimeFilter.all:
        return null;
    }
  }

  @override
  List<Object?> get props => [all, filter, status, error];
}
