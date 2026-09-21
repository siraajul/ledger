class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      note: map['note'],
    );
  }
}

class ExpenseCategory {
  final String name;
  final String icon;
  final int color;

  const ExpenseCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

const List<ExpenseCategory> categories = [
  ExpenseCategory(name: 'Food', icon: '🍔', color: 0xFFFF6B6B),
  ExpenseCategory(name: 'Transport', icon: '🚗', color: 0xFF4ECDC4),
  ExpenseCategory(name: 'Shopping', icon: '🛍️', color: 0xFFFFE66D),
  ExpenseCategory(name: 'Bills', icon: '📱', color: 0xFF95E1D3),
  ExpenseCategory(name: 'Entertainment', icon: '🎬', color: 0xFFF38181),
  ExpenseCategory(name: 'Health', icon: '💊', color: 0xFFAA96DA),
  ExpenseCategory(name: 'Education', icon: '📚', color: 0xFFFCBAD3),
  ExpenseCategory(name: 'Other', icon: '📦', color: 0xFFA8D8EA),
];
