import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/expense/expense_bloc.dart';
import '../bloc/expense/expense_event.dart';
import '../models/expense.dart';
import '../theme.dart';
import '../widgets/brutal_widgets.dart';
import '../widgets/pin_dialog.dart';
import '../widgets/expense_form_widgets.dart';

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
                  PressIconButton(
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
                  SaveButton(onTap: _saveExpense),
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
        FormLabel('AMOUNT', kOrange),
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
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            autofocus: !_isEditing,
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w900,
              color: kBlack,
              letterSpacing: -2,
            ),
            decoration: InputDecoration(
              prefixText: '$kCurrency ',
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
        FormLabel('DESCRIPTION', kBlue),
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
        FormLabel('CATEGORY', kPink),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final isSelected = _selectedCategory == category.name;
            return CategoryChip(
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
        FormLabel('DATE', kPurple),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: kWhite,
              border: Border.fromBorderSide(
                BorderSide(color: kBlack, width: 3),
              ),
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
        FormLabel('NOTE', kGreen),
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
    return BrutalActionButton(
      label: 'DELETE EXPENSE',
      color: kPink,
      onTap: () async {
        HapticFeedback.heavyImpact();
        final allowed = await PinDialog.verify(
          context,
          action: 'DELETE EXPENSE',
        );
        if (!allowed || !mounted) return;
        final confirmed = await showBrutalConfirm(
          context,
          title: 'DELETE?',
          confirmLabel: 'DELETE',
          color: kPink,
        );
        if (confirmed && mounted) {
          context.read<ExpenseBloc>().add(ExpenseDeleted(widget.expense!.id));
          Navigator.pop(context);
        }
      },
    );
  }
}
