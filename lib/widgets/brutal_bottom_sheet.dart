import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/expense/expense_bloc.dart';
import '../bloc/expense/expense_event.dart';
import '../bloc/settings/settings_bloc.dart';
import '../bloc/settings/settings_event.dart';
import '../bloc/settings/settings_state.dart';
import '../theme.dart';
import 'pin_dialog.dart';

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
              border: Border.fromBorderSide(BorderSide(color: kBlack, width: 2)),
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
              child: _ActionCard(
                icon: Icons.edit,
                label: 'EDIT\nBUDGET',
                color: kOrange,
                onTap: () async {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                  final allowed = await PinDialog.verify(context, action: 'EDIT BUDGET');
                  if (allowed) _showEditBudgetDialog();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionCard(
                icon: Icons.person_outline,
                label: 'CHANGE\nNAME',
                color: kPurple,
                onTap: () async {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                  final allowed = await PinDialog.verify(context, action: 'CHANGE NAME');
                  if (allowed) _showEditNameDialog();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionCard(
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
        _SettingsTile(
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
        _SettingsTile(
          icon: Icons.refresh,
          label: 'RESTART ONBOARDING',
          onTap: () {
            HapticFeedback.heavyImpact();
            Navigator.pop(context);
            _confirmResetOnboarding();
          },
        ),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.delete_outline,
          label: 'CLEAR ALL DATA',
          color: kPink,
          onTap: () async {
            HapticFeedback.heavyImpact();
            Navigator.pop(context);
            final allowed = await PinDialog.verify(context, action: 'CLEAR ALL DATA');
            if (allowed) _confirmClearData();
          },
        ),
      ],
    );
  }

  void _showEditBudgetDialog() {
    final controller =
        TextEditingController(text: _settingsState.budget.toInt().toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kWhite,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: kBlack, width: 3),
        ),
        title: const Text(
          'EDIT BUDGET',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        content: Container(
          decoration: const BoxDecoration(
            color: kBg,
            border: Border.fromBorderSide(BorderSide(color: kBlack, width: 2)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
            decoration: const InputDecoration(
              prefixText: '\$ ',
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
          _DialogButton(
            label: 'CANCEL',
            color: kWhite,
            onTap: () => Navigator.pop(context),
          ),
          _DialogButton(
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
      builder: (context) => AlertDialog(
        backgroundColor: kWhite,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: kBlack, width: 3),
        ),
        title: const Text(
          'CHANGE NAME',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        content: Container(
          decoration: const BoxDecoration(
            color: kBg,
            border: Border.fromBorderSide(BorderSide(color: kBlack, width: 2)),
          ),
          child: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: 'YOUR NAME',
              hintStyle: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        actions: [
          _DialogButton(
            label: 'CANCEL',
            color: kWhite,
            onTap: () => Navigator.pop(context),
          ),
          _DialogButton(
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
      builder: (context) => AlertDialog(
        backgroundColor: kWhite,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: kBlack, width: 3),
        ),
        title: const Text(
          'LEDGER',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A neo brutalism expense tracker.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          _DialogButton(
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

  void _confirmResetOnboarding() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kWhite,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: kBlack, width: 3),
        ),
        title: const Text(
          'RESTART ONBOARDING?',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
        ),
        content: const Text(
          'This will reset your preferences and show the onboarding flow again.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          _DialogButton(
            label: 'CANCEL',
            color: kWhite,
            onTap: () => Navigator.pop(context),
          ),
          _DialogButton(
            label: 'RESET',
            color: kOrange,
            onTap: () async {
              HapticFeedback.heavyImpact();
              _settings.add(const OnboardingReset());
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _confirmClearData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kWhite,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: kBlack, width: 3),
        ),
        title: const Text(
          'CLEAR ALL DATA?',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            color: kPink,
          ),
        ),
        content: const Text(
          'This will delete all your expenses. This cannot be undone.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          _DialogButton(
            label: 'CANCEL',
            color: kWhite,
            onTap: () => Navigator.pop(context),
          ),
          _DialogButton(
            label: 'DELETE ALL',
            color: kPink,
            onTap: () async {
              HapticFeedback.heavyImpact();
              _expenses.add(const AllExpensesCleared());
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        padding: const EdgeInsets.symmetric(vertical: 16),
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        decoration: BoxDecoration(
          color: _isPressed ? widget.color : kWhite,
          border: Border.all(color: kBlack, width: 2),
          boxShadow: _isPressed
              ? []
              : const [BoxShadow(offset: Offset(2, 2), color: kBlack)],
        ),
        child: Column(
          children: [
            Icon(
              widget.icon,
              size: 24,
              color: _isPressed ? kWhite : kBlack,
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: _isPressed ? kWhite : kBlack,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? kBlack;
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        decoration: BoxDecoration(
          color: _isPressed ? color : kBg,
          border: Border.all(color: kBlack, width: 2),
          boxShadow: _isPressed
              ? []
              : const [BoxShadow(offset: Offset(2, 2), color: kBlack)],
        ),
        child: Row(
          children: [
            Icon(
              widget.icon,
              size: 18,
              color: _isPressed ? kWhite : kBlack,
            ),
            const SizedBox(width: 12),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: _isPressed ? kWhite : kBlack,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: _isPressed ? kWhite : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_DialogButton> createState() => _DialogButtonState();
}

class _DialogButtonState extends State<_DialogButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _isPressed ? widget.color : kWhite,
          border: Border.all(color: kBlack, width: 2),
          boxShadow: _isPressed
              ? []
              : const [BoxShadow(offset: Offset(2, 2), color: kBlack)],
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: _isPressed ? kWhite : kBlack,
          ),
        ),
      ),
    );
  }
}
