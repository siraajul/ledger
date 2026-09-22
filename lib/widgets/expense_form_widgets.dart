import 'package:flutter/material.dart';

import '../theme.dart';
import 'brutal_widgets.dart';

class FormLabel extends StatelessWidget {
  final String text;
  final Color color;
  const FormLabel(this.text, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        border: const Border.fromBorderSide(
          BorderSide(color: kBlack, width: 2),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class PressIconButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const PressIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<PressIconButton> createState() => _IconButtonState();
}

class _IconButtonState extends State<PressIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return BrutalTap(
      onTap: widget.onTap,
      label: widget.label,
      onPressedChanged: (pressed) => setState(() => _isPressed = pressed),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: kWhite,
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

class SaveButton extends StatefulWidget {
  final VoidCallback onTap;
  const SaveButton({super.key, required this.onTap});

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return BrutalTap(
      onTap: widget.onTap,
      onPressedChanged: (pressed) => setState(() => _isPressed = pressed),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: kGreen,
          border: Border.all(color: kBlack, width: 2),
          boxShadow: _isPressed
              ? []
              : const [BoxShadow(offset: Offset(2, 2), color: kBlack)],
        ),
        child: const Text(
          'SAVE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class CategoryChip extends StatefulWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return BrutalTap(
      onTap: widget.onTap,
      selected: widget.isSelected,
      onPressedChanged: (pressed) => setState(() => _isPressed = pressed),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: widget.isSelected ? kBlack : kWhite,
          border: Border.all(color: kBlack, width: 2),
          boxShadow: _isPressed || widget.isSelected
              ? []
              : const [BoxShadow(offset: Offset(2, 2), color: kBlack)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              widget.label.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: widget.isSelected ? kYellow : kBlack,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BrutalActionButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const BrutalActionButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<BrutalActionButton> createState() => _BrutalActionButtonState();
}

class _BrutalActionButtonState extends State<BrutalActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return BrutalTap(
      onTap: widget.onTap,
      onPressedChanged: (pressed) => setState(() => _isPressed = pressed),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: widget.color,
          border: Border.all(color: kBlack, width: 3),
          boxShadow: _isPressed
              ? []
              : const [BoxShadow(offset: Offset(4, 4), color: kBlack)],
        ),
        child: Center(
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
