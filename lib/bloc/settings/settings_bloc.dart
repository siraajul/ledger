import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  static const _kUserName = 'user_name';
  static const _kBudget = 'monthly_budget';
  static const _kOnboardingComplete = 'onboarding_complete';

  SettingsBloc() : super(const SettingsState()) {
    on<LoadSettings>(_onLoad);
    on<UserNameChanged>(_onUserNameChanged);
    on<BudgetChanged>(_onBudgetChanged);
    on<OnboardingCompleted>(_onOnboardingCompleted);
    on<OnboardingReset>(_onOnboardingReset);
  }

  Future<void> _onLoad(LoadSettings event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    emit(state.copyWith(
      userName: prefs.getString(_kUserName) ?? '',
      budget: prefs.getDouble(_kBudget) ?? 0,
      onboardingComplete: prefs.getBool(_kOnboardingComplete) ?? false,
      status: SettingsStatus.loaded,
    ));
  }

  Future<void> _onUserNameChanged(
      UserNameChanged event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserName, event.name);
    emit(state.copyWith(userName: event.name));
  }

  Future<void> _onBudgetChanged(
      BudgetChanged event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kBudget, event.budget);
    emit(state.copyWith(budget: event.budget));
  }

  Future<void> _onOnboardingCompleted(
      OnboardingCompleted event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingComplete, true);
    emit(state.copyWith(onboardingComplete: true));
  }

  Future<void> _onOnboardingReset(
      OnboardingReset event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingComplete, false);
    emit(state.copyWith(onboardingComplete: false));
  }
}
