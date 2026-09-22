import 'package:flutter/material.dart';

import '../database/sync_status.dart';
import '../theme.dart';

/// Small chip showing whether the user's data has reached the server.
class SyncBadge extends StatefulWidget {
  /// Defaults to the live Firestore status; tests pass their own stream.
  final Stream<SyncStatus>? status;

  const SyncBadge({super.key, this.status});

  @override
  State<SyncBadge> createState() => _SyncBadgeState();
}

class _SyncBadgeState extends State<SyncBadge> {
  // Created once: the header rebuilds often and must not re-subscribe.
  late final Stream<SyncStatus> _status = widget.status ?? watchSyncStatus();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncStatus>(
      stream: _status,
      initialData: SyncStatus.syncing,
      builder: (context, snapshot) {
        final (label, icon, color) = switch (snapshot.data!) {
          SyncStatus.synced => ('SYNCED', Icons.cloud_done_rounded, kGreen),
          SyncStatus.syncing => (
            'SYNCING',
            Icons.cloud_upload_rounded,
            kYellow,
          ),
          SyncStatus.offline => ('OFFLINE', Icons.cloud_off_rounded, kWhite),
        };
        return Semantics(
          label: 'Sync status: ${label.toLowerCase()}',
          excludeSemantics: true,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              border: const Border.fromBorderSide(
                BorderSide(color: kBlack, width: 2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: kBlack),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
