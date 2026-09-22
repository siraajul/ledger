import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/expense/expense_bloc.dart';
import 'bloc/expense/expense_event.dart';
import 'bloc/settings/settings_bloc.dart';
import 'bloc/settings/settings_event.dart';
import 'bloc/settings/settings_state.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding_screen.dart';
import 'theme.dart';

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsBloc()..add(const LoadSettings()),
      child: MaterialApp(
        title: 'LEDGER',
        debugShowCheckedModeBanner: false,
        theme: kAppTheme,
        home: const AuthGate(),
      ),
    );
  }
}

/// Gates the whole app behind a Firebase (Google) session.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) return const LoginScreen();
        // Keyed by uid so switching accounts starts a clean expense stream.
        return BlocProvider(
          key: ValueKey(user.uid),
          create: (_) => ExpenseBloc()..add(const LoadExpenses()),
          child: const AuthCheck(),
        );
      },
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
