import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/expense/expense_bloc.dart';
import '../bloc/expense/expense_event.dart';
import '../models/expense.dart';
import '../theme.dart';
import '../widgets/pin_dialog.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;

  const AddExpenseScreen({super.key, this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _isEditing = true;
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount.toString();
      _noteController.text = widget.expense!.note ?? '';
      _selectedCategory = widget.expense!.category;
      _selectedDate = widget.expense!.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    HapticFeedback.lightImpact();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      HapticFeedback.selectionClick();
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      if (_isEditing) {
        final allowed = await PinDialog.verify(context, action: 'EDIT EXPENSE');
        if (!allowed) return;
      }
      HapticFeedback.heavyImpact();
      final expense = Expense(
        id: _isEditing ? widget.expense!.id : const Uuid().v4(),
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        date: _selectedDate,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );

      if (!mounted) return;
      context.read<ExpenseBloc>().add(
            _isEditing ? ExpenseUpdated(expense) : ExpenseAdded(expense),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'EXPENSE UPDATED' : 'EXPENSE ADDED',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            backgroundColor: kBlack,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              side: BorderSide(color: kBlack, width: 2),
            ),
            duration: const Duration(seconds: 1),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: kBg,
            border: Border(bottom: BorderSide(color: kBlack, width: 3)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _IconButton(
                    icon: Icons.close,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                  ),
                  const Spacer(),
                  Text(
                    _isEditing ? 'EDIT' : 'NEW EXPENSE',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  _SaveButton(onTap: _saveExpense),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildAmountField(),
            const SizedBox(height: 28),
            _buildTitleField(),
            const SizedBox(height: 28),
            _buildCategorySection(),
            const SizedBox(height: 28),
            _buildDateField(),
            const SizedBox(height: 28),
            _buildNoteField(),
            const SizedBox(height: 40),
            if (_isEditing) _buildDeleteButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('AMOUNT', kOrange),
        const SizedBox(height: 12),
        Container(
          decoration: const BoxDecoration(
            color: kWhite,
            border: Border.fromBorderSide(BorderSide(color: kBlack, width: 3)),
            boxShadow: [BoxShadow(offset: Offset(4, 4), color: kBlack)],
          ),
          child: TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
            ],
            autofocus: !_isEditing,
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w900,
              color: kBlack,
              letterSpacing: -2,
            ),
            decoration: InputDecoration(
              prefixText: '\$ ',
              prefixStyle: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                color: Colors.grey[300],
                letterSpacing: -2,
              ),
              border: InputBorder.none,
              hintText: '0',
              hintStyle: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                color: Colors.grey[100],
                letterSpacing: -2,
              ),
              contentPadding: const EdgeInsets.all(20),
              errorStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: kPink,
                letterSpacing: 1,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'ENTER AMOUNT';
              if (double.tryParse(value) == null) return 'NOT A NUMBER';
              if (double.parse(value) <= 0) return 'MUST BE > 0';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('DESCRIPTION', kBlue),
        const SizedBox(height: 12),
        Container(
          decoration: const BoxDecoration(
            color: kWhite,
            border: Border.fromBorderSide(BorderSide(color: kBlack, width: 3)),
            boxShadow: [BoxShadow(offset: Offset(3, 3), color: kBlack)],
          ),
          child: TextFormField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: kBlack,
            ),
            decoration: InputDecoration(
              hintText: 'WHAT WAS IT FOR?',
              hintStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[300],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              errorStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: kPink,
                letterSpacing: 1,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'REQUIRED';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('CATEGORY', kPink),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final isSelected = _selectedCategory == category.name;
            return _CategoryChip(
              icon: category.icon,
              label: category.name,
              isSelected: isSelected,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = category.name);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('DATE', kPurple),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: kWhite,
              border: Border.fromBorderSide(BorderSide(color: kBlack, width: 3)),
              boxShadow: [BoxShadow(offset: Offset(3, 3), color: kBlack)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, MMM d, yyyy')
                      .format(_selectedDate)
                      .toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Icon(Icons.calendar_today, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('NOTE', kGreen),
        const SizedBox(height: 12),
        Container(
          decoration: const BoxDecoration(
            color: kWhite,
            border: Border.fromBorderSide(BorderSide(color: kBlack, width: 3)),
            boxShadow: [BoxShadow(offset: Offset(3, 3), color: kBlack)],
          ),
          child: TextFormField(
            controller: _noteController,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kBlack,
            ),
            decoration: InputDecoration(
              hintText: 'OPTIONAL',
              hintStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[300],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteButton() {
    return _BrutalActionButton(
      label: 'DELETE EXPENSE',
      color: kPink,
      onTap: () async {
        HapticFeedback.heavyImpact();
        final allowed = await PinDialog.verify(context, action: 'DELETE EXPENSE');
        if (!allowed) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => _ConfirmDialog(
            title: 'DELETE?',
            confirmLabel: 'DELETE',
            confirmColor: kPink,
            onConfirm: () => Navigator.pop(context, true),
            onCancel: () => Navigator.pop(context, false),
          ),
        );
        if (confirmed == true && mounted) {
          context
              .read<ExpenseBloc>()
              .add(ExpenseDeleted(widget.expense!.id));
          Navigator.pop(context);
        }
      },
    );
  }
}

// Reusable widgets

class _Label extends StatelessWidget {
  final String text;
  final Color color;
  const _Label(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        border: const Border.fromBorderSide(BorderSide(color: kBlack, width: 2)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _IconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconButton({required this.icon, required this.onTap});

  @override
  State<_IconButton> createState() => _IconButtonState();
}

class _IconButtonState extends State<_IconButton> {
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: kWhite,
          border: Border.all(color: kBlack, width: 2),
          boxShadow: _isPressed
              ? []
              : const [BoxShadow(offset: Offset(2, 2), color: kBlack)],
        ),
        child: Icon(widget.icon, size: 18),
      ),
    );
  }
}

class _SaveButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SaveButton({required this.onTap});

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: kGreen,
          border: Border.all(color: kBlack, width: 2),
          boxShadow: _isPressed
              ? []
              : const [BoxShadow(offset: Offset(2, 2), color: kBlack)],
        ),
        child: const Text(
          'SAVE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatefulWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip> {
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
          color: widget.isSelected ? kBlack : kWhite,
          border: Border.all(color: kBlack, width: 2),
          boxShadow: _isPressed || widget.isSelected
              ? []
              : const [BoxShadow(offset: Offset(2, 2), color: kBlack)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              widget.label.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: widget.isSelected ? kYellow : kBlack,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrutalActionButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BrutalActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_BrutalActionButton> createState() => _BrutalActionButtonState();
}

class _BrutalActionButtonState extends State<_BrutalActionButton> {
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
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: widget.color,
          border: Border.all(color: kBlack, width: 3),
          boxShadow: _isPressed
              ? []
              : const [BoxShadow(offset: Offset(4, 4), color: kBlack)],
        ),
        child: Center(
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _ConfirmDialog({
    required this.title,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kWhite,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: kBlack, width: 3),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      actions: [
        _DialogButton(
          label: 'CANCEL',
          color: kWhite,
          onTap: onCancel,
        ),
        _DialogButton(
          label: confirmLabel,
          color: confirmColor,
          onTap: onConfirm,
        ),
      ],
    );
  }
}

class _DialogButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_DialogButton> createState() => _DialogButtonState();
}

class _DialogButtonState extends State<_DialogButton> {
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: widget.color,
          border: Border.all(color: kBlack, width: 2),
          boxShadow: _isPressed
              ? []
              : const [BoxShadow(offset: Offset(2, 2), color: kBlack)],
        ),
        child: Text(
          widget.label,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
        ),
      ),
    );
  }
}
