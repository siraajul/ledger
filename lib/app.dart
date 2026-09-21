import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/expense/expense_bloc.dart';
import 'bloc/expense/expense_event.dart';
import 'bloc/settings/settings_bloc.dart';
import 'bloc/settings/settings_event.dart';
import 'bloc/settings/settings_state.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'theme.dart';

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SettingsBloc()..add(const LoadSettings()),
        ),
        BlocProvider(
          create: (_) => ExpenseBloc()..add(const LoadExpenses()),
        ),
      ],
      child: MaterialApp(
        title: 'LEDGER',
        debugShowCheckedModeBanner: false,
        theme: kAppTheme,
        home: const AuthCheck(),
      ),
    );
  }
}

/// Shows onboarding or the app shell, driven by [SettingsBloc].
class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return state.onboardingComplete
            ? const MainShell()
            : const OnboardingScreen();
      },
    );
  }
}
