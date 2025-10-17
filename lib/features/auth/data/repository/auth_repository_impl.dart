import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repository/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';
import '../../domain/entities/user_entity.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  // Memetakan objek User dari Firebase ke UserEntity milik Domain
  Stream<UserEntity?> get authStateChanges {
    return _remoteDataSource.authStateChanges.map((user) {
      if (user != null) {
        return UserEntity.fromFirebaseUser(user);
      }
      return null;
    });
  }

  // --- Implementasi Fungsi ---

  @override
  Future<String?> signUp(String email, String password) async {
    try {
      await _remoteDataSource.signUp(email, password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseAuthError(e.code);
    }
  }

  @override
  Future<String?> signIn(String email, String password) async {
    try {
      await _remoteDataSource.signIn(email, password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseAuthError(e.code);
    }
  }

  @override
  Future<void> signOut() async {
    await _remoteDataSource.signOut();
  }

  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'weak-password':
        return 'Password terlalu lemah.';
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar.';
      case 'user-not-found':
      case 'wrong-password':
        return 'Kombinasi email/password salah.';
      default:
        return 'Otentikasi gagal. Code: $code';
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});
