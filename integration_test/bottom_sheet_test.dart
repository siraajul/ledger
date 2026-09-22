import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ledger/main.dart';
import 'helpers/test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Bottom Sheet & Settings', () {
    testWidgets('bottom sheet opens from settings icon', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.completeOnboarding(tester);

      await TestHelper.openBottomSheet(tester);

      expect(find.text('OPTIONS'), findsOneWidget);
      expect(find.text('QUICK ACTIONS'), findsOneWidget);
      expect(find.text('SETTINGS'), findsOneWidget);
    });

    testWidgets('edit budget opens dialog', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.completeOnboarding(tester);

      await TestHelper.openBottomSheet(tester);
      await tester.tap(find.textContaining('EDIT'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('EDIT BUDGET'), findsOneWidget);
    });

    testWidgets('change name opens dialog', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.completeOnboarding(tester);

      await TestHelper.openBottomSheet(tester);
      await tester.tap(find.textContaining('CHANGE'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('CHANGE NAME'), findsOneWidget);
    });

    testWidgets('about app shows version', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.completeOnboarding(tester);

      await TestHelper.openBottomSheet(tester);
      await tester.tap(find.textContaining('ABOUT'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.textContaining('Version'), findsOneWidget);
    });

    testWidgets('restart onboarding resets app', (tester) async {
      await TestHelper.resetApp();
      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pump(const Duration(milliseconds: 500));
      await TestHelper.completeOnboarding(tester);

      await TestHelper.openBottomSheet(tester);
      await tester.tap(find.text('RESTART ONBOARDING'));
      await tester.pump(const Duration(milliseconds: 500));

      // Confirm dialog
      expect(find.text('RESTART ONBOARDING?'), findsOneWidget);
      await tester.tap(find.text('RESET'));
      await tester.pump(const Duration(milliseconds: 500));

      // Should be back on onboarding
      expect(find.textContaining('MONEY'), findsOneWidget);
    });
  });
}
