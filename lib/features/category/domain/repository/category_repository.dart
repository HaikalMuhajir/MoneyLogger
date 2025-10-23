// lib/features/category/domain/repository/category_repository.dart
import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Stream<List<Category>> getCategories(String userId);
  Future<void> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String categoryId);
  Future<void> syncCategories(String userId);
}
