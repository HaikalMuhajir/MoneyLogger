// lib/features/shared_expense/data/data_sources/shared_expense_remote_data_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/shared_expense_entity.dart';
import '../../../../core/util/constants.dart';

abstract class SharedExpenseRemoteDataSource {
  Stream<List<SharedExpense>> getSharedExpenses(String userId);
  Stream<List<SharedExpense>> getSharedExpensesByGroup(String groupId);
  Future<void> addSharedExpense(SharedExpense sharedExpense);
  Future<void> updateSharedExpense(SharedExpense sharedExpense);
  Future<void> deleteSharedExpense(String sharedExpenseId);
  Future<void> addExpenseToGroup(String groupId, String expenseId);
  Future<void> removeExpenseFromGroup(String groupId, String expenseId);
}

class SharedExpenseRemoteDataSourceImpl implements SharedExpenseRemoteDataSource {
  final FirebaseFirestore _firestore;

  SharedExpenseRemoteDataSourceImpl(this._firestore);

  @override
  Stream<List<SharedExpense>> getSharedExpenses(String userId) {
    return _firestore
        .collection(AppConstants.sharedExpensesCollection)
        .where('participants', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SharedExpense.fromMap(doc.data()))
          .toList();
    });
  }

  @override
  Stream<List<SharedExpense>> getSharedExpensesByGroup(String groupId) {
    return _firestore
        .collection(AppConstants.sharedExpensesCollection)
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SharedExpense.fromMap(doc.data()))
          .toList();
    });
  }

  @override
  Future<void> addSharedExpense(SharedExpense sharedExpense) async {
    await _firestore
        .collection(AppConstants.sharedExpensesCollection)
        .doc(sharedExpense.id)
        .set(sharedExpense.toMap());
  }

  @override
  Future<void> updateSharedExpense(SharedExpense sharedExpense) async {
    await _firestore
        .collection(AppConstants.sharedExpensesCollection)
        .doc(sharedExpense.id)
        .update(sharedExpense.toMap());
  }

  @override
  Future<void> deleteSharedExpense(String sharedExpenseId) async {
    await _firestore
        .collection(AppConstants.sharedExpensesCollection)
        .doc(sharedExpenseId)
        .delete();
  }

  @override
  Future<void> addExpenseToGroup(String groupId, String expenseId) async {
    await _firestore
        .collection(AppConstants.sharedExpensesCollection)
        .doc(groupId)
        .update({
      'expenseIds': FieldValue.arrayUnion([expenseId])
    });
  }

  @override
  Future<void> removeExpenseFromGroup(String groupId, String expenseId) async {
    await _firestore
        .collection(AppConstants.sharedExpensesCollection)
        .doc(groupId)
        .update({
      'expenseIds': FieldValue.arrayRemove([expenseId])
    });
  }
}
