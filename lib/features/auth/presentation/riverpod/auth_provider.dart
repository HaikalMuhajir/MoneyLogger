import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_logger/features/auth/data/repository/auth_repository_impl.dart';
import '../../domain/repository/auth_repository.dart';
import '../../domain/entities/user_entity.dart';

class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? errorMessage;

  AuthState({this.user, this.isLoading = false, this.errorMessage});

  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState()) {
    // 1. Dengarkan stream status Auth dari Repository
    _repository.authStateChanges.listen((userEntity) {
      state = state.copyWith(
          user: userEntity, isLoading: false, errorMessage: null);
    });
  }

  Future<void> signUp(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final error = await _repository.signUp(email, password);

    if (error != null) {
      state = state.copyWith(isLoading: false, errorMessage: error);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final error = await _repository.signIn(email, password);

    if (error != null) {
      state = state.copyWith(isLoading: false, errorMessage: error);
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
