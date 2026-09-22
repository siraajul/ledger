import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/expense/expense_bloc.dart';
import 'bloc/expense/expense_event.dart';
import 'bloc/expense/expense_state.dart';
import 'bloc/settings/settings_bloc.dart';
import 'bloc/settings/settings_event.dart';
import 'bloc/settings/settings_state.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding_screen.dart';
import 'services/reminder_service.dart';
import 'theme.dart';

/// Gates the whole app behind a Firebase (Google) session.
///
/// The per-user blocs sit *above* [MaterialApp] so every route (pushed
/// screens, bottom sheets, dialogs) can read them, and are keyed by uid so
/// switching accounts starts clean streams.
class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final app = MaterialApp(
          title: 'LEDGER',
          debugShowCheckedModeBanner: false,
          theme: kAppTheme,
          home: snapshot.connectionState == ConnectionState.waiting
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : user == null
              ? const LoginScreen()
              : const AuthCheck(),
        );
        if (user == null) return app;
        return MultiBlocProvider(
          key: ValueKey(user.uid),
          providers: [
            BlocProvider(
              create: (_) => SettingsBloc()..add(const LoadSettings()),
            ),
            BlocProvider(
              create: (_) => ExpenseBloc()..add(const LoadExpenses()),
            ),
          ],
          // Keeps the "no expense logged" reminder in step with the data,
          // including expenses logged on other devices.
          child: BlocListener<ExpenseBloc, ExpenseState>(
            listenWhen: (a, b) =>
                b.status == ExpenseStatus.loaded && a.all != b.all,
            listener: (context, state) => ReminderService.instance
                .onExpensesChanged(newestExpenseDate(state.all)),
            child: app,
          ),
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
