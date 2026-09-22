import 'package:flutter/material.dart';

import '../theme.dart';

/// Budget progress strip shown under the summary card when the monthly
/// budget is set and the active filter is MONTH. Drives the only
/// feedback a user gets for the budget feature: how much is left, or
/// how far over they've drifted.
class BudgetBar extends StatefulWidget {
  final double spent;
  final double budget;
  final double remaining;
  final bool overBudget;

  const BudgetBar({
    super.key,
    required this.spent,
    required this.budget,
    required this.remaining,
    required this.overBudget,
  });

  @override
  State<BudgetBar> createState() => _BudgetBarState();
}

class _BudgetBarState extends State<BudgetBar> {
  @override
  Widget build(BuildContext context) {
    final ratio = (widget.spent / widget.budget).clamp(0.0, 1.0);
    final barColor = widget.overBudget ? kPink : kGreen;
    final label = widget.overBudget
        ? 'OVER BY $kCurrency${(-widget.remaining).toStringAsFixed(0)}'
        : '$kCurrency${widget.remaining.toStringAsFixed(0)} LEFT';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'BUDGET',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: widget.overBudget ? kDangerText : kBlack,
              ),
            ),
            const Spacer(),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: widget.overBudget ? kDangerText : kBlack,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 14,
          decoration: const BoxDecoration(
            color: kWhite,
            border: Border.fromBorderSide(BorderSide(color: kBlack, width: 2)),
          ),
          // Fills from the left and retargets from wherever it is,
          // instead of regrowing from zero on every change.
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: ratio),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 250),
            curve: kEaseOut,
            builder: (context, value, _) => FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: ColoredBox(color: barColor),
            ),
          ),
        ),
      ],
    );
  }
}
