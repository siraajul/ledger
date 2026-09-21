import 'package:equatable/equatable.dart';
import '../../models/expense.dart';
import 'expense_state.dart';

sealed class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

/// Reload the full expense list from the database.
class LoadExpenses extends ExpenseEvent {
  const LoadExpenses();
}

class FilterChanged extends ExpenseEvent {
  final TimeFilter filter;
  const FilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

class ExpenseAdded extends ExpenseEvent {
  final Expense expense;
  const ExpenseAdded(this.expense);

  @override
  List<Object?> get props => [expense.id];
}

class ExpenseUpdated extends ExpenseEvent {
  final Expense expense;
  const ExpenseUpdated(this.expense);

  @override
  List<Object?> get props => [expense.id];
}

class ExpenseDeleted extends ExpenseEvent {
  final String id;
  const ExpenseDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class AllExpensesCleared extends ExpenseEvent {
  const AllExpensesCleared();
}
