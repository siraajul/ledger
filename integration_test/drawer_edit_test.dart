import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ledger/main.dart';
import 'helpers/test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Drawer', () {
    testWidgets('drawer opens from hamburger menu', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.completeOnboarding(tester);

      await TestHelper.openDrawer(tester);

      // Drawer should be open with nav items
      expect(find.text('HOME'), findsWidgets);
      expect(find.text('STATS'), findsWidgets);
    });
  });

  group('Edit Expense', () {
    testWidgets('edit expense opens with pre-filled data', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.completeOnboarding(tester);

      // Add expense
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.addExpense(tester, amount: '42', description: 'EditMe');

      // Tap to edit
      await tester.tap(find.textContaining('EDITME'));
      await tester.pump(const Duration(milliseconds: 500));

      // Should show edit screen with delete button
      expect(find.text('EDIT'), findsOneWidget);
      expect(find.text('DELETE EXPENSE'), findsOneWidget);
    });

    testWidgets('delete expense from edit screen with PIN', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.completeOnboarding(tester);

      // Set PIN
      await TestHelper.setPin(tester, pin: '1234');

      // Add expense
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.addExpense(tester, amount: '10', description: 'DeleteMe');

      // Tap to edit
      await tester.tap(find.textContaining('DELETEME'));
      await tester.pump(const Duration(milliseconds: 500));

      // Enter PIN
      await tester.enterText(find.byType(TextField).last, '1234');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('CONFIRM'));
      await tester.pump(const Duration(milliseconds: 500));

      // Tap delete
      await tester.tap(find.text('DELETE EXPENSE'));
      await tester.pump(const Duration(milliseconds: 500));

      // Enter PIN again for delete
      await tester.enterText(find.byType(TextField).last, '1234');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('CONFIRM'));
      await tester.pump(const Duration(milliseconds: 500));

      // Confirm dialog
      await tester.tap(find.text('DELETE'));
      await tester.pump(const Duration(milliseconds: 500));

      // Should be back on home, expense deleted
      expect(find.textContaining('DELETEME'), findsNothing);
    });
  });
}
