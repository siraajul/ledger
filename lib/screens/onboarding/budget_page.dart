import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../../bloc/settings/settings_event.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final _controller = TextEditingController(text: '2000');
  double _selectedAmount = 2000;

  final List<double> _presets = [500, 1000, 1500, 2000, 3000, 5000];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final value = double.tryParse(_controller.text) ?? 0;
      setState(() => _selectedAmount = value);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveBudget() {
    context.read<SettingsBloc>().add(BudgetChanged(_selectedAmount));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(flex: 2),
            const Text(
              'Set a monthly\nbudget.',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "We'll help you stay on track.",
              style: TextStyle(
                fontSize: 17,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 40),
            // Amount input
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
                letterSpacing: -2,
              ),
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[200],
                  letterSpacing: -2,
                ),
                border: InputBorder.none,
                hintText: '0',
                hintStyle: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[100],
                  letterSpacing: -2,
                ),
              ),
              onChanged: (value) {
                _saveBudget();
              },
            ),
            const SizedBox(height: 8),
            Text(
              _getMonthlyBreakdown(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 32),
            // Preset chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.map((amount) {
                final isSelected = _selectedAmount == amount;
                return GestureDetector(
                  onTap: () {
                    _controller.text = amount.toInt().toString();
                    _saveBudget();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1A1A2E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1A1A2E)
                            : Colors.grey[200]!,
                      ),
                    ),
                    child: Text(
                      '\$${amount.toInt()}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  String _getMonthlyBreakdown() {
    if (_selectedAmount <= 0) return '';
    final daily = (_selectedAmount / 30).toStringAsFixed(0);
    final weekly = (_selectedAmount / 4).toStringAsFixed(0);
    return '≈ \$$daily/day  •  ≈ \$$weekly/week';
  }
}
