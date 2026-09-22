import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/expense/expense_bloc.dart';
import '../bloc/expense/expense_state.dart';
import '../models/expense.dart';
import '../theme.dart';
import '../widgets/brutal_widgets.dart';
import '../widgets/animations.dart';

class StatsScreen extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const StatsScreen({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final categoryTotals = state.monthlyCategoryTotals;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildBarChart(categoryTotals),
                const SizedBox(height: 20),
                _buildCategoryList(categoryTotals),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return StaggeredAnimation(
      index: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: const BoxDecoration(
              color: kPink,
              border: Border.fromBorderSide(
                BorderSide(color: kBlack, width: 2),
              ),
            ),
            child: Text(
              DateFormat('MMMM yyyy').format(DateTime.now()).toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'STATS',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: kBlack,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(Map<String, double> categoryTotals) {
    if (categoryTotals.isEmpty) {
      return StaggeredAnimation(
        index: 1,
        child: BrutalCard(
          child: Center(
            child: Text(
              'NO DATA YET.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.grey[400],
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      );
    }

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxValue = sortedEntries.first.value;

    return StaggeredAnimation(
      index: 1,
      child: BrutalCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BY CATEGORY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            ...sortedEntries.asMap().entries.map((mapEntry) {
              final index = mapEntry.key;
              final entry = mapEntry.value;
              final category = categories.firstWhere(
                (c) => c.name == entry.key,
                orElse: () => const ExpenseCategory(
                  name: 'Other',
                  icon: '📦',
                  color: 0xFFA8D8EA,
                ),
              );
              final ratio = entry.value / maxValue;

              return StaggeredAnimation(
                index: index + 2,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: kYellow,
                                  border: Border.fromBorderSide(
                                    BorderSide(color: kBlack, width: 2),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    category.icon,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                entry.key.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '-$kCurrency${entry.value.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      AnimatedBar(
                        ratio: ratio,
                        color: Color(category.color),
                        duration: Duration(milliseconds: 600 + (index * 150)),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(Map<String, double> categoryTotals) {
    if (categoryTotals.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = categoryTotals.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return StaggeredAnimation(
      index: sortedEntries.length + 3,
      child: BrutalCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BREAKDOWN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            ...sortedEntries.asMap().entries.map((mapEntry) {
              final index = mapEntry.key;
              final entry = mapEntry.value;
              final category = categories.firstWhere(
                (c) => c.name == entry.key,
                orElse: () => const ExpenseCategory(
                  name: 'Other',
                  icon: '📦',
                  color: 0xFFA8D8EA,
                ),
              );
              final percentage = (entry.value / total * 100).toStringAsFixed(0);

              return StaggeredAnimation(
                index: index + sortedEntries.length + 4,
                child: _CategoryRow(
                  icon: category.icon,
                  color: Color(category.color),
                  name: entry.key,
                  amount: entry.value,
                  percentage: percentage,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatefulWidget {
  final String icon;
  final Color color;
  final String name;
  final double amount;
  final String percentage;

  const _CategoryRow({
    required this.icon,
    required this.color,
    required this.name,
    required this.amount,
    required this.percentage,
  });

  @override
  State<_CategoryRow> createState() => _CategoryRowState();
}

class _CategoryRowState extends State<_CategoryRow> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        decoration: const BoxDecoration(
          color: kBg,
          border: Border.fromBorderSide(BorderSide(color: kBlack, width: 2)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: widget.color,
                border: const Border.fromBorderSide(
                  BorderSide(color: kBlack, width: 2),
                ),
              ),
              child: Center(
                child: Text(widget.icon, style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: const BoxDecoration(
                color: kWhite,
                border: Border.fromBorderSide(
                  BorderSide(color: kBlack, width: 2),
                ),
              ),
              child: Text(
                '${widget.percentage}%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '-$kCurrency${widget.amount.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
