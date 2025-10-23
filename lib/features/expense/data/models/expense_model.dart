// lib/features/expense/data/models/expense_model.dart
import 'package:hive/hive.dart';
import '../../domain/entities/expense_entity.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 1)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  String id = '';

  @HiveField(1)
  double amount = 0.0;

  @HiveField(2)
  String categoryId = '';

  @HiveField(3)
  String description = '';

  @HiveField(4)
  DateTime createdAt = DateTime.now();

  @HiveField(5)
  String? userId;

  @HiveField(6)
  bool isPending = false;

  @HiveField(7)
  DateTime? lastModified;

  ExpenseModel();

  ExpenseModel.create({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.description,
    required this.createdAt,
    this.userId,
    this.isPending = false,
    this.lastModified,
  });

  ExpenseModel copyWith({
    String? id,
    double? amount,
    String? categoryId,
    String? description,
    DateTime? createdAt,
    String? userId,
    bool? isPending,
    DateTime? lastModified,
  }) {
    return ExpenseModel.create(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      isPending: isPending ?? this.isPending,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  // Convert to Domain Entity
  Expense toEntity() {
    return Expense(
      id: id,
      amount: amount,
      categoryId: categoryId,
      description: description,
      createdAt: createdAt,
      userId: userId,
      isPending: isPending,
      lastModified: lastModified,
    );
  }

  // Convert from Domain Entity
  factory ExpenseModel.fromEntity(Expense entity) {
    return ExpenseModel.create(
      id: entity.id,
      amount: entity.amount,
      categoryId: entity.categoryId,
      description: entity.description,
      createdAt: entity.createdAt,
      userId: entity.userId,
      isPending: entity.isPending,
      lastModified: entity.lastModified,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'categoryId': categoryId,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
      'isPending': isPending,
      'lastModified': lastModified?.toIso8601String(),
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel.create(
      id: map['id'] as String,
      amount: map['amount'] as double,
      categoryId: map['categoryId'] as String,
      description: map['description'] as String,
      createdAt: DateTime.parse(map['createdAt']),
      userId: map['userId'] as String?,
      isPending: map['isPending'] as bool? ?? false,
      lastModified: map['lastModified'] != null
          ? DateTime.parse(map['lastModified'])
          : null,
    );
  }
}
