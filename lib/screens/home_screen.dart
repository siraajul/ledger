import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/expense/expense_bloc.dart';
import '../bloc/expense/expense_event.dart';
import '../bloc/expense/expense_state.dart';
import '../bloc/settings/settings_bloc.dart';
import '../bloc/settings/settings_state.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';
import '../widgets/brutal_widgets.dart';
import '../widgets/expense_card.dart';
import '../widgets/animations.dart';
import '../widgets/pin_dialog.dart';
import '../widgets/sync_badge.dart';
import '../theme.dart';
import '../widgets/budget_bar.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const HomeScreen({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final expenses = state.filtered;
          return CustomScrollView(
            slivers: [
              _buildHeader(),
              _buildSummary(
                context,
                state.filter,
                state.total,
                expenses.length,
                state.thisMonth,
              ),
              _buildTimeFilter(context, state.filter),
              _buildExpenseList(context, expenses),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();

    return SliverToBoxAdapter(
      child: StaggeredAnimation(
        index: 0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
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
                      DateFormat('MMM d, yyyy').format(now).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const SyncBadge(),
                ],
              ),
              const SizedBox(height: 12),
              BlocBuilder<SettingsBloc, SettingsState>(
                buildWhen: (a, b) => a.userName != b.userName,
                builder: (context, settings) => Text(
                  settings.userName.isNotEmpty
                      ? 'HEY, ${settings.userName.toUpperCase()}'
                      : 'HEY THERE',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: kBlack,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(
    BuildContext context,
    TimeFilter filter,
    double total,
    int count,
    List<Expense> thisMonth,
  ) {
    final budget = context.select<SettingsBloc, double>((s) => s.state.budget);
    final isMonth = filter == TimeFilter.month;
    final spent = isMonth ? total : thisMonth.fold(0.0, (s, e) => s + e.amount);
    final remaining = budget - spent;
    final overBudget = remaining < 0;
    final showBudget = isMonth && budget > 0;

    return SliverToBoxAdapter(
      child: StaggeredAnimation(
        index: 1,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: kYellow,
              border: Border.fromBorderSide(
                BorderSide(color: kBlack, width: 3),
              ),
              boxShadow: [kCardShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getFilterLabel(filter),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedCounter(
                  value: total,
                  prefix: kCurrency,
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: kBlack,
                    letterSpacing: -2,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: const BoxDecoration(
                    color: kWhite,
                    border: Border.fromBorderSide(
                      BorderSide(color: kBlack, width: 2),
                    ),
                  ),
                  child: Text(
                    '$count TRANSACTIONS',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                if (showBudget) ...[
                  const SizedBox(height: 16),
                  BudgetBar(
                    spent: spent,
                    budget: budget,
                    remaining: remaining,
                    overBudget: overBudget,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeFilter(BuildContext context, TimeFilter selected) {
    return SliverToBoxAdapter(
      child: StaggeredAnimation(
        index: 2,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: TimeFilter.values.map((filter) {
              final isSelected = selected == filter;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.read<ExpenseBloc>().add(FilterChanged(filter));
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? kBlack : kWhite,
                      border: Border.all(color: kBlack, width: 2),
                      boxShadow: isSelected
                          ? []
                          : const [
                              BoxShadow(offset: Offset(2, 2), color: kBlack),
                            ],
                    ),
                    child: Center(
                      child: Text(
                        _getFilterName(filter).toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? kYellow : kBlack,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseList(BuildContext context, List<Expense> expenses) {
    if (expenses.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: StaggeredAnimation(
            index: 0,
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PulseAnimation(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: kWhite,
                        border: Border.fromBorderSide(
                          BorderSide(color: kBlack, width: 3),
                        ),
                        boxShadow: [
                          BoxShadow(offset: Offset(3, 3), color: kBlack),
                        ],
                      ),
                      child: const Center(
                        child: Text('📦', style: TextStyle(fontSize: 36)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'NOTHING YET.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add\nyour first expense.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.push(
                        context,
                        SlidePageTransition(page: const AddExpenseScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        color: kYellow,
                        border: Border.fromBorderSide(
                          BorderSide(color: kBlack, width: 2),
                        ),
                        boxShadow: [
                          BoxShadow(offset: Offset(2, 2), color: kBlack),
                        ],
                      ),
                      child: const Text(
                        'ADD FIRST EXPENSE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Group expenses by date
    final grouped = <String, List<Expense>>{};
    for (final expense in expenses) {
      final key = DateFormat('yyyy-MM-dd').format(expense.date);
      grouped.putIfAbsent(key, () => []).add(expense);
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final dateKey = sortedKeys[index];
          final dayExpenses = grouped[dateKey]!;
          final dayTotal = dayExpenses.fold(0.0, (sum, e) => sum + e.amount);
          final date = DateTime.parse(dateKey);

          return StaggeredAnimation(
            index: index + 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: const BoxDecoration(
                          color: kPink,
                          border: Border.fromBorderSide(
                            BorderSide(color: kBlack, width: 2),
                          ),
                        ),
                        child: Text(
                          _formatDateHeader(date).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Text(
                        '-$kCurrency${dayTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: kBlack,
                        ),
                      ),
                    ],
                  ),
                ),
                ...dayExpenses.map(
                  (expense) => SwipeToDelete(
                    key: ValueKey(expense.id),
                    beforeDismiss: () =>
                        PinDialog.verify(context, action: 'DELETE EXPENSE'),
                    onDismissed: () => context.read<ExpenseBloc>().add(
                      ExpenseDeleted(expense.id),
                    ),
                    child: ExpenseCard(
                      expense: expense,
                      onTap: () async {
                        HapticFeedback.mediumImpact();
                        final allowed = await PinDialog.verify(
                          context,
                          action: 'EDIT EXPENSE',
                        );
                        if (!allowed || !context.mounted) return;
                        Navigator.push(
                          context,
                          SlidePageTransition(
                            page: AddExpenseScreen(expense: expense),
                          ),
                        );
                      },
                      onDelete: () async {
                        HapticFeedback.heavyImpact();
                        final allowed = await _confirmDelete(
                          context,
                          action: 'DELETE EXPENSE',
                        );
                        if (!allowed || !context.mounted) return;
                        context.read<ExpenseBloc>().add(
                          ExpenseDeleted(expense.id),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }, childCount: sortedKeys.length),
      ),
    );
  }

  String _getFilterLabel(TimeFilter filter) {
    switch (filter) {
      case TimeFilter.today:
        return "TODAY";
      case TimeFilter.week:
        return 'LAST 7 DAYS';
      case TimeFilter.month:
        return 'THIS MONTH';
      case TimeFilter.all:
        return 'ALL TIME';
    }
  }

  String _getFilterName(TimeFilter filter) {
    switch (filter) {
      case TimeFilter.today:
        return 'TODAY';
      case TimeFilter.week:
        return 'WEEK';
      case TimeFilter.month:
        return 'MONTH';
      case TimeFilter.all:
        return 'ALL';
    }
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'TODAY';
    if (dateOnly == yesterday) return 'YESTERDAY';
    return DateFormat('EEE, MMM d').format(date);
  }
}

/// Mirrors the swipe-delete flow exactly: confirm dialog, then PIN
/// gate, then the caller proceeds. Long-press previously skipped the
/// confirm step, giving accidental deletions fewer checks.
Future<bool> _confirmDelete(
  BuildContext context, {
  required String action,
}) async {
  final confirmed = await showBrutalConfirm(
    context,
    title: 'DELETE?',
    confirmLabel: 'DELETE',
    color: kPink,
  );
  if (!confirmed || !context.mounted) return false;
  return PinDialog.verify(context, action: action);
}
