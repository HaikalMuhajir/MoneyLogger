// lib/features/recurring_expense/domain/entities/recurring_expense_entity.dart
class RecurringExpense {
  final String id;
  final String userId;
  final String categoryId;
  final String description;
  final double amount;
  final RecurringFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? nextDueDate;
  final bool isActive;
  final String? reminderNote;
  final DateTime createdAt;
  final DateTime? lastExecuted;

  RecurringExpense({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.description,
    required this.amount,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.nextDueDate,
    this.isActive = true,
    this.reminderNote,
    required this.createdAt,
    this.lastExecuted,
  });

  RecurringExpense copyWith({
    String? id,
    String? userId,
    String? categoryId,
    String? description,
    double? amount,
    RecurringFrequency? frequency,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextDueDate,
    bool? isActive,
    String? reminderNote,
    DateTime? createdAt,
    DateTime? lastExecuted,
  }) {
    return RecurringExpense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isActive: isActive ?? this.isActive,
      reminderNote: reminderNote ?? this.reminderNote,
      createdAt: createdAt ?? this.createdAt,
      lastExecuted: lastExecuted ?? this.lastExecuted,
    );
  }

  DateTime calculateNextDueDate() {
    DateTime next = nextDueDate ?? startDate;

    switch (frequency) {
      case RecurringFrequency.daily:
        return next.add(const Duration(days: 1));
      case RecurringFrequency.weekly:
        return next.add(const Duration(days: 7));
      case RecurringFrequency.monthly:
        return DateTime(next.year, next.month + 1, next.day);
      case RecurringFrequency.quarterly:
        return DateTime(next.year, next.month + 3, next.day);
      case RecurringFrequency.yearly:
        return DateTime(next.year + 1, next.month, next.day);
    }
  }

  bool get isDue {
    if (!isActive) return false;
    final now = DateTime.now();
    return nextDueDate != null && now.isAfter(nextDueDate!);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'categoryId': categoryId,
      'description': description,
      'amount': amount,
      'frequency': frequency.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'nextDueDate': nextDueDate?.toIso8601String(),
      'isActive': isActive,
      'reminderNote': reminderNote,
      'createdAt': createdAt.toIso8601String(),
      'lastExecuted': lastExecuted?.toIso8601String(),
    };
  }

  factory RecurringExpense.fromMap(Map<String, dynamic> map) {
    return RecurringExpense(
      id: map['id'] as String,
      userId: map['userId'] as String,
      categoryId: map['categoryId'] as String,
      description: map['description'] as String,
      amount: map['amount'] as double,
      frequency: RecurringFrequency.values.firstWhere(
        (e) => e.name == map['frequency'],
        orElse: () => RecurringFrequency.monthly,
      ),
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      nextDueDate: map['nextDueDate'] != null
          ? DateTime.parse(map['nextDueDate'])
          : null,
      isActive: map['isActive'] as bool? ?? true,
      reminderNote: map['reminderNote'] as String?,
      createdAt: DateTime.parse(map['createdAt']),
      lastExecuted: map['lastExecuted'] != null
          ? DateTime.parse(map['lastExecuted'])
          : null,
    );
  }
}

enum RecurringFrequency {
  daily,
  weekly,
  monthly,
  quarterly,
  yearly,
}
