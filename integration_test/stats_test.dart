import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ledger/main.dart';
import 'helpers/test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Stats Screen', () {
    testWidgets('shows empty state initially', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.completeOnboarding(tester);

      // Switch to stats tab
      await tester.tap(find.text('STATS'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('NO DATA YET.'), findsOneWidget);
    });

    testWidgets('shows data after adding expenses', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.completeOnboarding(tester);

      // Add expense
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.addExpense(tester, amount: '25', description: 'Food1', category: 'Food');

      // Switch to stats
      await tester.tap(find.text('STATS'));
      await tester.pump(const Duration(milliseconds: 500));

      // Should show category breakdown
      expect(find.text('BY CATEGORY'), findsOneWidget);
    });

    testWidgets('breakdown shows percentages', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.completeOnboarding(tester);

      // Add two expenses in same category
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.addExpense(tester, amount: '30', description: 'Lunch', category: 'Food');

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.addExpense(tester, amount: '70', description: 'Dinner', category: 'Food');

      // Switch to stats
      await tester.tap(find.text('STATS'));
      await tester.pump(const Duration(milliseconds: 500));

      // Should show breakdown with 100%
      expect(find.text('BREAKDOWN'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });
  });
}
