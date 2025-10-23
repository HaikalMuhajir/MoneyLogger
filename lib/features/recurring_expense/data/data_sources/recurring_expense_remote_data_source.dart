// lib/features/recurring_expense/data/data_sources/recurring_expense_remote_data_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/recurring_expense_entity.dart';
import '../../../../core/util/constants.dart';

abstract class RecurringExpenseRemoteDataSource {
  Stream<List<RecurringExpense>> getRecurringExpenses(String userId);
  Future<void> addRecurringExpense(RecurringExpense recurringExpense);
  Future<void> updateRecurringExpense(RecurringExpense recurringExpense);
  Future<void> deleteRecurringExpense(String recurringExpenseId);
}

class RecurringExpenseRemoteDataSourceImpl implements RecurringExpenseRemoteDataSource {
  final FirebaseFirestore _firestore;

  RecurringExpenseRemoteDataSourceImpl(this._firestore);

  @override
  Stream<List<RecurringExpense>> getRecurringExpenses(String userId) {
    return _firestore
        .collection(AppConstants.recurringExpensesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RecurringExpense.fromMap(doc.data()))
          .toList();
    });
  }

  @override
  Future<void> addRecurringExpense(RecurringExpense recurringExpense) async {
    await _firestore
        .collection(AppConstants.recurringExpensesCollection)
        .doc(recurringExpense.id)
        .set(recurringExpense.toMap());
  }

  @override
  Future<void> updateRecurringExpense(RecurringExpense recurringExpense) async {
    await _firestore
        .collection(AppConstants.recurringExpensesCollection)
        .doc(recurringExpense.id)
        .update(recurringExpense.toMap());
  }

  @override
  Future<void> deleteRecurringExpense(String recurringExpenseId) async {
    await _firestore
        .collection(AppConstants.recurringExpensesCollection)
        .doc(recurringExpenseId)
        .delete();
  }
}
