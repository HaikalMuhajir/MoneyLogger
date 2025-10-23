// lib/features/shared_expense/data/repository/shared_expense_repository_impl.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/shared_expense_entity.dart';
import '../../domain/repository/shared_expense_repository.dart';
import '../data_sources/shared_expense_remote_data_source.dart';

class SharedExpenseRepositoryImpl implements SharedExpenseRepository {
  final SharedExpenseRemoteDataSource _remoteDataSource;

  SharedExpenseRepositoryImpl(this._remoteDataSource);

  @override
  Stream<List<SharedExpense>> getSharedExpenses(String userId) {
    return _remoteDataSource.getSharedExpenses(userId);
  }

  @override
  Stream<List<SharedExpense>> getSharedExpensesByStatus(
      String userId, SharedExpenseStatus status) {
    return _remoteDataSource.getSharedExpenses(userId).map((expenses) {
      return expenses.where((expense) => expense.status == status).toList();
    });
  }

  @override
  Future<SharedExpense?> getSharedExpense(String expenseId) async {
    final expenses = await _remoteDataSource.getSharedExpenses('').first;
    try {
      return expenses.firstWhere((expense) => expense.id == expenseId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> createSharedExpense(SharedExpense expense) async {
    await _remoteDataSource.addSharedExpense(expense);
  }

  @override
  Future<void> updateSharedExpense(SharedExpense expense) async {
    await _remoteDataSource.updateSharedExpense(expense);
  }

  @override
  Future<void> deleteSharedExpense(String expenseId) async {
    await _remoteDataSource.deleteSharedExpense(expenseId);
  }

  @override
  Future<void> addParticipant(
      String expenseId, SharedExpenseParticipant participant) async {
    final expense = await getSharedExpense(expenseId);
    if (expense != null) {
      final updatedExpense = expense.copyWith(
        participants: [...expense.participants, participant],
      );
      await updateSharedExpense(updatedExpense);
    }
  }

  @override
  Future<void> removeParticipant(String expenseId, String userId) async {
    final expense = await getSharedExpense(expenseId);
    if (expense != null) {
      final updatedExpense = expense.copyWith(
        participants:
            expense.participants.where((p) => p.userId != userId).toList(),
      );
      await updateSharedExpense(updatedExpense);
    }
  }

  @override
  Future<void> addExpenseItem(String expenseId, SharedExpenseItem item) async {
    final expense = await getSharedExpense(expenseId);
    if (expense != null) {
      final updatedExpense = expense.copyWith(
        items: [...expense.items, item],
      );
      await updateSharedExpense(updatedExpense);
    }
  }

  @override
  Future<void> removeExpenseItem(String expenseId, String itemId) async {
    final expense = await getSharedExpense(expenseId);
    if (expense != null) {
      final updatedExpense = expense.copyWith(
        items: expense.items.where((item) => item.id != itemId).toList(),
      );
      await updateSharedExpense(updatedExpense);
    }
  }

  @override
  Future<void> settleExpense(String expenseId) async {
    final expense = await getSharedExpense(expenseId);
    if (expense != null) {
      final updatedExpense = expense.copyWith(
        status: SharedExpenseStatus.settled,
        settledAt: DateTime.now(),
      );
      await updateSharedExpense(updatedExpense);
    }
  }

  @override
  Future<void> markParticipantAsPaid(
      String expenseId, String userId, double amount) async {
    final expense = await getSharedExpense(expenseId);
    if (expense != null) {
      final updatedParticipants = expense.participants.map((participant) {
        if (participant.userId == userId) {
          return participant.copyWith(
            amountPaid: participant.amountPaid + amount,
            isSettled:
                (participant.amountPaid + amount) >= participant.amountOwed,
          );
        }
        return participant;
      }).toList();

      final updatedExpense = expense.copyWith(
        participants: updatedParticipants,
      );
      await updateSharedExpense(updatedExpense);
    }
  }

  @override
  Future<List<SharedExpense>> getPendingSettlements(String userId) async {
    final expenses =
        await getSharedExpensesByStatus(userId, SharedExpenseStatus.active)
            .first;
    return expenses.where((expense) {
      return expense.participants
          .any((p) => p.userId == userId && !p.isSettled);
    }).toList();
  }
}

// Providers
final sharedExpenseRemoteDataSourceProvider =
    Provider<SharedExpenseRemoteDataSource>((ref) {
  return SharedExpenseRemoteDataSourceImpl(FirebaseFirestore.instance);
});

final sharedExpenseRepositoryProvider =
    Provider<SharedExpenseRepository>((ref) {
  final remoteDataSource = ref.watch(sharedExpenseRemoteDataSourceProvider);
  return SharedExpenseRepositoryImpl(remoteDataSource);
});
