import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ledger/app.dart';
import 'package:ledger/bloc/settings/settings_bloc.dart';
import 'package:ledger/bloc/settings/settings_event.dart';
import 'package:ledger/screens/onboarding_screen.dart';

void main() {
  // Tests AuthCheck (below the Firebase AuthGate) so no Firebase app is needed.
  testWidgets('App starts into onboarding when not yet complete', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': false});

    await tester.pumpWidget(
      BlocProvider(
        create: (_) => SettingsBloc()..add(const LoadSettings()),
        child: const MaterialApp(home: AuthCheck()),
      ),
    );
    await tester.pump(); // settings load
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}
