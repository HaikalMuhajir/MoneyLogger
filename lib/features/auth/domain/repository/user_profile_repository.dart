// lib/features/auth/domain/repository/user_profile_repository.dart
import '../entities/user_profile_entity.dart';

abstract class UserProfileRepository {
  Future<UserProfile?> getUserProfile(String uid);
  Future<void> createUserProfile(UserProfile profile);
  Future<void> updateUserProfile(UserProfile profile);
  Future<void> deleteUserProfile(String uid);
  Future<void> updateLastLogin(String uid);
  Future<void> updatePreferences(String uid, Map<String, dynamic> preferences);
}
