// lib/features/expense/data/data_sources/expense_local_data_source.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense_model.dart';
import '../../../../core/util/constants.dart';

abstract class ExpenseLocalDataSource {
  Future<List<ExpenseModel>> getExpenses();
  Future<List<ExpenseModel>> getExpensesByCategory(String categoryId);
  Future<List<ExpenseModel>> getExpensesByDateRange(
      DateTime start, DateTime end);
  Future<void> addExpense(ExpenseModel expense);
  Future<void> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String expenseId);
  Future<void> saveExpenses(List<ExpenseModel> expenses);
  Future<double> getTotalExpenses();
  Future<double> getTotalExpensesByCategory(String categoryId);
  Future<double> getTotalExpensesByDateRange(DateTime start, DateTime end);
}

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  late Box<ExpenseModel> _box;

  ExpenseLocalDataSourceImpl() {
    _box = Hive.box<ExpenseModel>(AppConstants.expensesBox);
  }

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    return _box.values.toList();
  }

  @override
  Future<List<ExpenseModel>> getExpensesByCategory(String categoryId) async {
    return _box.values
        .where((expense) => expense.categoryId == categoryId)
        .toList();
  }

  @override
  Future<List<ExpenseModel>> getExpensesByDateRange(
      DateTime start, DateTime end) async {
    return _box.values.where((expense) {
      return expense.createdAt.isAfter(start) &&
          expense.createdAt.isBefore(end);
    }).toList();
  }

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    await _box.put(expense.id, expense);
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    await _box.put(expense.id, expense);
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    await _box.delete(expenseId);
  }

  @override
  Future<void> saveExpenses(List<ExpenseModel> expenses) async {
    await _box.clear();
    for (final expense in expenses) {
      await _box.put(expense.id, expense);
    }
  }

  @override
  Future<double> getTotalExpenses() async {
    final expenses = await getExpenses();
    double total = 0.0;
    for (final expense in expenses) {
      total += expense.amount;
    }
    return total;
  }

  @override
  Future<double> getTotalExpensesByCategory(String categoryId) async {
    final expenses = await getExpensesByCategory(categoryId);
    double total = 0.0;
    for (final expense in expenses) {
      total += expense.amount;
    }
    return total;
  }

  @override
  Future<double> getTotalExpensesByDateRange(
      DateTime start, DateTime end) async {
    final expenses = await getExpensesByDateRange(start, end);
    double total = 0.0;
    for (final expense in expenses) {
      total += expense.amount;
    }
    return total;
  }
}
