import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../database/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _repo;

  /// Edits not yet sent. Onboarding fires one event per keystroke, so writes
  /// are coalesced; pending values also win over incoming snapshots so a
  /// remote echo can't roll back what the user is typing.
  final Map<String, Object> _pending = {};
  Timer? _flushTimer;

  SettingsBloc({SettingsRepository? repo})
    : _repo = repo ?? SettingsRepository.instance,
      super(const SettingsState()) {
    on<LoadSettings>(_onLoad);
    on<UserNameChanged>(
      (e, emit) => _set(emit, {SettingsRepository.kName: e.name}),
    );
    on<BudgetChanged>(
      (e, emit) => _set(emit, {SettingsRepository.kBudget: e.budget}),
    );
    on<OnboardingCompleted>(
      (e, emit) =>
          _set(emit, {SettingsRepository.kOnboardingComplete: true}, now: true),
    );
    on<OnboardingReset>(
      (e, emit) => _set(emit, {
        SettingsRepository.kOnboardingComplete: false,
      }, now: true),
    );
  }

  Future<void> _onLoad(LoadSettings event, Emitter<SettingsState> emit) =>
      emit.forEach<Map<String, dynamic>?>(
        _repo.watch(),
        onData: (remote) =>
            remote == null ? state : _fromMap({...remote, ..._pending}),
        // Keep the last known settings; a failed listener isn't worth
        // blocking the app over.
        onError: (_, _) => state.copyWith(status: SettingsStatus.loaded),
      );

  void _set(
    Emitter<SettingsState> emit,
    Map<String, Object> fields, {
    bool now = false,
  }) {
    _pending.addAll(fields);
    emit(_fromMap({..._toMap(state), ..._pending}));
    _flushTimer?.cancel();
    if (now) {
      _flush();
    } else {
      _flushTimer = Timer(const Duration(milliseconds: 400), _flush);
    }
  }

  void _flush() {
    if (_pending.isEmpty) return;
    final fields = Map.of(_pending);
    _pending.clear();
    // Failures surface as the listener re-emitting the server's value.
    _repo.update(fields).catchError((_) {});
  }

  @override
  Future<void> close() {
    _flushTimer?.cancel();
    _flush();
    return super.close();
  }

  static SettingsState _fromMap(Map<String, dynamic> m) => SettingsState(
    userName: m[SettingsRepository.kName] as String? ?? '',
    budget: (m[SettingsRepository.kBudget] as num?)?.toDouble() ?? 0,
    onboardingComplete: m[SettingsRepository.kOnboardingComplete] == true,
    status: SettingsStatus.loaded,
  );

  static Map<String, Object> _toMap(SettingsState s) => {
    SettingsRepository.kName: s.userName,
    SettingsRepository.kBudget: s.budget,
    SettingsRepository.kOnboardingComplete: s.onboardingComplete,
  };
}
