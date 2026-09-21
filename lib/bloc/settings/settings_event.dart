import 'package:equatable/equatable.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class UserNameChanged extends SettingsEvent {
  final String name;
  const UserNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class BudgetChanged extends SettingsEvent {
  final double budget;
  const BudgetChanged(this.budget);

  @override
  List<Object?> get props => [budget];
}

class OnboardingCompleted extends SettingsEvent {
  const OnboardingCompleted();
}

class OnboardingReset extends SettingsEvent {
  const OnboardingReset();
}
