import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../models/expense.dart';
import '../theme.dart';
import 'brutal_widgets.dart';

class ExpenseCard extends StatefulWidget {
  final Expense expense;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const ExpenseCard({
    super.key,
    required this.expense,
    required this.onDelete,
    required this.onTap,
  });

  @override
  State<ExpenseCard> createState() => _ExpenseCardState();
}

class _ExpenseCardState extends State<ExpenseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ExpenseCategory? get _category {
    try {
      return categories.firstWhere((c) => c.name == widget.expense.category);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = _category;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: BrutalTap(
        onTap: widget.onTap,
        onPressedChanged: (pressed) {
          if (pressed) HapticFeedback.lightImpact();
          setState(() => _isPressed = pressed);
          pressed ? _controller.forward() : _controller.reverse();
        },
        onLongPress: () {
          HapticFeedback.heavyImpact();
          widget.onDelete();
        },
        // Swipe and long-press are invisible to screen readers; name the action.
        semanticActions: {
          const CustomSemanticsAction(label: 'Delete expense'): widget.onDelete,
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          padding: const EdgeInsets.all(14),
          transform: Matrix4.translationValues(0, _isPressed ? 3 : 0, 0),
          decoration: const BoxDecoration(
            color: kWhite,
            border: Border.fromBorderSide(BorderSide(color: kBlack, width: 2)),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _isPressed ? kGreen : kYellow,
                  border: const Border.fromBorderSide(
                    BorderSide(color: kBlack, width: 2),
                  ),
                ),
                child: Center(
                  child: Text(
                    category?.icon ?? '📦',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.expense.title.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.expense.note != null &&
                        widget.expense.note!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.expense.note!,
                        style: const TextStyle(fontSize: 12, color: kMutedText),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '-$kCurrency${widget.expense.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: kBlack,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
