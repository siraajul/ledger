import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

class BrutalButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final Color color;
  final bool isSelected;
  final IconData? icon;

  const BrutalButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.color = kYellow,
    this.isSelected = false,
    this.icon,
  });

  @override
  State<BrutalButton> createState() => _BrutalButtonState();
}

class _BrutalButtonState extends State<BrutalButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _downAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
    _downAnimation = Tween<double>(begin: 0, end: 4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _downAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _isPressed ? _downAnimation.value : 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: widget.isSelected ? kBlack : widget.color,
                border: Border.all(color: kBlack, width: 3),
                boxShadow: _isPressed
                    ? []
                    : const [BoxShadow(offset: Offset(4, 4), color: kBlack)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon,
                        size: 18,
                        color: widget.isSelected ? kYellow : kBlack),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: widget.isSelected ? kYellow : kBlack,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class BrutalCard extends StatefulWidget {
  final Widget child;
  final Color color;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const BrutalCard({
    super.key,
    required this.child,
    this.color = kWhite,
    this.width,
    this.height,
    this.padding,
    this.onTap,
  });

  @override
  State<BrutalCard> createState() => _BrutalCardState();
}

class _BrutalCardState extends State<BrutalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _downAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
    _downAnimation = Tween<double>(begin: 0, end: 4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null
          ? (_) {
              HapticFeedback.lightImpact();
              setState(() => _isPressed = true);
              _controller.forward();
            }
          : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _isPressed = false);
              _controller.reverse();
              widget.onTap?.call();
            }
          : null,
      onTapCancel: widget.onTap != null
          ? () {
              setState(() => _isPressed = false);
              _controller.reverse();
            }
          : null,
      child: AnimatedBuilder(
        animation: _downAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _isPressed ? _downAnimation.value : 0),
            child: Container(
              width: widget.width,
              height: widget.height,
              padding: widget.padding ?? const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.color,
                border: Border.all(color: kBlack, width: 3),
                boxShadow: _isPressed
                    ? []
                    : const [BoxShadow(offset: Offset(5, 5), color: kBlack)],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

class BrutalIconButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color color;

  const BrutalIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.color = kWhite,
  });

  @override
  State<BrutalIconButton> createState() => _BrutalIconButtonState();
}

class _BrutalIconButtonState extends State<BrutalIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.color,
          border: Border.all(color: kBlack, width: 2),
          boxShadow: _isPressed
              ? []
              : const [BoxShadow(offset: Offset(2, 2), color: kBlack)],
        ),
        child: Icon(widget.icon, size: 18),
      ),
    );
  }
}

class BrutalChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;

  const BrutalChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor = kBlack,
    this.unselectedColor = kWhite,
  });

  @override
  State<BrutalChip> createState() => _BrutalChipState();
}

class _BrutalChipState extends State<BrutalChip>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: widget.isSelected ? widget.selectedColor : widget.unselectedColor,
          border: Border.all(color: kBlack, width: 2),
          boxShadow: _isPressed || widget.isSelected
              ? []
              : const [BoxShadow(offset: Offset(2, 2), color: kBlack)],
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: widget.isSelected ? kYellow : kBlack,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
