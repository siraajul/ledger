import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/models/expense.dart';
import 'package:ledger/services/reminder_messages.dart';

void main() {
  final now = DateTime(2026, 9, 22, 9);
  DateTime today(int h) => DateTime(2026, 9, 22, h);
  DateTime tomorrow(int h) => DateTime(2026, 9, 23, h);

  Expense e(DateTime d, double amount) =>
      Expense(id: '$d', title: 't', amount: amount, category: 'Food', date: d);

  ReminderMessage msg(
    DateTime slot,
    CheckIn position,
    ReminderFacts facts, {
    DateTime? at,
  }) => reminderMessage(
    slot: slot,
    now: at ?? now,
    position: position,
    facts: facts,
  );

  test('facts summarise today and this month', () {
    final facts = ReminderFacts.from(
      expenses: [
        e(DateTime(2026, 9, 22, 8), 100),
        e(DateTime(2026, 9, 22, 8, 30), 50),
        e(DateTime(2026, 9, 2), 400), // earlier this month
        e(DateTime(2026, 8, 31), 999), // last month
      ],
      budget: 1000,
      now: now,
    );
    expect(facts.todayCount, 2);
    expect(facts.todayTotal, 150);
    expect(facts.monthTotal, 550);
    expect(facts.lastExpense, DateTime(2026, 9, 22, 8, 30));
  });

  test('no expenses ever: onboarding nudge, no budget talk', () {
    final m = msg(today(14), CheckIn.middle, const ReminderFacts(budget: 1000));
    expect(m.title, 'START YOUR LEDGER');
    expect(m.body, contains('first expense'));
  });

  test('quiet for days: says how long', () {
    final m = msg(
      today(14),
      CheckIn.middle,
      ReminderFacts(lastExpense: DateTime(2026, 9, 18), budget: 1000),
    );
    expect(m.title, 'STILL TRACKING?');
    expect(m.body, contains('4 days'));
  });

  test('evening: summarises the day when something was logged', () {
    final m = msg(
      today(19),
      CheckIn.last,
      ReminderFacts(
        lastExpense: today(8),
        todayCount: 3,
        todayTotal: 845.4,
        monthTotal: 845.4,
        budget: 5000,
      ),
    );
    expect(m.title, "TODAY'S TOTAL");
    expect(m.body, contains('৳845 across 3 expenses'));
  });

  test('evening with nothing logged: nudge, not a ৳0 summary', () {
    final m = msg(
      today(19),
      CheckIn.last,
      ReminderFacts(lastExpense: today(0)),
    );
    expect(m.title, 'BEFORE BED');
    expect(m.body, isNot(contains('৳')));
  });

  test('over budget is called out', () {
    final m = msg(
      today(14),
      CheckIn.middle,
      ReminderFacts(lastExpense: today(8), monthTotal: 5600, budget: 5000),
    );
    expect(m.title, 'OVER BUDGET');
    expect(m.body, contains('৳600 over'));
  });

  test('nearly spent budget warns with what is left', () {
    final m = msg(
      today(14),
      CheckIn.middle,
      ReminderFacts(lastExpense: today(8), monthTotal: 4500, budget: 5000),
    );
    expect(m.title, 'BUDGET RUNNING LOW');
    expect(m.body, contains('৳500 left'));
  });

  test('a future day never quotes figures, which would be stale', () {
    final m = msg(
      tomorrow(19),
      CheckIn.last,
      ReminderFacts(
        lastExpense: today(8),
        todayCount: 3,
        todayTotal: 845,
        monthTotal: 5600,
        budget: 5000,
      ),
    );
    expect(m.body, isNot(contains('৳')));
    expect(m.title, 'BEFORE BED');
  });

  test('morning and midday wording differs, and rotates by day', () {
    final facts = ReminderFacts(lastExpense: today(8));
    expect(msg(today(10), CheckIn.first, facts).title, 'MORNING CHECK-IN');
    expect(msg(today(14), CheckIn.middle, facts).title, 'MIDDAY CHECK-IN');
    final bodies = {
      for (var d = 0; d < 3; d++)
        msg(
          DateTime(2026, 9, 22 + d, 14),
          CheckIn.middle,
          ReminderFacts(lastExpense: DateTime(2026, 9, 22 + d, 8)),
          at: DateTime(2026, 9, 22 + d, 9),
        ).body,
    };
    expect(bodies.length, greaterThan(1));
  });
}
