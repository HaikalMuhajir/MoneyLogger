// lib/features/category/data/data_sources/category_local_data_source.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/category_model.dart';
import '../../../../core/util/constants.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<void> addCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String categoryId);
  Future<void> saveCategories(List<CategoryModel> categories);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  late Box<CategoryModel> _box;

  CategoryLocalDataSourceImpl() {
    _box = Hive.box<CategoryModel>(AppConstants.categoriesBox);
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    return _box.values.toList();
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    await _box.put(category.id, category);
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    await _box.put(category.id, category);
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await _box.delete(categoryId);
  }

  @override
  Future<void> saveCategories(List<CategoryModel> categories) async {
    await _box.clear();
    for (final category in categories) {
      await _box.put(category.id, category);
    }
  }
}
