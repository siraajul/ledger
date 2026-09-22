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

class _BudgetBarState extends State<BudgetBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void didUpdateWidget(BudgetBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.spent != widget.spent) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 14,
              width: constraints.maxWidth,
              decoration: const BoxDecoration(
                color: kWhite,
                border: Border.fromBorderSide(
                  BorderSide(color: kBlack, width: 2),
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ScaleTransition(
                  scale: MediaQuery.disableAnimationsOf(context)
                      ? kAlwaysCompleteAnimation
                      : Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                  child: Container(
                    height: 14,
                    width: constraints.maxWidth * ratio,
                    color: barColor,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
