import '../models/expense.dart';
import '../theme.dart';

/// What the app knows when a reminder is scheduled.
class ReminderFacts {
  final DateTime? lastExpense;
  final int todayCount;
  final double todayTotal;
  final double monthTotal;
  final double budget;

  const ReminderFacts({
    this.lastExpense,
    this.todayCount = 0,
    this.todayTotal = 0,
    this.monthTotal = 0,
    this.budget = 0,
  });

  factory ReminderFacts.from({
    required Iterable<Expense> expenses,
    required double budget,
    required DateTime now,
  }) {
    DateTime? last;
    var todayCount = 0;
    var todayTotal = 0.0;
    var monthTotal = 0.0;
    for (final e in expenses) {
      if (last == null || e.date.isAfter(last)) last = e.date;
      final sameMonth = e.date.year == now.year && e.date.month == now.month;
      if (sameMonth) {
        monthTotal += e.amount;
        if (e.date.day == now.day) {
          todayCount++;
          todayTotal += e.amount;
        }
      }
    }
    return ReminderFacts(
      lastExpense: last,
      todayCount: todayCount,
      todayTotal: todayTotal,
      monthTotal: monthTotal,
      budget: budget,
    );
  }
}

/// Where a check-in sits in the day, which sets the tone of the message.
enum CheckIn { first, middle, last }

typedef ReminderMessage = ({String title, String body});

String _money(double v) => '$kCurrency${v.round()}';

/// Rotates through [options] so the same check-in doesn't read identically
/// every day.
String _pick(List<String> options, int seed) => options[seed % options.length];

/// The notification for a check-in at [slot].
///
/// Figures (today's total, budget left) are only used for a check-in later
/// the same day: the text is fixed when the notification is scheduled, so
/// numbers for a future day would be stale by the time it appears.
ReminderMessage reminderMessage({
  required DateTime slot,
  required DateTime now,
  required CheckIn position,
  required ReminderFacts facts,
}) {
  final seed = slot.difference(DateTime(slot.year)).inDays;
  final sameDay =
      slot.year == now.year && slot.month == now.month && slot.day == now.day;
  final fresh = sameDay ? facts : const ReminderFacts();
  final remaining = facts.budget - facts.monthTotal;

  // Nothing ever logged: get the first expense in rather than talk budgets.
  if (facts.lastExpense == null) {
    return (
      title: 'START YOUR LEDGER',
      body: _pick([
        'Add your first expense — even a coffee counts.',
        'Nothing tracked yet. What did you spend today?',
        'One tap to log your first expense.',
      ], seed),
    );
  }

  // Back after a quiet stretch.
  final silentDays = now.difference(facts.lastExpense!).inDays;
  if (silentDays >= 3 && fresh.todayCount == 0) {
    return (
      title: 'STILL TRACKING?',
      body: _pick([
        'No expenses in $silentDays days. Catch up while you remember.',
        "It's been $silentDays days. Add what you've spent since.",
      ], seed),
    );
  }

  // The day's last check-in doubles as a summary.
  if (position == CheckIn.last) {
    if (fresh.todayCount > 0) {
      final n = fresh.todayCount;
      return (
        title: "TODAY'S TOTAL",
        body:
            '${_money(fresh.todayTotal)} across $n ${n == 1 ? 'expense' : 'expenses'}. Anything missing?',
      );
    }
    return (
      title: 'BEFORE BED',
      body: _pick([
        'Nothing logged today. Add it before you forget what it was.',
        'Log the day now — tomorrow you never remember.',
        'Empty day so far. Spend nothing, or forget to log it?',
      ], seed),
    );
  }

  // Budget lines: only with a budget set, and only for later today.
  if (sameDay && facts.budget > 0) {
    if (remaining < 0) {
      return (
        title: 'OVER BUDGET',
        body:
            '${_money(-remaining)} over this month. Keep logging so you know where it went.',
      );
    }
    if (remaining <= facts.budget * 0.2) {
      return (
        title: 'BUDGET RUNNING LOW',
        body: '${_money(remaining)} left this month. Logged anything just now?',
      );
    }
    if (seed.isEven) {
      return (
        title: position == CheckIn.first ? 'MORNING CHECK-IN' : 'CHECK-IN',
        body: '${_money(remaining)} left this month. Anything to add?',
      );
    }
  }

  if (position == CheckIn.first) {
    return (
      title: 'MORNING CHECK-IN',
      body: _pick([
        'Anything on the way in — fare, breakfast, coffee?',
        'Spent anything this morning?',
        'Log it now while the morning is fresh.',
      ], seed),
    );
  }
  return (
    title: 'MIDDAY CHECK-IN',
    body: _pick([
      'Lunch, coffee, anything else? Log it now.',
      'Spent anything since this morning?',
      'Quick one: anything to add since the last check-in?',
    ], seed),
  );
}
