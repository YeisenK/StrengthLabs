import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strengthlabs/features/auth/data/auth_repository.dart';
import 'package:strengthlabs/features/auth/data/session_restore_result.dart';
import 'package:strengthlabs/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthInitial());

  final AuthRepository _repository;

  /// Called on app start to restore an existing session.
  ///
  /// Tolerates a flaky network: if the device is offline but we have a
  /// cached user, the app stays logged in instead of bouncing to login.
  Future<void> checkAuthStatus() async {
    final result = await _repository.restoreSession();
    switch (result) {
      case SessionRestored(:final user):
        emit(AuthAuthenticated(user));
      case SessionMissing():
      case SessionExpired():
      case SessionOfflineNoCache():
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
