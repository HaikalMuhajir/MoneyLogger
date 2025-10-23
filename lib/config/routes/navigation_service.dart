// lib/config/routes/navigation_service.dart

import 'package:flutter/material.dart';
import 'app_routes.dart';

/// Service class for centralized navigation management
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Get current context
  static BuildContext? get currentContext => navigatorKey.currentContext;

  /// Navigate to a named route
  static Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate and replace current route
  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// Navigate and clear all previous routes
  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  /// Pop current route
  static void pop<T extends Object?>([T? result]) {
    navigatorKey.currentState!.pop<T>(result);
  }

  /// Pop until specific route
  static void popUntil(String routeName) {
    navigatorKey.currentState!.popUntil(ModalRoute.withName(routeName));
  }

  /// Check if can pop
  static bool canPop() {
    return navigatorKey.currentState!.canPop();
  }

  // Convenience methods for common routes
  static Future<T?> goToHome<T extends Object?>() {
    return pushNamedAndRemoveUntil<T>(AppRoutes.home);
  }

  static Future<T?> goToLogin<T extends Object?>() {
    return pushNamedAndRemoveUntil<T>(AppRoutes.login);
  }

  static Future<T?> goToAddExpense<T extends Object?>() {
    return pushNamed<T>(AppRoutes.addExpense);
  }

  static Future<T?> goToEditExpense<T extends Object?>(dynamic expense) {
    return pushNamed<T>(
      AppRoutes.editExpense,
      arguments: {'expense': expense},
    );
  }

  static Future<T?> goToStatistics<T extends Object?>() {
    return pushNamed<T>(AppRoutes.statistics);
  }

  static Future<T?> goToAnalytics<T extends Object?>() {
    return pushNamed<T>(AppRoutes.advancedAnalytics);
  }

  static Future<T?> goToExport<T extends Object?>() {
    return pushNamed<T>(AppRoutes.exportData);
  }

  static Future<T?> goToCategories<T extends Object?>() {
    return pushNamed<T>(AppRoutes.categoryManagement);
  }

  static Future<T?> goToBudgets<T extends Object?>() {
    return pushNamed<T>(AppRoutes.budgetManagement);
  }

  static Future<T?> goToRecurringExpense<T extends Object?>() {
    return pushNamed<T>(AppRoutes.recurringExpense);
  }

  static Future<T?> goToSharedExpense<T extends Object?>() {
    return pushNamed<T>(AppRoutes.sharedExpense);
  }

  static Future<T?> goToUserProfile<T extends Object?>() {
    return pushNamed<T>(AppRoutes.userProfile);
  }
}
