class Expense {
  final String id;
  final double amount;
  final String categoryId;
  final String description;
  final DateTime createdAt;
  final String? userId;
  final bool isPending;
  final DateTime? lastModified;

  Expense({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.description,
    required this.createdAt,
    this.userId,
    this.isPending = false,
    this.lastModified,
  });

  Expense copyWith({
    String? id,
    double? amount,
    String? categoryId,
    String? description,
    DateTime? createdAt,
    String? userId,
    bool? isPending,
    DateTime? lastModified,
  }) {
    return Expense(
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

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
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
