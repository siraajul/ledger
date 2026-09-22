import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense.dart';
import 'database_helper.dart';

/// Expenses stored per signed-in user in Firestore.
///
/// Firestore's on-device cache keeps the app usable offline; writes made while
/// offline are replayed when the connection comes back.
class ExpenseRepository {
  static final ExpenseRepository instance = ExpenseRepository._();

  ExpenseRepository._();

  CollectionReference<Map<String, dynamic>> get _collection {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Expenses are only available while signed in.');
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('expenses');
  }

  /// Live view of the signed-in user's expenses, newest first.
  Stream<List<Expense>> watchExpenses() => _collection
      .orderBy('date', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((d) => Expense.fromMap(d.data())).toList());

  Future<void> insertExpense(Expense expense) =>
      _collection.doc(expense.id).set(expense.toMap());

  Future<void> updateExpense(Expense expense) =>
      _collection.doc(expense.id).set(expense.toMap());

  Future<void> deleteExpense(String id) => _collection.doc(id).delete();

  Future<void> clearAllExpenses() async {
    final snap = await _collection.get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Copies expenses written by pre-cloud builds into this account, once.
  ///
  /// The local sqflite rows are left untouched so a failed migration can be
  /// retried (the flag is only set after the upload commits).
  Future<void> migrateLegacyLocalExpenses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final flag = 'legacy_expenses_migrated_${user.uid}';
    if (prefs.getBool(flag) ?? false) return;

    final legacy = await DatabaseHelper.instance.getAllExpenses();
    if (legacy.isNotEmpty) {
      final batch = FirebaseFirestore.instance.batch();
      for (final expense in legacy) {
        batch.set(_collection.doc(expense.id), expense.toMap());
      }
      await batch.commit();
    }
    await prefs.setBool(flag, true);
  }
}
