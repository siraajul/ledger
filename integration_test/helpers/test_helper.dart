import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ledger/main.dart';

class TestHelper {
  /// Reset app to fresh-install state (clear all SharedPreferences)
  static Future<void> resetApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Pump until a finder finds widgets, or timeout
  static Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    int maxPumps = 50,
    Duration interval = const Duration(milliseconds: 100),
  }) async {
    for (var i = 0; i < maxPumps; i++) {
      if (finder.evaluate().isNotEmpty) return;
      await tester.pump(interval);
    }
  }

  /// Complete onboarding with given name and budget
  static Future<void> completeOnboarding(
    WidgetTester tester, {
    String name = 'TestUser',
    String budget = '2000',
  }) async {
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('CONTINUE'), findsOneWidget);
    await tester.tap(find.text('CONTINUE'));
    await tester.pump(const Duration(milliseconds: 500));

    // Name page
    await tester.enterText(find.byType(TextField).first, name);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('CONTINUE'));
    await tester.pump(const Duration(milliseconds: 500));

    // Budget page
    await tester.tap(find.text('CONTINUE'));
    await tester.pump(const Duration(milliseconds: 500));

    // Done page
    expect(find.text('START'), findsOneWidget);
    await tester.tap(find.text('START'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// Add a complete expense via the UI
  static Future<void> addExpense(
    WidgetTester tester, {
    String amount = '25.50',
    String description = 'Coffee',
    String category = 'Food',
    String? note,
  }) async {
    await tester.enterText(
      find.byType(TextFormField).first,
      amount,
    );
    await tester.pump(const Duration(milliseconds: 100));

    await tester.enterText(
      find.byType(TextFormField).at(1),
      description,
    );
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text(category.toUpperCase()));
    await tester.pump(const Duration(milliseconds: 100));

    if (note != null) {
      await tester.enterText(
        find.byType(TextFormField).at(2),
        note,
      );
      await tester.pump(const Duration(milliseconds: 100));
    }

    await tester.tap(find.text('SAVE'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// Tap the settings/options icon to open bottom sheet
  static Future<void> openBottomSheet(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// Tap the hamburger menu to open drawer
  static Future<void> openDrawer(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// Set a PIN via the bottom sheet
  static Future<void> setPin(
    WidgetTester tester, {
    String pin = '1234',
  }) async {
    await openBottomSheet(tester);
    await tester.tap(find.text('SET / CHANGE PIN'));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.enterText(find.byType(TextField).first, pin);
    await tester.pump(const Duration(milliseconds: 100));

    await tester.enterText(find.byType(TextField).last, pin);
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('SAVE'));
    await tester.pump(const Duration(milliseconds: 500));
  }
}
