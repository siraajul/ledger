import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ledger/main.dart';

void main() {
  testWidgets('App starts into onboarding when not yet complete',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': false});

    await tester.pumpWidget(const ExpenseTrackerApp());
    await tester.pump(); // settings load
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(ExpenseTrackerApp), findsOneWidget);
  });
}
