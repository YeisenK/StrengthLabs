import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strengthlabs/features/auth/data/auth_repository.dart';
import 'package:strengthlabs/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthInitial());

  final AuthRepository _repository;

  /// Called on app start to restore an existing session.
  Future<void> checkAuthStatus() async {
    final hasToken = await _repository.hasStoredTokens();
    if (!hasToken) {
      emit(const AuthUnauthenticated());
      return;
    }
    try {
      final user = await _repository.getCurrentUser();
      emit(AuthAuthenticated(user));
    } catch (_) {
      // If session restoration fails for any reason, clear tokens and go to
      // login silently — showing an error on startup before the user has
      // done anything is confusing.
      try {
        await _repository.logout();
      } catch (_) {}
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.login(email: email, password: password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.register(
        name: name,
        email: email,
        password: password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> loginWithGoogle() async {
    emit(const AuthLoading());
    try {
      final user = await _repository.loginWithGoogle();
      emit(AuthAuthenticated(user));
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      // Cancelled sign-in is not an error worth surfacing
      if (message == 'Google Sign-In cancelled') {
        emit(const AuthUnauthenticated());
      } else {
        emit(AuthError(message));
      }
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthUnauthenticated());
  }
}
