import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strengthlabs_beta/features/auth/data/auth_repository.dart';
import 'package:strengthlabs_beta/features/auth/presentation/cubit/auth_state.dart';

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
    } catch (e) {
      // After a failed /auth/me the Dio interceptor has already cleared
      // tokens if the refresh also failed (401). If tokens are gone it
      // means the session is invalid → just go to login. Otherwise we
      // couldn't reach the server, so surface that to the user.
      final stillHasToken = await _repository.hasStoredTokens();
      if (stillHasToken) {
        emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
      } else {
        emit(const AuthUnauthenticated());
      }
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
