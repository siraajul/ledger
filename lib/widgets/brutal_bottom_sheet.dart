import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/expense/expense_bloc.dart';
import '../bloc/expense/expense_event.dart';
import '../bloc/settings/settings_bloc.dart';
import '../bloc/settings/settings_event.dart';
import '../bloc/settings/settings_state.dart';
import '../theme.dart';
import 'brutal_widgets.dart';
import 'pin_dialog.dart';
import 'reminder_dialog.dart';
import 'settings_tiles.dart';

class BrutalBottomSheet extends StatefulWidget {
  final ScrollController? scrollController;

  const BrutalBottomSheet({super.key, this.scrollController});

  @override
  State<BrutalBottomSheet> createState() => _BrutalBottomSheetState();
}

class _BrutalBottomSheetState extends State<BrutalBottomSheet> {
  /// Captured up-front: the dialogs below outlive this sheet's own route.
  late final SettingsBloc _settings = context.read<SettingsBloc>();
  late final ExpenseBloc _expenses = context.read<ExpenseBloc>();

  SettingsState get _settingsState => _settings.state;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kBg,
        border: Border(top: BorderSide(color: kBlack, width: 3)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHandle(),
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 20),
              _buildQuickActions(),
              const SizedBox(height: 16),
              _buildSettingsSection(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          border: Border.all(color: kBlack, width: 1),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'OPTIONS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: kWhite,
              border: Border.fromBorderSide(
                BorderSide(color: kBlack, width: 2),
              ),
              boxShadow: [BoxShadow(offset: Offset(2, 2), color: kBlack)],
            ),
            child: const Icon(Icons.close, size: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QUICK ACTIONS',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ActionCard(
                icon: Icons.edit,
                label: 'EDIT\nBUDGET',
                color: kOrange,
                onTap: () async {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                  final allowed = await PinDialog.verify(
                    context,
                    action: 'EDIT BUDGET',
                  );
                  if (allowed) _showEditBudgetDialog();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ActionCard(
                icon: Icons.person_outline,
                label: 'CHANGE\nNAME',
                color: kPurple,
                onTap: () async {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                  final allowed = await PinDialog.verify(
                    context,
                    action: 'CHANGE NAME',
                  );
                  if (allowed) _showEditNameDialog();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ActionCard(
                icon: Icons.info_outline,
                label: 'ABOUT\nAPP',
                color: kBlue,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                  _showAboutDialog();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SETTINGS',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        SettingsTile(
          icon: Icons.lock_outline,
          label: 'SET / CHANGE PIN',
          color: kPurple,
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.pop(context);
            _showSetPinDialog();
          },
        ),
        const SizedBox(height: 8),
        SettingsTile(
          icon: Icons.notifications_none_rounded,
          label: 'REMINDER',
          color: kGreen,
          onTap: () {
            HapticFeedback.mediumImpact();
            // The sheet unmounts once popped; the navigator's context doesn't.
            final navigatorContext = Navigator.of(context).context;
            Navigator.pop(context);
            showReminderDialog(navigatorContext);
          },
        ),
        const SizedBox(height: 8),
        SettingsTile(
          icon: Icons.refresh,
          label: 'RESTART ONBOARDING',
          onTap: () {
            HapticFeedback.heavyImpact();
            Navigator.pop(context);
            _confirmResetOnboarding();
          },
        ),
        const SizedBox(height: 8),
        SettingsTile(
          icon: Icons.delete_outline,
          label: 'CLEAR ALL DATA',
          color: kPink,
          onTap: () async {
            HapticFeedback.heavyImpact();
            Navigator.pop(context);
            final allowed = await PinDialog.verify(
              context,
              action: 'CLEAR ALL DATA',
            );
            if (allowed) _confirmClearData();
          },
        ),
      ],
    );
  }

  void _showEditBudgetDialog() {
    final controller = TextEditingController(
      text: _settingsState.budget.toInt().toString(),
    );
    showDialog(
      context: context,
      builder: (context) => brutalDialog(
        title: 'EDIT BUDGET',
        titleStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        content: Container(
          decoration: const BoxDecoration(
            color: kBg,
            border: Border.fromBorderSide(BorderSide(color: kBlack, width: 2)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            decoration: const InputDecoration(
              prefixText: '$kCurrency ',
              prefixStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.grey,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
        actions: [
          BrutalDialogButton(
            fillOnPress: true,
            label: 'CANCEL',
            color: kWhite,
            onTap: () => Navigator.pop(context),
          ),
          BrutalDialogButton(
            fillOnPress: true,
            label: 'SAVE',
            color: kGreen,
            onTap: () async {
              HapticFeedback.heavyImpact();
              final value = double.tryParse(controller.text) ?? 0;
              _settings.add(BudgetChanged(value));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog() {
    final controller = TextEditingController(text: _settingsState.userName);
    showDialog(
      context: context,
      builder: (context) => brutalDialog(
        title: 'CHANGE NAME',
        titleStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        content: Container(
          decoration: const BoxDecoration(
            color: kBg,
            border: Border.fromBorderSide(BorderSide(color: kBlack, width: 2)),
          ),
          child: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              hintText: 'YOUR NAME',
              hintStyle: TextStyle(color: Colors.grey[300], fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        actions: [
          BrutalDialogButton(
            fillOnPress: true,
            label: 'CANCEL',
            color: kWhite,
            onTap: () => Navigator.pop(context),
          ),
          BrutalDialogButton(
            fillOnPress: true,
            label: 'SAVE',
            color: kGreen,
            onTap: () async {
              HapticFeedback.heavyImpact();
              _settings.add(UserNameChanged(controller.text));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => brutalDialog(
        title: 'LEDGER',
        titleStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Synced to your Google account.\nSame expenses and settings on every device.',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            SizedBox(height: 12),
            Text(
              'Stored in Firebase (Google Cloud), readable only\nwhen signed in as you. Works offline, syncs later.',
              style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
            ),
            SizedBox(height: 12),
            Text(
              'The PIN stays on this device. It is a convenience\nlock, not encryption, and does not sync.',
              style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
            ),
            SizedBox(height: 16),
            Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          BrutalDialogButton(
            fillOnPress: true,
            label: 'CLOSE',
            color: kBlue,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showSetPinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SetPinDialog(),
    );
  }

  Future<void> _confirmResetOnboarding() async {
    final confirmed = await showBrutalConfirm(
      context,
      title: 'RESTART ONBOARDING?',
      titleStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
      message: 'This will reset your preferences and show the onboarding flow again.',
      confirmLabel: 'RESET',
      color: kOrange,
    );
    if (confirmed) _settings.add(const OnboardingReset());
  }

  Future<void> _confirmClearData() async {
    final confirmed = await showBrutalConfirm(
      context,
      title: 'CLEAR ALL DATA?',
      titleStyle: const TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 14,
        color: kPink,
      ),
      message: 'This will delete all your expenses. This cannot be undone.',
      confirmLabel: 'DELETE ALL',
      color: kPink,
    );
    if (confirmed) _expenses.add(const AllExpensesCleared());
  }
}
