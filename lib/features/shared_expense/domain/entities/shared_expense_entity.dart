// lib/features/shared_expense/domain/entities/shared_expense_entity.dart
class SharedExpense {
  final String id;
  final String title;
  final String description;
  final double totalAmount;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? settledAt;
  final List<SharedExpenseParticipant> participants;
  final List<SharedExpenseItem> items;
  final SharedExpenseStatus status;

  SharedExpense({
    required this.id,
    required this.title,
    required this.description,
    required this.totalAmount,
    required this.createdBy,
    required this.createdAt,
    this.settledAt,
    required this.participants,
    required this.items,
    this.status = SharedExpenseStatus.active,
  });

  SharedExpense copyWith({
    String? id,
    String? title,
    String? description,
    double? totalAmount,
    String? createdBy,
    DateTime? createdAt,
    DateTime? settledAt,
    List<SharedExpenseParticipant>? participants,
    List<SharedExpenseItem>? items,
    SharedExpenseStatus? status,
  }) {
    return SharedExpense(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      totalAmount: totalAmount ?? this.totalAmount,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      settledAt: settledAt ?? this.settledAt,
      participants: participants ?? this.participants,
      items: items ?? this.items,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'totalAmount': totalAmount,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'settledAt': settledAt?.toIso8601String(),
      'participants': participants.map((p) => p.toMap()).toList(),
      'items': items.map((i) => i.toMap()).toList(),
      'status': status.name,
    };
  }

  factory SharedExpense.fromMap(Map<String, dynamic> map) {
    return SharedExpense(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      totalAmount: map['totalAmount'] as double,
      createdBy: map['createdBy'] as String,
      createdAt: DateTime.parse(map['createdAt']),
      settledAt:
          map['settledAt'] != null ? DateTime.parse(map['settledAt']) : null,
      participants: (map['participants'] as List)
          .map((p) => SharedExpenseParticipant.fromMap(p))
          .toList(),
      items: (map['items'] as List)
          .map((i) => SharedExpenseItem.fromMap(i))
          .toList(),
      status: SharedExpenseStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SharedExpenseStatus.active,
      ),
    );
  }
}

class SharedExpenseParticipant {
  final String userId;
  final String email;
  final String? displayName;
  final double amountOwed;
  final double amountPaid;
  final bool isSettled;

  SharedExpenseParticipant({
    required this.userId,
    required this.email,
    this.displayName,
    required this.amountOwed,
    this.amountPaid = 0.0,
    this.isSettled = false,
  });

  SharedExpenseParticipant copyWith({
    String? userId,
    String? email,
    String? displayName,
    double? amountOwed,
    double? amountPaid,
    bool? isSettled,
  }) {
    return SharedExpenseParticipant(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      amountOwed: amountOwed ?? this.amountOwed,
      amountPaid: amountPaid ?? this.amountPaid,
      isSettled: isSettled ?? this.isSettled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'amountOwed': amountOwed,
      'amountPaid': amountPaid,
      'isSettled': isSettled,
    };
  }

  factory SharedExpenseParticipant.fromMap(Map<String, dynamic> map) {
    return SharedExpenseParticipant(
      userId: map['userId'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String?,
      amountOwed: map['amountOwed'] as double,
      amountPaid: map['amountPaid'] as double? ?? 0.0,
      isSettled: map['isSettled'] as bool? ?? false,
    );
  }
}

class SharedExpenseItem {
  final String id;
  final String description;
  final double amount;
  final String paidBy;
  final List<String> sharedBy;

  SharedExpenseItem({
    required this.id,
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.sharedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'paidBy': paidBy,
      'sharedBy': sharedBy,
    };
  }

  factory SharedExpenseItem.fromMap(Map<String, dynamic> map) {
    return SharedExpenseItem(
      id: map['id'] as String,
      description: map['description'] as String,
      amount: map['amount'] as double,
      paidBy: map['paidBy'] as String,
      sharedBy: List<String>.from(map['sharedBy']),
    );
  }
}

enum SharedExpenseStatus {
  active,
  settled,
  cancelled,
}
