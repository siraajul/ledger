import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ledger/main.dart';
import 'helpers/test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Add Expense', () {
    testWidgets('opens add expense screen from FAB', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.completeOnboarding(tester);

      // Tap FAB
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(milliseconds: 500));

      // Should show add expense form
      expect(find.text('NEW EXPENSE'), findsOneWidget);
      expect(find.text('AMOUNT'), findsOneWidget);
      expect(find.text('DESCRIPTION'), findsOneWidget);
      expect(find.text('CATEGORY'), findsOneWidget);
    });

    testWidgets('validates empty amount', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.completeOnboarding(tester);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(milliseconds: 500));

      // Try to save without amount
      await tester.tap(find.text('SAVE'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('ENTER AMOUNT'), findsOneWidget);
    });

    testWidgets('validates zero amount', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.completeOnboarding(tester);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.enterText(find.byType(TextFormField).first, '0');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('SAVE'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('MUST BE > 0'), findsOneWidget);
    });

    testWidgets('validates empty description', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.completeOnboarding(tester);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.enterText(find.byType(TextFormField).first, '10');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('SAVE'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('REQUIRED'), findsOneWidget);
    });

    testWidgets('adds expense successfully', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.completeOnboarding(tester);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(milliseconds: 500));

      await TestHelper.addExpense(tester, amount: '25', description: 'Lunch');

      // Should return to home and show the expense
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.textContaining('LUNCH'), findsOneWidget);
    });

    testWidgets('category selection works', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.completeOnboarding(tester);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(milliseconds: 500));

      // Tap Transport
      await tester.tap(find.text('TRANSPORT'));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap Shopping
      await tester.tap(find.text('SHOPPING'));
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('close button discards expense', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.completeOnboarding(tester);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(milliseconds: 500));

      // Enter some data
      await tester.enterText(find.byType(TextFormField).first, '50');
      await tester.pump(const Duration(milliseconds: 100));

      // Close without saving
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump(const Duration(milliseconds: 500));

      // Should be back on home, no expense added
      expect(find.text('NOTHING YET.'), findsOneWidget);
    });

    testWidgets('expense appears in list after adding', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.completeOnboarding(tester);

      // Add first expense
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.addExpense(tester, amount: '15', description: 'Taxi');

      // Add second expense
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.addExpense(tester, amount: '30', description: 'Dinner');

      // Both should appear
      expect(find.textContaining('TAXI'), findsOneWidget);
      expect(find.textContaining('DINNER'), findsOneWidget);
    });
  });
}
