class AppConstants {
  // Hive Box Names
  static const String categoriesBox = 'categories';
  static const String expensesBox = 'expenses';

  // Firebase Collections
  static const String categoriesCollection = 'categories';
  static const String expensesCollection = 'expenses';
  static const String budgetsCollection = 'budgets';
  static const String recurringExpensesCollection = 'recurring_expenses';
  static const String sharedExpensesCollection = 'shared_expenses';
  static const String userProfilesCollection = 'user_profiles';

  // Default Categories
  static const List<Map<String, dynamic>> defaultCategories = [
    {'name': 'Makanan', 'colorHex': '#FF6B6B'},
    {'name': 'Transportasi', 'colorHex': '#4ECDC4'},
    {'name': 'Belanja', 'colorHex': '#45B7D1'},
    {'name': 'Hiburan', 'colorHex': '#96CEB4'},
    {'name': 'Kesehatan', 'colorHex': '#FFEAA7'},
    {'name': 'Lainnya', 'colorHex': '#DDA0DD'},
  ];
}
