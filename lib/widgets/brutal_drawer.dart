import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/settings/settings_bloc.dart';
import '../bloc/settings/settings_state.dart';
import '../services/auth.dart';
import '../theme.dart';

/// Up to two initials. Splitting on runs of whitespace matters: a trailing
/// space (iOS autocorrect adds one) used to yield an empty word, and `''[0]`
/// threw while building the drawer, which renders blank in release builds.
String drawerInitials(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  if (words.isEmpty) return '?';
  return words.map((w) => w[0]).take(2).join().toUpperCase();
}

class BrutalDrawer extends StatelessWidget {
  final VoidCallback? onNavigateToHome;
  final VoidCallback? onNavigateToStats;
  final VoidCallback? onNavigateToBudget;

  const BrutalDrawer({
    super.key,
    this.onNavigateToHome,
    this.onNavigateToStats,
    this.onNavigateToBudget,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: kBg,
      child: SafeArea(
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settings) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(settings.userName),
                const SizedBox(height: 32),
                _buildMenuItem(
                  icon: Icons.home_rounded,
                  label: 'HOME',
                  color: kBlue,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                    onNavigateToHome?.call();
                  },
                ),
                const SizedBox(height: 8),
                _buildMenuItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'STATS',
                  color: kPink,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                    onNavigateToStats?.call();
                  },
                ),
                const SizedBox(height: 8),
                _buildMenuItem(
                  icon: Icons.savings_outlined,
                  label: 'BUDGET',
                  color: kGreen,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                    onNavigateToBudget?.call();
                  },
                ),
                const SizedBox(height: 8),
                _buildMenuItem(
                  icon: Icons.logout_rounded,
                  label: 'SIGN OUT',
                  color: kOrange,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                    signOut();
                  },
                ),
                const Spacer(),
                _buildBudgetCard(settings.budget),
                const SizedBox(height: 16),
                _buildVersionInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String userName) {
    final initials = drawerInitials(userName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: kYellow,
            border: Border.fromBorderSide(BorderSide(color: kBlack, width: 3)),
            boxShadow: [BoxShadow(offset: Offset(3, 3), color: kBlack)],
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          userName.isNotEmpty ? userName.toUpperCase() : 'GUEST',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: const BoxDecoration(
            color: kGreen,
            border: Border.fromBorderSide(BorderSide(color: kBlack, width: 2)),
          ),
          child: const Text(
            'ACTIVE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return _MenuItemTile(icon: icon, label: label, color: color, onTap: onTap);
  }

  Widget _buildBudgetCard(double budget) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: kWhite,
        border: Border.fromBorderSide(BorderSide(color: kBlack, width: 2)),
        boxShadow: [BoxShadow(offset: Offset(3, 3), color: kBlack)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MONTHLY BUDGET',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$kCurrency${budget.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return const Text(
      'LEDGER v1.0',
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
        letterSpacing: 1,
      ),
    );
  }
}

class _MenuItemTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuItemTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_MenuItemTile> createState() => _MenuItemTileState();
}

class _MenuItemTileState extends State<_MenuItemTile> {
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
        duration: kPress,
        curve: kEaseOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        decoration: BoxDecoration(
          color: _isPressed ? widget.color : kWhite,
          border: Border.all(color: kBlack, width: 2),
          boxShadow: _isPressed
              ? []
              : const [BoxShadow(offset: Offset(2, 2), color: kBlack)],
        ),
        child: Row(
          children: [
            Icon(widget.icon, size: 20, color: _isPressed ? kWhite : kBlack),
            const SizedBox(width: 12),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: _isPressed ? kWhite : kBlack,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: _isPressed ? kWhite : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
