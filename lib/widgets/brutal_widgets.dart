import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

/// Tap target for the hand-built brutal controls: button semantics,
/// keyboard focus with a visible ring, Enter/Space activation.
/// [onPressedChanged] drives each control's own press visuals.
class BrutalTap extends StatefulWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onPressedChanged;
  final bool? selected;

  /// Accessible name for icon-only controls; text children name the rest.
  final String? label;
  final Map<CustomSemanticsAction, VoidCallback>? semanticActions;
  final Widget child;

  const BrutalTap({
    super.key,
    required this.onTap,
    required this.child,
    this.onLongPress,
    this.onPressedChanged,
    this.selected,
    this.label,
    this.semanticActions,
  });

  @override
  State<BrutalTap> createState() => _BrutalTapState();
}

class _BrutalTapState extends State<BrutalTap> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final onTap = widget.onTap;
    final press = onTap == null ? null : widget.onPressedChanged;
    return MergeSemantics(
      child: Semantics(
        button: true,
        enabled: onTap != null,
        selected: widget.selected,
        label: widget.label,
        customSemanticsActions: widget.semanticActions,
        child: FocusableActionDetector(
          enabled: onTap != null,
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                onTap?.call();
                return null;
              },
            ),
          },
          onShowFocusHighlight: (v) => setState(() => _focused = v),
          child: GestureDetector(
            onTapDown: press == null ? null : (_) => press(true),
            onTapUp: press == null ? null : (_) => press(false),
            onTapCancel: press == null ? null : () => press(false),
            onTap: onTap,
            onLongPress: widget.onLongPress,
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              // Blue over the black border: 9:1 against it, so the ring
              // reads on every fill.
              decoration: _focused
                  ? const BoxDecoration(
                      border: Border.fromBorderSide(
                        BorderSide(color: kBlue, width: 4),
                      ),
                    )
                  : const BoxDecoration(),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

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
    _downAnimation = Tween<double>(
      begin: 0,
      end: 4,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BrutalTap(
      onTap: widget.onPressed,
      selected: widget.isSelected,
      onPressedChanged: (pressed) {
        if (pressed) HapticFeedback.lightImpact();
        setState(() => _isPressed = pressed);
        pressed ? _controller.forward() : _controller.reverse();
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
                    Icon(
                      widget.icon,
                      size: 18,
                      color: widget.isSelected ? kYellow : kBlack,
                    ),
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
    _downAnimation = Tween<double>(
      begin: 0,
      end: 4,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
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

/// Small bordered button used in dialog action rows.
class BrutalDialogButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  /// When true the button stays white and only shows [color] while pressed.
  final bool fillOnPress;

  const BrutalDialogButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
    this.fillOnPress = false,
  });

  @override
  State<BrutalDialogButton> createState() => _BrutalDialogButtonState();
}

class _BrutalDialogButtonState extends State<BrutalDialogButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final fill = widget.fillOnPress && !_isPressed ? kWhite : widget.color;
    final text = widget.fillOnPress && _isPressed ? kWhite : kBlack;
    return BrutalTap(
      onTap: widget.onTap,
      onPressedChanged: (pressed) => setState(() => _isPressed = pressed),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: fill,
          border: Border.all(color: kBlack, width: 2),
          boxShadow: _isPressed
              ? []
              : const [BoxShadow(offset: Offset(2, 2), color: kBlack)],
        ),
        child: Text(
          widget.label,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: text,
          ),
        ),
      ),
    );
  }
}

/// The app's dialog frame: white, square, thick black border.
AlertDialog brutalDialog({
  required String title,
  TextStyle titleStyle = const TextStyle(fontWeight: FontWeight.w900),
  Widget? content,
  required List<Widget> actions,
}) {
  return AlertDialog(
    backgroundColor: kWhite,
    shape: const RoundedRectangleBorder(
      side: BorderSide(color: kBlack, width: 3),
    ),
    title: Text(title, style: titleStyle),
    content: content,
    actions: actions,
  );
}

/// CANCEL / [confirmLabel] dialog. Resolves true only on confirm.
Future<bool> showBrutalConfirm(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  required Color color,
  String? message,
  TextStyle titleStyle = const TextStyle(fontWeight: FontWeight.w900),
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => brutalDialog(
      title: title,
      titleStyle: titleStyle,
      content: message == null
          ? null
          : Text(message, style: const TextStyle(fontSize: 13)),
      actions: [
        BrutalDialogButton(
          label: 'CANCEL',
          color: kWhite,
          onTap: () => Navigator.pop(context, false),
        ),
        BrutalDialogButton(
          label: confirmLabel,
          color: color,
          onTap: () {
            HapticFeedback.heavyImpact();
            Navigator.pop(context, true);
          },
        ),
      ],
    ),
  );
  return confirmed == true;
}
