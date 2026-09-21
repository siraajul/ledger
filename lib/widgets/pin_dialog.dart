import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';

class PinDialog extends StatefulWidget {
  final String title;
  final String confirmLabel;
  final VoidCallback onConfirmed;

  const PinDialog({
    super.key,
    required this.title,
    required this.confirmLabel,
    required this.onConfirmed,
  });

  static Future<bool> verify(
    BuildContext context, {
    String action = 'PERFORM THIS ACTION',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('pin_code');

    if (savedPin == null || savedPin.isEmpty) return true;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PinDialog(
        title: 'ENTER PIN',
        confirmLabel: 'CONFIRM',
        onConfirmed: () => Navigator.pop(context, true),
      ),
    );

    return confirmed == true;
  }

  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _error;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    HapticFeedback.selectionClick();
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('pin_code') ?? '';
    if (_controller.text == savedPin) {
      HapticFeedback.lightImpact();
      widget.onConfirmed();
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _error = 'WRONG PIN';
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kWhite,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: kBlack, width: 3),
      ),
      title: Text(
        widget.title,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
      ),
      // Scrollable: the soft keyboard shrinks the dialog, and the fields plus
      // the error line must not overflow what's left.
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: kBg,
                border: Border.fromBorderSide(
                  BorderSide(color: kBlack, width: 2),
                ),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 12,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '• • • •',
                  hintStyle: TextStyle(
                    fontSize: 28,
                    color: Colors.grey[300],
                    letterSpacing: 12,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                onSubmitted: (_) => _confirm(),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: kPink,
                  letterSpacing: 1,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        _PinDialogButton(
          label: 'CANCEL',
          color: kWhite,
          onTap: () => Navigator.pop(context),
        ),
        _PinDialogButton(
          label: widget.confirmLabel,
          color: kGreen,
          onTap: _confirm,
        ),
      ],
    );
  }
}

class SetPinDialog extends StatefulWidget {
  final VoidCallback? onPinSet;
  final VoidCallback? onPinRemoved;

  const SetPinDialog({super.key, this.onPinSet, this.onPinRemoved});

  @override
  State<SetPinDialog> createState() => _SetPinDialogState();
}

class _SetPinDialogState extends State<SetPinDialog> {
  final _controller = TextEditingController();
  final _confirmController = TextEditingController();
  final _focusNode = FocusNode();
  String? _error;
  bool _hasExistingPin = false;

  @override
  void initState() {
    super.initState();
    _loadExistingPin();
    _focusNode.requestFocus();
  }

  Future<void> _loadExistingPin() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString('pin_code');
    setState(() => _hasExistingPin = pin != null && pin.isNotEmpty);
  }

  @override
  void dispose() {
    _controller.dispose();
    _confirmController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _savePin() async {
    HapticFeedback.selectionClick();
    final pin = _controller.text.trim();
    final confirm = _confirmController.text.trim();

    if (pin.length < 4) {
      setState(() => _error = 'MIN 4 DIGITS');
      return;
    }
    if (pin != confirm) {
      setState(() => _error = 'PINS DON\'T MATCH');
      _confirmController.clear();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pin_code', pin);
    HapticFeedback.heavyImpact();
    widget.onPinSet?.call();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _removePin() async {
    HapticFeedback.heavyImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pin_code');
    widget.onPinRemoved?.call();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kWhite,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: kBlack, width: 3),
      ),
      title: Text(
        _hasExistingPin ? 'CHANGE PIN' : 'SET PIN',
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: kBg,
                border: Border.fromBorderSide(
                  BorderSide(color: kBlack, width: 2),
                ),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 10,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '• • • •',
                  hintStyle: TextStyle(
                    fontSize: 24,
                    color: Colors.grey[300],
                    letterSpacing: 10,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: const BoxDecoration(
                color: kBg,
                border: Border.fromBorderSide(
                  BorderSide(color: kBlack, width: 2),
                ),
              ),
              child: TextField(
                controller: _confirmController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 10,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'CONFIRM',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[300],
                    letterSpacing: 4,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                ),
                onSubmitted: (_) => _savePin(),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: kPink,
                  letterSpacing: 1,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (_hasExistingPin)
          _PinDialogButton(
            label: 'REMOVE PIN',
            color: kPink,
            onTap: _removePin,
          ),
        _PinDialogButton(
          label: 'CANCEL',
          color: kWhite,
          onTap: () => Navigator.pop(context),
        ),
        _PinDialogButton(label: 'SAVE', color: kGreen, onTap: _savePin),
      ],
    );
  }
}

class _PinDialogButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PinDialogButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_PinDialogButton> createState() => _PinDialogButtonState();
}

class _PinDialogButtonState extends State<_PinDialogButton> {
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
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
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
