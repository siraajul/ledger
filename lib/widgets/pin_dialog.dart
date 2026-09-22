import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';
import 'brutal_widgets.dart';

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
    if (!context.mounted) return false;

    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PinDialog(
        title: 'ENTER PIN',
        confirmLabel: 'CONFIRM',
        onConfirmed: () => navigator.pop(true),
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
        _error = 'WRONG PIN. TRY AGAIN.';
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return brutalDialog(
      title: widget.title,
      titleStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
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
              Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: kDangerText,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ],
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
    return brutalDialog(
      title: _hasExistingPin ? 'CHANGE PIN' : 'SET PIN',
      titleStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
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
              Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: kDangerText,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (_hasExistingPin)
          BrutalDialogButton(
            fillOnPress: true,
            label: 'REMOVE PIN',
            color: kPink,
            onTap: _removePin,
          ),
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
          onTap: _savePin,
        ),
      ],
    );
  }
}
