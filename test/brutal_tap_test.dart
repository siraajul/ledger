import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/widgets/brutal_widgets.dart';

void main() {
  testWidgets('BrutalTap is a named, focusable, keyboard-activated button', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BrutalTap(
            label: 'Close',
            selected: true,
            onTap: () => taps++,
            child: const Icon(Icons.close),
          ),
        ),
      ),
    );

    final node = tester.getSemantics(find.byType(BrutalTap));
    expect(
      node,
      matchesSemantics(
        label: 'Close',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasSelectedState: true,
        isSelected: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );

    await tester.tap(find.byType(BrutalTap));
    expect(taps, 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(taps, 3);
  });
}
