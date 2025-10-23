// lib/config/routes/route_generator.dart

import 'package:flutter/material.dart';
import 'app_routes.dart';

// Import all pages
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/registration_page.dart';
import '../../features/auth/presentation/pages/user_profile_page.dart';
import '../../features/expense/presentation/pages/home_page.dart';
import '../../features/expense/presentation/pages/add_expense_page.dart';
import '../../features/expense/presentation/pages/edit_expense_page.dart';
import '../../features/category/presentation/pages/category_management_page.dart';
import '../../features/budget/presentation/pages/budget_management_page.dart';
import '../../features/expense/presentation/pages/statistics_page.dart';
import '../../features/analytics/presentation/pages/advanced_analytics_page.dart';
import '../../features/expense/presentation/pages/export_data_page.dart';
import '../../features/recurring_expense/presentation/pages/recurring_expense_page.dart';
import '../../features/shared_expense/presentation/pages/shared_expense_page.dart';

/// Centralized route generator for the MoneyLogger app
class AppRouteGenerator {
  /// Generate routes based on route name
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth Routes
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );

      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegistrationPage(),
          settings: settings,
        );

      case AppRoutes.userProfile:
        return MaterialPageRoute(
          builder: (_) => const UserProfilePage(),
          settings: settings,
        );

      // Home Routes
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );

      // Expense Routes
      case AppRoutes.addExpense:
        return MaterialPageRoute(
          builder: (_) => const AddExpensePage(),
          settings: settings,
        );

      case AppRoutes.editExpense:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || args['expense'] == null) {
          return _errorRoute('Expense data is required for edit page');
        }
        return MaterialPageRoute(
          builder: (_) => EditExpensePage(expense: args['expense']),
          settings: settings,
        );

      // Category Routes
      case AppRoutes.categoryManagement:
        return MaterialPageRoute(
          builder: (_) => const CategoryManagementPage(),
          settings: settings,
        );

      // Budget Routes
      case AppRoutes.budgetManagement:
        return MaterialPageRoute(
          builder: (_) => const BudgetManagementPage(),
          settings: settings,
        );

      // Statistics Routes
      case AppRoutes.statistics:
        return MaterialPageRoute(
          builder: (_) => const StatisticsPage(),
          settings: settings,
        );

      case AppRoutes.advancedAnalytics:
        return MaterialPageRoute(
          builder: (_) => const AdvancedAnalyticsPage(),
          settings: settings,
        );

      // Export Routes
      case AppRoutes.exportData:
        return MaterialPageRoute(
          builder: (_) => const ExportDataPage(),
          settings: settings,
        );

      // Recurring Expense Routes
      case AppRoutes.recurringExpense:
        return MaterialPageRoute(
          builder: (_) => const RecurringExpensePage(),
          settings: settings,
        );

      // Shared Expense Routes
      case AppRoutes.sharedExpense:
        return MaterialPageRoute(
          builder: (_) => const SharedExpensePage(),
          settings: settings,
        );

      // Default route (404)
      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  /// Error route for invalid routes
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(_).pushNamedAndRemoveUntil(
                  AppRoutes.home,
                  (route) => false,
                ),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
