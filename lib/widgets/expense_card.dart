import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/expense.dart';
import '../theme.dart';

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

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onLongPressStart: (_) {
        HapticFeedback.heavyImpact();
      },
      onLongPress: widget.onDelete,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        margin: const EdgeInsets.only(bottom: 8),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.expense.note != null &&
                      widget.expense.note!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.expense.note!,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                fontSize: _isPressed ? 17 : 15,
                fontWeight: FontWeight.w900,
                color: _isPressed ? kPink : kBlack,
              ),
              child: Text(
                '-$kCurrency${widget.expense.amount.toStringAsFixed(2)}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
