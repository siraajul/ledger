import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import 'brutal_widgets.dart';

class AnimatedFAB extends StatefulWidget {
  final VoidCallback onTap;

  const AnimatedFAB({super.key, required this.onTap});

  @override
  State<AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<AnimatedFAB> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return BrutalTap(
      onTap: widget.onTap,
      label: 'Add expense',
      onPressedChanged: (pressed) {
        if (pressed) HapticFeedback.mediumImpact();
        setState(() => _isPressed = pressed);
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 100),
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
