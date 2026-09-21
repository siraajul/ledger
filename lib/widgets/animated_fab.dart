import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

class AnimatedFAB extends StatefulWidget {
  final VoidCallback onTap;

  const AnimatedFAB({super.key, required this.onTap});

  @override
  State<AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<AnimatedFAB>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.mediumImpact();
        setState(() => _isPressed = true);
        _pulseController.stop();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _pulseController.repeat(reverse: true);
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _pulseController.repeat(reverse: true);
      },
      child: ScaleTransition(
        scale: _isPressed
            ? const AlwaysStoppedAnimation(0.9)
            : _pulseAnimation,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: kYellow,
            border: Border.all(color: kBlack, width: 3),
            boxShadow: _isPressed
                ? []
                : const [BoxShadow(offset: Offset(4, 4), color: kBlack)],
          ),
          child: const Icon(Icons.add, size: 28, color: kBlack),
        ),
      ),
    );
  }
}
