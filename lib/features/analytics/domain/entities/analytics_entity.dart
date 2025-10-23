// lib/features/analytics/domain/entities/analytics_entity.dart
class ExpenseAnalytics {
  final String userId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double totalExpenses;
  final double averageDailyExpense;
  final double averageMonthlyExpense;
  final List<CategoryAnalytics> categoryBreakdown;
  final List<DailyAnalytics> dailyBreakdown;
  final List<MonthlyAnalytics> monthlyBreakdown;
  final ExpenseTrends trends;
  final List<ExpenseInsight> insights;

  ExpenseAnalytics({
    required this.userId,
    required this.periodStart,
    required this.periodEnd,
    required this.totalExpenses,
    required this.averageDailyExpense,
    required this.averageMonthlyExpense,
    required this.categoryBreakdown,
    required this.dailyBreakdown,
    required this.monthlyBreakdown,
    required this.trends,
    required this.insights,
  });
}

class CategoryAnalytics {
  final String categoryId;
  final String categoryName;
  final String categoryColor;
  final double totalAmount;
  final double percentage;
  final int transactionCount;
  final double averageAmount;
  final ExpenseTrend trend;

  CategoryAnalytics({
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.totalAmount,
    required this.percentage,
    required this.transactionCount,
    required this.averageAmount,
    required this.trend,
  });
}

class DailyAnalytics {
  final DateTime date;
  final double totalAmount;
  final int transactionCount;
  final List<String> categories;

  DailyAnalytics({
    required this.date,
    required this.totalAmount,
    required this.transactionCount,
    required this.categories,
  });
}

class MonthlyAnalytics {
  final int year;
  final int month;
  final double totalAmount;
  final int transactionCount;
  final double averageDailyAmount;
  final List<String> topCategories;

  MonthlyAnalytics({
    required this.year,
    required this.month,
    required this.totalAmount,
    required this.transactionCount,
    required this.averageDailyAmount,
    required this.topCategories,
  });
}

class ExpenseTrends {
  final double weeklyChange;
  final double monthlyChange;
  final double yearlyChange;
  final TrendDirection direction;
  final List<double> weeklyData;
  final List<double> monthlyData;

  ExpenseTrends({
    required this.weeklyChange,
    required this.monthlyChange,
    required this.yearlyChange,
    required this.direction,
    required this.weeklyData,
    required this.monthlyData,
  });
}

class ExpenseInsight {
  final String id;
  final String title;
  final String description;
  final InsightType type;
  final double? value;
  final String? categoryId;
  final DateTime generatedAt;

  ExpenseInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.value,
    this.categoryId,
    required this.generatedAt,
  });
}

enum ExpenseTrend {
  increasing,
  decreasing,
  stable,
}

enum TrendDirection {
  up,
  down,
  stable,
}

enum InsightType {
  spendingPattern,
  categoryAlert,
  budgetWarning,
  savingOpportunity,
  unusualSpending,
}
