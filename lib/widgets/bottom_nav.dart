import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

class AnimatedBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onMenuTap;
  final VoidCallback onOptionsTap;

  const AnimatedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onMenuTap,
    required this.onOptionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kWhite,
        border: Border(top: BorderSide(color: kBlack, width: 3)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavIconButton(
                icon: Icons.menu,
                isSelected: currentIndex == -1,
                onTap: onMenuTap,
              ),
              const SizedBox(width: 24),
              _NavItem(
                icon: Icons.home_rounded,
                label: 'HOME',
                isSelected: currentIndex == 0,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(0);
                },
              ),
              const SizedBox(width: 24),
              _NavItem(
                icon: Icons.bar_chart_rounded,
                label: 'STATS',
                isSelected: currentIndex == 1,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(1);
                },
              ),
              const SizedBox(width: 24),
              _NavIconButton(
                icon: Icons.tune,
                isSelected: false,
                onTap: onOptionsTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIconButton extends StatefulWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavIconButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavIconButton> createState() => _NavIconButtonState();
}

class _NavIconButtonState extends State<_NavIconButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _scaleController.forward();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        _scaleController.reverse();
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        _scaleController.reverse();
        setState(() => _isPressed = false);
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _isPressed ? kBg : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            widget.icon,
            size: 24,
            color: kBlack,
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _scaleController.forward();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        _scaleController.reverse();
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        _scaleController.reverse();
        setState(() => _isPressed = false);
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: widget.isSelected
              ? const BoxDecoration(
                  color: kBlack,
                  border: Border.fromBorderSide(
                      BorderSide(color: kBlack, width: 2)),
                )
              : BoxDecoration(
                  color: _isPressed ? kBg : Colors.transparent,
                ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: widget.isSelected ? kYellow : kBlack,
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: widget.isSelected ? kYellow : kBlack,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
