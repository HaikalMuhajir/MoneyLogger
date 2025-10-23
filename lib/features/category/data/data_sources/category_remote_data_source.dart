// lib/features/category/data/data_sources/category_remote_data_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../../../../core/util/constants.dart';

abstract class CategoryRemoteDataSource {
  Stream<List<CategoryModel>> getCategories(String userId);
  Future<void> addCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String categoryId);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final FirebaseFirestore _firestore;

  CategoryRemoteDataSourceImpl(this._firestore);

  @override
  Stream<List<CategoryModel>> getCategories(String userId) {
    return _firestore
        .collection(AppConstants.categoriesCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data()))
          .toList();
    });
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    await _firestore
        .collection(AppConstants.categoriesCollection)
        .doc(category.id)
        .set(category.toMap());
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    await _firestore
        .collection(AppConstants.categoriesCollection)
        .doc(category.id)
        .update(category.toMap());
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await _firestore
        .collection(AppConstants.categoriesCollection)
        .doc(categoryId)
        .delete();
  }
}
