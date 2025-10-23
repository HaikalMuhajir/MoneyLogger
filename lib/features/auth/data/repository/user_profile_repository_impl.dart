// lib/features/auth/data/repository/user_profile_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repository/user_profile_repository.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../../../core/util/constants.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final FirebaseFirestore _firestore;

  UserProfileRepositoryImpl(this._firestore);

  @override
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.userProfilesCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserProfile.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  @override
  Future<void> createUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection(AppConstants.userProfilesCollection)
          .doc(profile.uid)
          .set(profile.toMap());
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection(AppConstants.userProfilesCollection)
          .doc(profile.uid)
          .update(profile.toMap());
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<void> deleteUserProfile(String uid) async {
    try {
      await _firestore
          .collection(AppConstants.userProfilesCollection)
          .doc(uid)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }

  @override
  Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore
          .collection(AppConstants.userProfilesCollection)
          .doc(uid)
          .update({
        'lastLoginAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update last login: $e');
    }
  }

  @override
  Future<void> updatePreferences(
      String uid, Map<String, dynamic> preferences) async {
    try {
      await _firestore
          .collection(AppConstants.userProfilesCollection)
          .doc(uid)
          .update({
        'preferences': preferences,
      });
    } catch (e) {
      throw Exception('Failed to update preferences: $e');
    }
  }
}

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepositoryImpl(FirebaseFirestore.instance);
});
