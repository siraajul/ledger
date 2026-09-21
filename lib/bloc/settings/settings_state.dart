import 'package:equatable/equatable.dart';

enum SettingsStatus { initial, loaded }

class SettingsState extends Equatable {
  final String userName;
  final double budget;
  final bool onboardingComplete;
  final SettingsStatus status;

  const SettingsState({
    this.userName = '',
    this.budget = 0,
    this.onboardingComplete = false,
    this.status = SettingsStatus.initial,
  });

  bool get isLoading => status == SettingsStatus.initial;

  SettingsState copyWith({
    String? userName,
    double? budget,
    bool? onboardingComplete,
    SettingsStatus? status,
  }) {
    return SettingsState(
      userName: userName ?? this.userName,
      budget: budget ?? this.budget,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [userName, budget, onboardingComplete, status];
}
