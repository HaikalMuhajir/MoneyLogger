// lib/features/category/data/repository/category_repository_impl.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repository/category_repository.dart';
import '../../domain/entities/category_entity.dart';
import '../data_sources/category_local_data_source.dart';
import '../data_sources/category_remote_data_source.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource _localDataSource;
  final CategoryRemoteDataSource _remoteDataSource;

  CategoryRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Stream<List<Category>> getCategories(String userId) {
    return _remoteDataSource.getCategories(userId).map((models) {
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<void> addCategory(Category category) async {
    final model = CategoryModel.fromEntity(category);

    // Save to local first
    await _localDataSource.addCategory(model);

    // Then sync to remote
    try {
      await _remoteDataSource.addCategory(model);
    } catch (e) {
      // Mark as pending if sync fails
      final pendingModel = model.copyWith(isPending: true);
      await _localDataSource.updateCategory(pendingModel);
      rethrow;
    }
  }

  @override
  Future<void> updateCategory(Category category) async {
    final model = CategoryModel.fromEntity(category);

    // Update local first
    await _localDataSource.updateCategory(model);

    // Then sync to remote
    try {
      await _remoteDataSource.updateCategory(model);
    } catch (e) {
      // Mark as pending if sync fails
      final pendingModel = model.copyWith(isPending: true);
      await _localDataSource.updateCategory(pendingModel);
      rethrow;
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    // Delete from local first
    await _localDataSource.deleteCategory(categoryId);

    // Then sync to remote
    try {
      await _remoteDataSource.deleteCategory(categoryId);
    } catch (e) {
      // If sync fails, we can't recover the deleted local data
      // This is a limitation of the current implementation
      rethrow;
    }
  }

  @override
  Future<void> syncCategories(String userId) async {
    try {
      // Get remote categories
      final remoteCategories =
          await _remoteDataSource.getCategories(userId).first;

      // Save to local
      await _localDataSource.saveCategories(remoteCategories);
    } catch (e) {
      // Handle sync error
      rethrow;
    }
  }
}

// Providers
final categoryLocalDataSourceProvider =
    Provider<CategoryLocalDataSource>((ref) {
  return CategoryLocalDataSourceImpl();
});

final categoryRemoteDataSourceProvider =
    Provider<CategoryRemoteDataSource>((ref) {
  return CategoryRemoteDataSourceImpl(FirebaseFirestore.instance);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final localDataSource = ref.watch(categoryLocalDataSourceProvider);
  final remoteDataSource = ref.watch(categoryRemoteDataSourceProvider);
  return CategoryRepositoryImpl(localDataSource, remoteDataSource);
});
