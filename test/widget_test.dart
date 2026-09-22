import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/app.dart';
import 'package:ledger/bloc/settings/settings_bloc.dart';
import 'package:ledger/bloc/settings/settings_event.dart';
import 'package:ledger/database/settings_repository.dart';
import 'package:ledger/screens/onboarding_screen.dart';

/// In-memory stand-in for the Firestore-backed settings document.
class FakeSettingsRepository implements SettingsRepository {
  final remote = StreamController<Map<String, dynamic>?>.broadcast();
  final writes = <Map<String, Object>>[];

  @override
  Stream<Map<String, dynamic>?> watch() => remote.stream;

  @override
  Future<void> update(Map<String, Object> fields) async => writes.add(fields);
}

void main() {
  // Tests AuthCheck (below the Firebase auth gate) with an in-memory settings
  // repository, so no Firebase app is needed.
  testWidgets('App starts into onboarding when not yet complete', (
    WidgetTester tester,
  ) async {
    final repo = FakeSettingsRepository();
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => SettingsBloc(repo: repo)..add(const LoadSettings()),
        child: const MaterialApp(home: AuthCheck()),
      ),
    );
    await tester.pump();
    repo.remote.add({SettingsRepository.kOnboardingComplete: false});
    await tester.pump();

    expect(find.byType(OnboardingScreen), findsOneWidget);
  });

  test(
    'settings: coalesce typing, keep local edits over remote echoes',
    () async {
      final repo = FakeSettingsRepository();
      final bloc = SettingsBloc(repo: repo)..add(const LoadSettings());
      await pumpEventQueue();

      repo.remote.add(null); // cache empty, server not heard from yet
      await pumpEventQueue();
      expect(bloc.state.isLoading, isTrue);

      repo.remote.add({
        SettingsRepository.kName: 'Old',
        SettingsRepository.kBudget: 5,
      });
      await pumpEventQueue();
      expect(bloc.state.userName, 'Old');

      for (final n in ['S', 'Si', 'Sir']) {
        bloc.add(UserNameChanged(n));
      }
      await pumpEventQueue();
      // A remote snapshot mid-typing must not roll the name back.
      repo.remote.add({
        SettingsRepository.kName: 'Old',
        SettingsRepository.kBudget: 9,
      });
      await pumpEventQueue();
      expect(bloc.state.userName, 'Sir');
      expect(bloc.state.budget, 9);
      expect(repo.writes, isEmpty); // still debouncing

      await Future<void>.delayed(const Duration(milliseconds: 450));
      expect(repo.writes, [
        {SettingsRepository.kName: 'Sir'},
      ]);

      bloc.add(const OnboardingCompleted());
      await pumpEventQueue();
      expect(repo.writes.last, {SettingsRepository.kOnboardingComplete: true});
      expect(bloc.state.onboardingComplete, isTrue);

      await bloc.close();
    },
  );
}
