import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/widgets/animations.dart';

double _opacity(WidgetTester tester) =>
    tester.widget<Opacity>(find.byType(Opacity)).opacity;

void main() {
  testWidgets('EnterOnce fades only rows mounted as new, and never replays', (
    tester,
  ) async {
    Widget row(bool animate) => MaterialApp(
      home: EnterOnce(animate: animate, child: const Text('row')),
    );

    // Existing rows render settled.
    await tester.pumpWidget(row(false));
    expect(_opacity(tester), 1);

    // A new row starts invisible and settles within 200ms.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(row(true));
    expect(_opacity(tester), 0);
    await tester.pump(const Duration(milliseconds: 200));
    expect(_opacity(tester), 1);

    // Rebuilding the same row never restarts it.
    await tester.pumpWidget(row(true));
    expect(_opacity(tester), 1);
  });
}
