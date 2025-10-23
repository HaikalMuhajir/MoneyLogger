// lib/features/budget/data/repository/budget_repository_impl.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/budget_entity.dart';
import '../data_sources/budget_remote_data_source.dart';

abstract class BudgetRepository {
  Stream<List<Budget>> getBudgets(String userId);
  Future<void> addBudget(Budget budget);
  Future<void> updateBudget(Budget budget);
  Future<void> deleteBudget(String budgetId);
}

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetRemoteDataSource _remoteDataSource;

  BudgetRepositoryImpl(this._remoteDataSource);

  @override
  Stream<List<Budget>> getBudgets(String userId) {
    return _remoteDataSource.getBudgets(userId);
  }

  @override
  Future<void> addBudget(Budget budget) async {
    await _remoteDataSource.addBudget(budget);
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    await _remoteDataSource.updateBudget(budget);
  }

  @override
  Future<void> deleteBudget(String budgetId) async {
    await _remoteDataSource.deleteBudget(budgetId);
  }
}

// Providers
final budgetRemoteDataSourceProvider = Provider<BudgetRemoteDataSource>((ref) {
  return BudgetRemoteDataSourceImpl(FirebaseFirestore.instance);
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final remoteDataSource = ref.watch(budgetRemoteDataSourceProvider);
  return BudgetRepositoryImpl(remoteDataSource);
});
