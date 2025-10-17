import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;

  Future<String?> signUp(String email, String password);
  Future<String?> signIn(String email, String password);
  Future<void> signOut();
}
