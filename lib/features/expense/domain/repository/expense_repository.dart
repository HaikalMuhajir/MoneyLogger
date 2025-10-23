// lib/features/expense/domain/repository/expense_repository.dart
import '../entities/expense_entity.dart';

abstract class ExpenseRepository {
  Stream<List<Expense>> getExpenses(String userId);
  Stream<List<Expense>> getExpensesByCategory(String userId, String categoryId);
  Stream<List<Expense>> getExpensesByDateRange(
      String userId, DateTime start, DateTime end);
  Future<void> addExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String expenseId);
  Future<void> syncExpenses(String userId);
  Future<double> getTotalExpenses(String userId);
  Future<double> getTotalExpensesByCategory(String userId, String categoryId);
  Future<double> getTotalExpensesByDateRange(
      String userId, DateTime start, DateTime end);
}
