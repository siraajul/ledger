import 'package:flutter_bloc/flutter_bloc.dart';
import '../../database/database_helper.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final DatabaseHelper _db;

  ExpenseBloc({DatabaseHelper? db})
      : _db = db ?? DatabaseHelper.instance,
        super(const ExpenseState()) {
    on<LoadExpenses>(_onLoad);
    on<FilterChanged>(_onFilterChanged);
    on<ExpenseAdded>(_onAdded);
    on<ExpenseUpdated>(_onUpdated);
    on<ExpenseDeleted>(_onDeleted);
    on<AllExpensesCleared>(_onCleared);
  }

  Future<void> _onLoad(LoadExpenses event, Emitter<ExpenseState> emit) async {
    emit(state.copyWith(status: ExpenseStatus.loading));
    await _reload(emit);
  }

  void _onFilterChanged(FilterChanged event, Emitter<ExpenseState> emit) {
    emit(state.copyWith(filter: event.filter));
  }

  Future<void> _onAdded(ExpenseAdded event, Emitter<ExpenseState> emit) =>
      _mutate(emit, () => _db.insertExpense(event.expense));

  Future<void> _onUpdated(ExpenseUpdated event, Emitter<ExpenseState> emit) =>
      _mutate(emit, () => _db.updateExpense(event.expense));

  Future<void> _onDeleted(ExpenseDeleted event, Emitter<ExpenseState> emit) =>
      _mutate(emit, () => _db.deleteExpense(event.id));

  Future<void> _onCleared(
          AllExpensesCleared event, Emitter<ExpenseState> emit) =>
      _mutate(emit, _db.clearAllExpenses);

  /// Writes through to the database, then re-reads so state always mirrors it.
  Future<void> _mutate(
      Emitter<ExpenseState> emit, Future<void> Function() write) async {
    try {
      await write();
    } catch (e) {
      emit(state.copyWith(status: ExpenseStatus.failure, error: '$e'));
      return;
    }
    await _reload(emit);
  }

  Future<void> _reload(Emitter<ExpenseState> emit) async {
    try {
      final all = await _db.getAllExpenses();
      emit(state.copyWith(all: all, status: ExpenseStatus.loaded));
    } catch (e) {
      emit(state.copyWith(status: ExpenseStatus.failure, error: '$e'));
    }
  }
}
