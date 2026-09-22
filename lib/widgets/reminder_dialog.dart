import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/reminder_service.dart';
import '../theme.dart';
import 'brutal_widgets.dart';

const _maxTimes = 5;

int _minutes(TimeOfDay t) => t.hour * 60 + t.minute;

/// Lets the user turn check-in reminders on/off and edit the daily times.
/// Saving asks for notification permission if needed.
Future<void> showReminderDialog(BuildContext context) async {
  final service = ReminderService.instance;
  var settings = await service.load();
  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        final times = [...settings.times]
          ..sort((a, b) => _minutes(a) - _minutes(b));

        Future<void> pick({TimeOfDay? replacing}) async {
          final picked = await showTimePicker(
            context: context,
            initialTime: replacing ?? const TimeOfDay(hour: 12, minute: 0),
          );
          if (picked == null) return;
          final next = [
            for (final t in times)
              if (t != replacing) t,
          ];
          if (!next.any((t) => _minutes(t) == _minutes(picked))) {
            next.add(picked);
          }
          setState(() => settings = settings.copyWith(times: next));
        }

        return brutalDialog(
          title: 'CHECK-IN REMINDERS',
          titleStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: kBlack,
                  activeTrackColor: kGreen,
                  title: const Text(
                    'REMIND ME TO LOG',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                  value: settings.enabled,
                  onChanged: (v) =>
                      setState(() => settings = settings.copyWith(enabled: v)),
                ),
                const Text(
                  'SKIPPED IF YOU ALREADY LOGGED SHORTLY BEFORE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                for (final t in times)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: BrutalDialogButton(
                            label: t.format(context),
                            color: settings.enabled ? kBlue : kWhite,
                            onTap: () {
                              if (settings.enabled) pick(replacing: t);
                            },
                          ),
                        ),
                        IconButton(
                          tooltip: 'Remove ${t.format(context)}',
                          icon: const Icon(Icons.close_rounded),
                          onPressed: settings.enabled && times.length > 1
                              ? () => setState(
                                  () => settings = settings.copyWith(
                                    times: [
                                      for (final x in times)
                                        if (x != t) x,
                                    ],
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                if (times.length < _maxTimes)
                  BrutalDialogButton(
                    label: '+ ADD TIME',
                    color: kWhite,
                    onTap: () {
                      if (settings.enabled) pick();
                    },
                  ),
              ],
            ),
          ),
          actions: [
            BrutalDialogButton(
              label: 'CANCEL',
              color: kWhite,
              fillOnPress: true,
              onTap: () => Navigator.pop(dialogContext),
            ),
            BrutalDialogButton(
              label: 'SAVE',
              color: kGreen,
              fillOnPress: true,
              onTap: () async {
                HapticFeedback.heavyImpact();
                final navigator = Navigator.of(dialogContext);
                final messenger = ScaffoldMessenger.maybeOf(dialogContext);
                final granted = await service.save(settings);
                navigator.pop();
                if (!granted) {
                  messenger?.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'NOTIFICATIONS ARE OFF FOR LEDGER — ENABLE THEM IN SETTINGS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      backgroundColor: kBlack,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    ),
  );
}
