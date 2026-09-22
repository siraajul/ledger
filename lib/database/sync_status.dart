import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum SyncStatus {
  /// Server has confirmed everything; nothing waiting to upload.
  synced,

  /// Changes are saved on the device and being uploaded, or the app is
  /// still connecting after launch.
  syncing,

  /// No server connection. Changes are kept on the device and upload later.
  offline,
}

/// How long to wait for the first server response after launch before
/// calling it offline, so a normal cold start doesn't flash OFFLINE.
const kConnectGrace = Duration(seconds: 5);

SyncStatus deriveSyncStatus({
  required bool fromCache,
  required bool pendingWrites,
  required bool connectGraceOver,
}) {
  if (fromCache) {
    return connectGraceOver ? SyncStatus.offline : SyncStatus.syncing;
  }
  return pendingWrites ? SyncStatus.syncing : SyncStatus.synced;
}

/// Sync state of the signed-in user's data (settings document + expenses),
/// from Firestore's own snapshot metadata.
Stream<SyncStatus> watchSyncStatus() {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();
  final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
  // Same queries the blocs listen to, so Firestore shares the listeners.
  final sources = <Stream<SnapshotMetadata>>[
    userDoc.snapshots(includeMetadataChanges: true).map((s) => s.metadata),
    userDoc
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots(includeMetadataChanges: true)
        .map((s) => s.metadata),
  ];

  late StreamController<SyncStatus> controller;
  final latest = List<SnapshotMetadata?>.filled(sources.length, null);
  final subs = <StreamSubscription<SnapshotMetadata>>[];
  var graceOver = false;
  Timer? grace;

  void emit() {
    final known = latest.whereType<SnapshotMetadata>();
    if (known.isEmpty) return;
    controller.add(
      deriveSyncStatus(
        fromCache: known.any((m) => m.isFromCache),
        pendingWrites: known.any((m) => m.hasPendingWrites),
        connectGraceOver: graceOver,
      ),
    );
  }

  controller = StreamController<SyncStatus>(
    onListen: () {
      controller.add(SyncStatus.syncing);
      grace = Timer(kConnectGrace, () {
        graceOver = true;
        emit();
      });
      for (var i = 0; i < sources.length; i++) {
        subs.add(
          sources[i].listen((m) {
            latest[i] = m;
            // Once the server has answered, losing it again is "offline"
            // right away, not after another grace period.
            if (!m.isFromCache) graceOver = true;
            emit();
          }, onError: (_) {}),
        );
      }
    },
    onCancel: () async {
      grace?.cancel();
      for (final s in subs) {
        await s.cancel();
      }
    },
  );
  return controller.stream.distinct();
}
