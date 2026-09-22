import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/settings/settings_bloc.dart';
import '../bloc/settings/settings_event.dart';
import '../theme.dart';

class NamePageContent extends StatefulWidget {
  final VoidCallback onNext;
  final ValueChanged<String>? onNameChanged;
  const NamePageContent({super.key, required this.onNext, this.onNameChanged});

  @override
  State<NamePageContent> createState() => _NamePageContentState();
}

class _NamePageContentState extends State<NamePageContent> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            const Text(
              "WHAT'S\nYOUR\nNAME?",
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: kBlack,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: const BoxDecoration(
                color: kWhite,
                border: Border.fromBorderSide(
                  BorderSide(color: kBlack, width: 3),
                ),
                boxShadow: [BoxShadow(offset: Offset(3, 3), color: kBlack)],
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: kBlack,
                ),
                decoration: InputDecoration(
                  hintText: 'TYPE HERE...',
                  hintStyle: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[300],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                onChanged: (value) {
                  context.read<SettingsBloc>().add(UserNameChanged(value));
                  widget.onNameChanged?.call(value);
                },
              ),
            ),
            const SizedBox(height: 12),
            if (_controller.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: const BoxDecoration(
                  color: kBlue,
                  border: Border.fromBorderSide(
                    BorderSide(color: kBlack, width: 2),
                  ),
                ),
                child: Text(
                  'HEY, ${_controller.text.toUpperCase()}!',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: kBlack,
                    letterSpacing: 1,
                  ),
                ),
              ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class BudgetPageContent extends StatefulWidget {
  final VoidCallback onNext;
  final ValueChanged<double>? onBudgetChanged;
  const BudgetPageContent({
    super.key,
    required this.onNext,
    this.onBudgetChanged,
  });

  @override
  State<BudgetPageContent> createState() => _BudgetPageContentState();
}

class _BudgetPageContentState extends State<BudgetPageContent> {
  final _controller = TextEditingController(text: '2000');
  final List<double> _presets = [500, 1000, 2000, 3000, 5000];
  double _selected = 2000;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            const Text(
              'MONTHLY\nBUDGET?',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: kBlack,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: const BoxDecoration(
                color: kWhite,
                border: Border.fromBorderSide(
                  BorderSide(color: kBlack, width: 3),
                ),
                boxShadow: [BoxShadow(offset: Offset(3, 3), color: kBlack)],
              ),
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: kBlack,
                ),
                decoration: InputDecoration(
                  prefixText: '$kCurrency ',
                  prefixStyle: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  hintText: '0',
                  hintStyle: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey[200],
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                onChanged: (value) {
                  final val = double.tryParse(value) ?? 0;
                  setState(() => _selected = val);
                  widget.onBudgetChanged?.call(val);
                },
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.map((amount) {
                final isSelected = _selected == amount;
                return GestureDetector(
                  onTap: () {
                    _controller.text = amount.toInt().toString();
                    setState(() => _selected = amount);
                    widget.onBudgetChanged?.call(amount.toDouble());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? kBlack : kWhite,
                      border: Border.all(color: kBlack, width: 2),
                      boxShadow: isSelected
                          ? []
                          : const [
                              BoxShadow(offset: Offset(2, 2), color: kBlack),
                            ],
                    ),
                    child: Text(
                      '$kCurrency${amount.toInt()}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? kYellow : kBlack,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
