import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expenses.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT
      )
    ''');
  }

  Future<void> insertExpense(Expense expense) async {
    final db = await database;
    await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateExpense(Expense expense) async {
    final db = await database;
    await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<void> deleteExpense(String id) async {
    final db = await database;
    await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final result = await db.query('expenses', orderBy: 'date DESC');
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  Future<void> clearAllExpenses() async {
    final db = await database;
    await db.delete('expenses');
  }

  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final result = await db.query(
      'expenses',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  Future<double> getTotalExpenses() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(amount) as total FROM expenses');
    return (result.first['total'] as double?) ?? 0.0;
  }

  Future<Map<String, double>> getExpensesByCategory() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT category, SUM(amount) as total 
      FROM expenses 
      GROUP BY category
    ''');
    
    Map<String, double> categoryTotals = {};
    for (var row in result) {
      categoryTotals[row['category'] as String] = (row['total'] as double);
    }
    return categoryTotals;
  }
}
