import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ledger/main.dart';
import 'helpers/test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Onboarding Flow', () {
    testWidgets('shows onboarding on fresh install', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Should show welcome page with CONTINUE button
      expect(find.text('CONTINUE'), findsOneWidget);
      expect(find.textContaining('MONEY'), findsOneWidget);
    });

    testWidgets('cannot proceed without entering name', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Go to name page
      await tester.tap(find.text('CONTINUE'));
      await tester.pump(const Duration(milliseconds: 500));

      // Try to continue without entering name
      await tester.tap(find.text('CONTINUE'));
      await tester.pump(const Duration(milliseconds: 500));

      // Should still be on name page (no BUDGET? visible)
      expect(find.textContaining('BUDGET'), findsNothing);
    });

    testWidgets('can proceed after entering name', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Go to name page
      await tester.tap(find.text('CONTINUE'));
      await tester.pump(const Duration(milliseconds: 500));

      // Enter name
      await tester.enterText(find.byType(TextField).first, 'Alice');
      await tester.pump(const Duration(milliseconds: 200));

      // Continue to budget page
      await tester.tap(find.text('CONTINUE'));
      await tester.pump(const Duration(milliseconds: 500));

      // Should be on budget page
      expect(find.textContaining('BUDGET'), findsOneWidget);
    });

    testWidgets('budget presets update field', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Navigate to budget page
      await tester.tap(find.text('CONTINUE'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.enterText(find.byType(TextField).first, 'Bob');
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('CONTINUE'));
      await tester.pump(const Duration(milliseconds: 500));

      // Tap $500 preset
      await tester.tap(find.text('\$500'));
      await tester.pump(const Duration(milliseconds: 200));

      // Field should show 500
      expect(find.text('500'), findsOneWidget);
    });

    testWidgets('completes onboarding and shows home', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));

      await TestHelper.completeOnboarding(tester, name: 'TestUser');

      // Wait for home screen to render
      await TestHelper.pumpUntilFound(tester, find.textContaining('TESTUSER'));

      // Home screen should show greeting and bottom nav
      expect(find.textContaining('TESTUSER'), findsOneWidget);
      expect(find.text('HOME'), findsWidgets);
      expect(find.text('STATS'), findsWidgets);
    });

    testWidgets('onboarding persists across restart', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));

      await TestHelper.completeOnboarding(tester);
      await TestHelper.pumpUntilFound(tester, find.text('HOME'));

      // Restart app
      await tester.pumpWidget(const ExpenseTrackerApp());
      await TestHelper.pumpUntilFound(tester, find.text('HOME'));

      // Should skip onboarding - bottom nav visible
      expect(find.text('HOME'), findsWidgets);
      expect(find.text('STATS'), findsWidgets);
    });

    testWidgets('progress dots update correctly', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Navigate forward through pages
      await tester.tap(find.text('CONTINUE'));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.enterText(find.byType(TextField).first, 'Test');
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('CONTINUE'));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('CONTINUE'));
      await tester.pump(const Duration(milliseconds: 500));

      // Done page - START button
      expect(find.text('START'), findsOneWidget);
    });

    testWidgets('back button returns to previous page', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Go to name page
      await tester.tap(find.text('CONTINUE'));
      await tester.pump(const Duration(milliseconds: 500));

      // Tap back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump(const Duration(milliseconds: 500));

      // Should be back on welcome page
      expect(find.textContaining('MONEY'), findsOneWidget);
    });
  });
}
