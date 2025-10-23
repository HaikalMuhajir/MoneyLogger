// lib/features/category/data/models/category_model.dart
import 'package:hive/hive.dart';
import '../../domain/entities/category_entity.dart';

part 'category_model.g.dart';

@HiveType(typeId: 0)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String id = '';

  @HiveField(1)
  String name = '';

  @HiveField(2)
  String colorHex = '';

  @HiveField(3)
  bool isPending = false;

  @HiveField(4)
  String? userId;

  @HiveField(5)
  DateTime? lastModified;

  CategoryModel();

  CategoryModel.create({
    required this.id,
    required this.name,
    required this.colorHex,
    this.isPending = false,
    this.userId,
    this.lastModified,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    String? colorHex,
    bool? isPending,
    String? userId,
    DateTime? lastModified,
  }) {
    return CategoryModel.create(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      isPending: isPending ?? this.isPending,
      userId: userId ?? this.userId,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  // Convert to Domain Entity
  Category toEntity() {
    return Category(
      id: id,
      name: name,
      colorHex: colorHex,
      isPending: isPending,
      userId: userId,
      lastModified: lastModified,
    );
  }

  // Convert from Domain Entity
  factory CategoryModel.fromEntity(Category entity) {
    return CategoryModel.create(
      id: entity.id,
      name: entity.name,
      colorHex: entity.colorHex,
      isPending: entity.isPending,
      userId: entity.userId,
      lastModified: entity.lastModified,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorHex': colorHex,
      'isPending': isPending,
      'userId': userId,
      'lastModified': lastModified?.toIso8601String(),
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel.create(
      id: map['id'] as String,
      name: map['name'] as String,
      colorHex: map['colorHex'] as String,
      isPending: map['isPending'] as bool? ?? false,
      userId: map['userId'] as String?,
      lastModified: map['lastModified'] != null
          ? DateTime.parse(map['lastModified'])
          : null,
    );
  }
}
