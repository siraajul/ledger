import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ledger/main.dart';
import 'helpers/test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('PIN System', () {
    testWidgets('no PIN set - operations allowed without prompt', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.completeOnboarding(tester);

      // Add an expense
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.addExpense(tester, amount: '10', description: 'Test');

      // Tap to edit - should go directly to edit screen (no PIN)
      await tester.tap(find.textContaining('TEST'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('EDIT'), findsOneWidget);
    });

    testWidgets('set PIN via bottom sheet', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.completeOnboarding(tester);

      await TestHelper.setPin(tester, pin: '1234');

      // Add an expense to verify PIN works
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.addExpense(tester, amount: '5', description: 'PinTest');

      await tester.tap(find.textContaining('PINTEST'));
      await tester.pump(const Duration(milliseconds: 500));

      // Should show PIN dialog
      expect(find.text('ENTER PIN'), findsOneWidget);
    });

    testWidgets('wrong PIN shows error', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.completeOnboarding(tester);

      // Set PIN
      await TestHelper.setPin(tester, pin: '1234');

      // Add expense
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.addExpense(tester, amount: '5', description: 'WrongPin');

      // Try to edit with wrong PIN
      await tester.tap(find.textContaining('WRONGPIN'));
      await tester.pump(const Duration(milliseconds: 500));

      // Enter wrong PIN
      await tester.enterText(find.byType(TextField).last, '9999');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('CONFIRM'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('WRONG PIN'), findsOneWidget);
    });

    testWidgets('correct PIN allows operation', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.completeOnboarding(tester);

      // Set PIN
      await TestHelper.setPin(tester, pin: '1234');

      // Add expense
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.addExpense(tester, amount: '5', description: 'CorrectPin');

      // Tap to edit
      await tester.tap(find.textContaining('CORRECTPIN'));
      await tester.pump(const Duration(milliseconds: 500));

      // Enter correct PIN
      await tester.enterText(find.byType(TextField).last, '1234');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('CONFIRM'));
      await tester.pump(const Duration(milliseconds: 500));

      // Should be on edit screen
      expect(find.text('EDIT'), findsOneWidget);
    });

    testWidgets('PIN persists across app restart', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.completeOnboarding(tester);

      // Set PIN
      await TestHelper.setPin(tester, pin: '5678');

      // Restart app
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));

      // Add expense
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.addExpense(tester, amount: '5', description: 'PersistPin');

      // Try to edit - should still prompt for PIN
      await tester.tap(find.textContaining('PERSISTPIN'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('ENTER PIN'), findsOneWidget);
    });

    testWidgets('PIN dialog cancel does not proceed', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.completeOnboarding(tester);

      // Set PIN
      await TestHelper.setPin(tester, pin: '1234');

      // Add expense
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.addExpense(tester, amount: '5', description: 'CancelPin');

      // Try to edit
      await tester.tap(find.textContaining('CANCELPIN'));
      await tester.pump(const Duration(milliseconds: 500));

      // Cancel PIN dialog
      await tester.tap(find.text('CANCEL'));
      await tester.pump(const Duration(milliseconds: 500));

      // Should NOT be on edit screen
      expect(find.text('EDIT'), findsNothing);
    });
  });
}
