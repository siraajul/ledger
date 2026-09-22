import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/reminder_service.dart';
import '../theme.dart';
import 'brutal_widgets.dart';

const _intervals = [1, 2, 3, 7];

/// Lets the user turn the "no expense logged" reminder on/off and pick its
/// time and interval. Saving asks for notification permission if needed.
Future<void> showReminderDialog(BuildContext context) async {
  final service = ReminderService.instance;
  var settings = await service.load();
  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => brutalDialog(
        title: 'REMINDER',
        titleStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        content: Column(
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
            const SizedBox(height: 8),
            const Text(
              'IF NOTHING LOGGED FOR',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final days in _intervals)
                  ChoiceChip(
                    label: Text(days == 1 ? '1 DAY' : '$days DAYS'),
                    labelStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: kBlack,
                    ),
                    selected: settings.everyDays == days,
                    selectedColor: kYellow,
                    backgroundColor: kWhite,
                    showCheckmark: false,
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(color: kBlack, width: 2),
                    ),
                    onSelected: settings.enabled
                        ? (_) => setState(
                            () => settings = settings.copyWith(everyDays: days),
                          )
                        : null,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'AT',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            BrutalDialogButton(
              label: settings.time.format(context),
              color: settings.enabled ? kBlue : kWhite,
              onTap: () async {
                if (!settings.enabled) return;
                final picked = await showTimePicker(
                  context: context,
                  initialTime: settings.time,
                );
                if (picked != null) {
                  setState(() => settings = settings.copyWith(time: picked));
                }
              },
            ),
          ],
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
      ),
    ),
  );
}
