// lib/features/budget/data/data_sources/budget_remote_data_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/budget_entity.dart';
import '../../../../core/util/constants.dart';

abstract class BudgetRemoteDataSource {
  Stream<List<Budget>> getBudgets(String userId);
  Future<void> addBudget(Budget budget);
  Future<void> updateBudget(Budget budget);
  Future<void> deleteBudget(String budgetId);
}

class BudgetRemoteDataSourceImpl implements BudgetRemoteDataSource {
  final FirebaseFirestore _firestore;

  BudgetRemoteDataSourceImpl(this._firestore);

  @override
  Stream<List<Budget>> getBudgets(String userId) {
    return _firestore
        .collection(AppConstants.budgetsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Budget.fromMap(doc.data())).toList();
    });
  }

  @override
  Future<void> addBudget(Budget budget) async {
    await _firestore
        .collection(AppConstants.budgetsCollection)
        .doc(budget.id)
        .set(budget.toMap());
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    await _firestore
        .collection(AppConstants.budgetsCollection)
        .doc(budget.id)
        .update(budget.toMap());
  }

  @override
  Future<void> deleteBudget(String budgetId) async {
    await _firestore
        .collection(AppConstants.budgetsCollection)
        .doc(budgetId)
        .delete();
  }
}
