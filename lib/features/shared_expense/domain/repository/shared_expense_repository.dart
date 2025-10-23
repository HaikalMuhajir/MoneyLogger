// lib/features/shared_expense/domain/repository/shared_expense_repository.dart
import '../entities/shared_expense_entity.dart';

abstract class SharedExpenseRepository {
  Stream<List<SharedExpense>> getSharedExpenses(String userId);
  Stream<List<SharedExpense>> getSharedExpensesByStatus(
      String userId, SharedExpenseStatus status);
  Future<SharedExpense?> getSharedExpense(String expenseId);
  Future<void> createSharedExpense(SharedExpense expense);
  Future<void> updateSharedExpense(SharedExpense expense);
  Future<void> deleteSharedExpense(String expenseId);
  Future<void> addParticipant(
      String expenseId, SharedExpenseParticipant participant);
  Future<void> removeParticipant(String expenseId, String userId);
  Future<void> addExpenseItem(String expenseId, SharedExpenseItem item);
  Future<void> removeExpenseItem(String expenseId, String itemId);
  Future<void> settleExpense(String expenseId);
  Future<void> markParticipantAsPaid(
      String expenseId, String userId, double amount);
  Future<List<SharedExpense>> getPendingSettlements(String userId);
}
