import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/database/sync_status.dart';
import 'package:ledger/widgets/sync_badge.dart';

void main() {
  test('sync status from snapshot metadata', () {
    SyncStatus s(bool cache, bool pending, bool grace) => deriveSyncStatus(
      fromCache: cache,
      pendingWrites: pending,
      connectGraceOver: grace,
    );
    expect(s(false, false, true), SyncStatus.synced);
    expect(s(false, true, true), SyncStatus.syncing); // uploading
    expect(s(true, false, false), SyncStatus.syncing); // still connecting
    expect(s(true, true, true), SyncStatus.offline); // saved locally
    expect(s(true, false, true), SyncStatus.offline);
  });

  testWidgets('badge follows the status stream', (tester) async {
    final status = StreamController<SyncStatus>();
    await tester.pumpWidget(
      MaterialApp(home: SyncBadge(status: status.stream)),
    );
    expect(find.text('SYNCING'), findsOneWidget);

    status.add(SyncStatus.synced);
    await tester.pump(); // deliver the event
    await tester.pump(); // rebuild
    expect(find.text('SYNCED'), findsOneWidget);

    status.add(SyncStatus.offline);
    await tester.pump();
    await tester.pump();
    expect(find.text('OFFLINE'), findsOneWidget);
    await status.close();
  });
}
