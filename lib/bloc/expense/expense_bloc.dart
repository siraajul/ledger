import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../database/expense_repository.dart';
import '../../models/expense.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository _db;

  ExpenseBloc({ExpenseRepository? db})
    : _db = db ?? ExpenseRepository.instance,
      super(const ExpenseState()) {
    on<LoadExpenses>(_onLoad);
    on<FilterChanged>(_onFilterChanged);
    on<ExpenseAdded>(_onAdded);
    on<ExpenseUpdated>(_onUpdated);
    on<ExpenseDeleted>(_onDeleted);
    on<AllExpensesCleared>(_onCleared);
  }

  /// Subscribes to the cloud collection; the stream keeps [state] in sync with
  /// writes from this device and from any other device on the same account.
  Future<void> _onLoad(LoadExpenses event, Emitter<ExpenseState> emit) async {
    emit(state.copyWith(status: ExpenseStatus.loading));
    // Best-effort; a failure here just means the retry happens next launch.
    unawaited(_db.migrateLegacyLocalExpenses().catchError((_) {}));
    await emit.forEach<List<Expense>>(
      _db.watchExpenses(),
      onData: (all) => state.copyWith(all: all, status: ExpenseStatus.loaded),
      onError: (e, _) =>
          state.copyWith(status: ExpenseStatus.failure, error: '$e'),
    );
  }

  void _onFilterChanged(FilterChanged event, Emitter<ExpenseState> emit) {
    emit(state.copyWith(filter: event.filter));
  }

  void _onAdded(ExpenseAdded event, Emitter<ExpenseState> emit) =>
      _write(() => _db.insertExpense(event.expense));

  void _onUpdated(ExpenseUpdated event, Emitter<ExpenseState> emit) =>
      _write(() => _db.updateExpense(event.expense));

  void _onDeleted(ExpenseDeleted event, Emitter<ExpenseState> emit) =>
      _write(() => _db.deleteExpense(event.id));

  void _onCleared(AllExpensesCleared event, Emitter<ExpenseState> emit) =>
      _write(_db.clearAllExpenses);

  /// A Firestore write future only completes once the server acknowledges it,
  /// so it is deliberately not awaited: the local cache applies the change (and
  /// re-emits it through [watchExpenses]) right away and replays it when the
  /// device is back online. Failures surface on the read stream.
  void _write(Future<void> Function() write) {
    unawaited(
      write().catchError((Object e) {
        if (!isClosed) addError(e);
      }),
    );
  }
}
