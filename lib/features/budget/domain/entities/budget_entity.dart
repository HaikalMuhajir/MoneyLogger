// lib/features/budget/domain/entities/budget_entity.dart
class Budget {
  final String id;
  final String userId;
  final String name;
  final String? categoryId;
  final double totalAmount;
  final double spentAmount;
  final DateTime startDate;
  final DateTime endDate;
  final BudgetPeriod period;
  final BudgetStatus status;
  final DateTime createdAt;
  final DateTime? lastUpdated;

  Budget({
    required this.id,
    required this.userId,
    required this.name,
    this.categoryId,
    required this.totalAmount,
    this.spentAmount = 0.0,
    required this.startDate,
    required this.endDate,
    required this.period,
    this.status = BudgetStatus.active,
    required this.createdAt,
    this.lastUpdated,
  });

  Budget copyWith({
    String? id,
    String? userId,
    String? name,
    String? categoryId,
    double? totalAmount,
    double? spentAmount,
    DateTime? startDate,
    DateTime? endDate,
    BudgetPeriod? period,
    BudgetStatus? status,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return Budget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      totalAmount: totalAmount ?? this.totalAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      period: period ?? this.period,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  double get remainingAmount => totalAmount - spentAmount;
  double get spentPercentage =>
      totalAmount > 0 ? (spentAmount / totalAmount) * 100 : 0;
  bool get isOverBudget => spentAmount > totalAmount;
  bool get isNearLimit => spentPercentage >= 80;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'categoryId': categoryId,
      'totalAmount': totalAmount,
      'spentAmount': spentAmount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'period': period.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as String,
      userId: map['userId'] as String,
      name: map['name'] as String,
      categoryId: map['categoryId'] as String?,
      totalAmount: map['totalAmount'] as double,
      spentAmount: map['spentAmount'] as double? ?? 0.0,
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      period: BudgetPeriod.values.firstWhere(
        (e) => e.name == map['period'],
        orElse: () => BudgetPeriod.monthly,
      ),
      status: BudgetStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BudgetStatus.active,
      ),
      createdAt: DateTime.parse(map['createdAt']),
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'])
          : null,
    );
  }
}

class BudgetAlert {
  final String id;
  final String budgetId;
  final String userId;
  final BudgetAlertType type;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  BudgetAlert({
    required this.id,
    required this.budgetId,
    required this.userId,
    required this.type,
    required this.message,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'budgetId': budgetId,
      'userId': userId,
      'type': type.name,
      'message': message,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BudgetAlert.fromMap(Map<String, dynamic> map) {
    return BudgetAlert(
      id: map['id'] as String,
      budgetId: map['budgetId'] as String,
      userId: map['userId'] as String,
      type: BudgetAlertType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => BudgetAlertType.warning,
      ),
      message: map['message'] as String,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

enum BudgetPeriod {
  weekly,
  monthly,
  quarterly,
  yearly,
}

enum BudgetStatus {
  active,
  paused,
  completed,
  cancelled,
}

enum BudgetAlertType {
  warning,
  exceeded,
  nearLimit,
  completed,
}
