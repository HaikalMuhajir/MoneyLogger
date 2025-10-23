// lib/features/expense/data/data_sources/expense_remote_data_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';
import '../../../../core/util/constants.dart';

abstract class ExpenseRemoteDataSource {
  Stream<List<ExpenseModel>> getExpenses(String userId);
  Stream<List<ExpenseModel>> getExpensesByCategory(
      String userId, String categoryId);
  Stream<List<ExpenseModel>> getExpensesByDateRange(
      String userId, DateTime start, DateTime end);
  Future<void> addExpense(ExpenseModel expense);
  Future<void> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String expenseId);
  Future<double> getTotalExpenses(String userId);
  Future<double> getTotalExpensesByCategory(String userId, String categoryId);
  Future<double> getTotalExpensesByDateRange(
      String userId, DateTime start, DateTime end);
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final FirebaseFirestore _firestore;

  ExpenseRemoteDataSourceImpl(this._firestore);

  @override
  Stream<List<ExpenseModel>> getExpenses(String userId) {
    return _firestore
        .collection(AppConstants.expensesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ExpenseModel.fromMap(doc.data()))
          .toList();
    });
  }

  @override
  Stream<List<ExpenseModel>> getExpensesByCategory(
      String userId, String categoryId) {
    return _firestore
        .collection(AppConstants.expensesCollection)
        .where('userId', isEqualTo: userId)
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ExpenseModel.fromMap(doc.data()))
          .toList();
    });
  }

  @override
  Stream<List<ExpenseModel>> getExpensesByDateRange(
      String userId, DateTime start, DateTime end) {
    return _firestore
        .collection(AppConstants.expensesCollection)
        .where('userId', isEqualTo: userId)
        .where('createdAt', isGreaterThanOrEqualTo: start)
        .where('createdAt', isLessThanOrEqualTo: end)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ExpenseModel.fromMap(doc.data()))
          .toList();
    });
  }

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    await _firestore
        .collection(AppConstants.expensesCollection)
        .doc(expense.id)
        .set(expense.toMap());
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    await _firestore
        .collection(AppConstants.expensesCollection)
        .doc(expense.id)
        .update(expense.toMap());
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    await _firestore
        .collection(AppConstants.expensesCollection)
        .doc(expenseId)
        .delete();
  }

  @override
  Future<double> getTotalExpenses(String userId) async {
    final snapshot = await _firestore
        .collection(AppConstants.expensesCollection)
        .where('userId', isEqualTo: userId)
        .get();

    double total = 0.0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      total += (data['amount'] as double? ?? 0.0);
    }
    return total;
  }

  @override
  Future<double> getTotalExpensesByCategory(
      String userId, String categoryId) async {
    final snapshot = await _firestore
        .collection(AppConstants.expensesCollection)
        .where('userId', isEqualTo: userId)
        .where('categoryId', isEqualTo: categoryId)
        .get();

    double total = 0.0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      total += (data['amount'] as double? ?? 0.0);
    }
    return total;
  }

  @override
  Future<double> getTotalExpensesByDateRange(
      String userId, DateTime start, DateTime end) async {
    final snapshot = await _firestore
        .collection(AppConstants.expensesCollection)
        .where('userId', isEqualTo: userId)
        .where('createdAt', isGreaterThanOrEqualTo: start)
        .where('createdAt', isLessThanOrEqualTo: end)
        .get();

    double total = 0.0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      total += (data['amount'] as double? ?? 0.0);
    }
    return total;
  }
}
