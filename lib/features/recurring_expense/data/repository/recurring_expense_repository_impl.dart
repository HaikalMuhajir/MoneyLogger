// lib/features/recurring_expense/data/repository/recurring_expense_repository_impl.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/recurring_expense_entity.dart';
import '../data_sources/recurring_expense_remote_data_source.dart';

abstract class RecurringExpenseRepository {
  Stream<List<RecurringExpense>> getRecurringExpenses(String userId);
  Future<void> addRecurringExpense(RecurringExpense recurringExpense);
  Future<void> updateRecurringExpense(RecurringExpense recurringExpense);
  Future<void> deleteRecurringExpense(String recurringExpenseId);
}

class RecurringExpenseRepositoryImpl implements RecurringExpenseRepository {
  final RecurringExpenseRemoteDataSource _remoteDataSource;

  RecurringExpenseRepositoryImpl(this._remoteDataSource);

  @override
  Stream<List<RecurringExpense>> getRecurringExpenses(String userId) {
    return _remoteDataSource.getRecurringExpenses(userId);
  }

  @override
  Future<void> addRecurringExpense(RecurringExpense recurringExpense) async {
    await _remoteDataSource.addRecurringExpense(recurringExpense);
  }

  @override
  Future<void> updateRecurringExpense(RecurringExpense recurringExpense) async {
    await _remoteDataSource.updateRecurringExpense(recurringExpense);
  }

  @override
  Future<void> deleteRecurringExpense(String recurringExpenseId) async {
    await _remoteDataSource.deleteRecurringExpense(recurringExpenseId);
  }
}

// Providers
final recurringExpenseRemoteDataSourceProvider = Provider<RecurringExpenseRemoteDataSource>((ref) {
  return RecurringExpenseRemoteDataSourceImpl(FirebaseFirestore.instance);
});

final recurringExpenseRepositoryProvider = Provider<RecurringExpenseRepository>((ref) {
  final remoteDataSource = ref.watch(recurringExpenseRemoteDataSourceProvider);
  return RecurringExpenseRepositoryImpl(remoteDataSource);
});
