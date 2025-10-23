// lib/features/expense/data/repository/expense_repository_impl.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repository/expense_repository.dart';
import '../../domain/entities/expense_entity.dart';
import '../data_sources/expense_local_data_source.dart';
import '../data_sources/expense_remote_data_source.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource _localDataSource;
  final ExpenseRemoteDataSource _remoteDataSource;

  ExpenseRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Stream<List<Expense>> getExpenses(String userId) {
    return _remoteDataSource.getExpenses(userId).map((models) {
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Stream<List<Expense>> getExpensesByCategory(
      String userId, String categoryId) {
    return _remoteDataSource
        .getExpensesByCategory(userId, categoryId)
        .map((models) {
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Stream<List<Expense>> getExpensesByDateRange(
      String userId, DateTime start, DateTime end) {
    return _remoteDataSource
        .getExpensesByDateRange(userId, start, end)
        .map((models) {
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<void> addExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);

    // Save to local first
    await _localDataSource.addExpense(model);

    // Then sync to remote
    try {
      await _remoteDataSource.addExpense(model);
    } catch (e) {
      // Mark as pending if sync fails
      final pendingModel = model.copyWith(isPending: true);
      await _localDataSource.updateExpense(pendingModel);
      rethrow;
    }
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);

    // Update local first
    await _localDataSource.updateExpense(model);

    // Then sync to remote
    try {
      await _remoteDataSource.updateExpense(model);
    } catch (e) {
      // Mark as pending if sync fails
      final pendingModel = model.copyWith(isPending: true);
      await _localDataSource.updateExpense(pendingModel);
      rethrow;
    }
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    // Delete from local first
    await _localDataSource.deleteExpense(expenseId);

    // Then sync to remote
    try {
      await _remoteDataSource.deleteExpense(expenseId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> syncExpenses(String userId) async {
    try {
      // Get remote expenses
      final remoteExpenses = await _remoteDataSource.getExpenses(userId).first;

      // Save to local
      await _localDataSource.saveExpenses(remoteExpenses);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<double> getTotalExpenses(String userId) async {
    try {
      return await _remoteDataSource.getTotalExpenses(userId);
    } catch (e) {
      // Fallback to local data
      return await _localDataSource.getTotalExpenses();
    }
  }

  @override
  Future<double> getTotalExpensesByCategory(
      String userId, String categoryId) async {
    try {
      return await _remoteDataSource.getTotalExpensesByCategory(
          userId, categoryId);
    } catch (e) {
      // Fallback to local data
      return await _localDataSource.getTotalExpensesByCategory(categoryId);
    }
  }

  @override
  Future<double> getTotalExpensesByDateRange(
      String userId, DateTime start, DateTime end) async {
    try {
      return await _remoteDataSource.getTotalExpensesByDateRange(
          userId, start, end);
    } catch (e) {
      // Fallback to local data
      return await _localDataSource.getTotalExpensesByDateRange(start, end);
    }
  }
}

// Providers
final expenseLocalDataSourceProvider = Provider<ExpenseLocalDataSource>((ref) {
  return ExpenseLocalDataSourceImpl();
});

final expenseRemoteDataSourceProvider =
    Provider<ExpenseRemoteDataSource>((ref) {
  return ExpenseRemoteDataSourceImpl(FirebaseFirestore.instance);
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final localDataSource = ref.watch(expenseLocalDataSourceProvider);
  final remoteDataSource = ref.watch(expenseRemoteDataSourceProvider);
  return ExpenseRepositoryImpl(localDataSource, remoteDataSource);
});
