// lib/config/routes/app_routes.dart

/// Centralized route definitions for MoneyLogger app
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Auth Routes
  static const String login = '/login';
  static const String register = '/register';
  static const String userProfile = '/user-profile';

  // Home & Main Routes
  static const String home = '/';
  static const String splash = '/splash';

  // Expense Routes
  static const String addExpense = '/expense/add';
  static const String editExpense = '/expense/edit';
  static const String expenseDetails = '/expense/details';

  // Category Routes
  static const String categoryManagement = '/category/management';

  // Budget Routes
  static const String budgetManagement = '/budget/management';

  // Statistics & Analytics Routes
  static const String statistics = '/statistics';
  static const String advancedAnalytics = '/analytics/advanced';

  // Export Routes
  static const String exportData = '/export/data';

  // Recurring Expense Routes
  static const String recurringExpense = '/recurring-expense';

  // Shared Expense Routes
  static const String sharedExpense = '/shared-expense';

  // Photo Attachment Routes
  static const String photoAttachment = '/photo/attachment';
}
