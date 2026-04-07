import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strengthlabs_beta/features/auth/data/auth_repository.dart';
import 'package:strengthlabs_beta/features/auth/domain/entities/user.dart';
import 'package:strengthlabs_beta/features/auth/presentation/cubit/auth_state.dart';

// Demo credentials — allow the app to run fully offline without a backend.
const _demoEmail = 'example@example.com';
const _demoPassword = 'example';
const _demoUser = User(id: 'demo', name: 'Demo User', email: _demoEmail);

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthInitial());

  final AuthRepository _repository;

  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());

    // Demo bypass — works without a backend running.
    if (email.trim().toLowerCase() == _demoEmail &&
        password == _demoPassword) {
      await Future.delayed(const Duration(milliseconds: 300));
      emit(const AuthAuthenticated(_demoUser));
      return;
    }

    try {
      final user = await _repository.login(email: email, password: password);
      emit(AuthAuthenticated(user));
    } on DioException catch (e) {
      final msg = e.response?.data?['detail'] as String? ?? 'Login failed';
      emit(AuthError(msg));
    } catch (_) {
      emit(const AuthError('Unexpected error — please try again'));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());

    // Demo registration — accept any input offline.
    final isDemoEmail = email.trim().toLowerCase() == _demoEmail;
    try {
      final user = await _repository.register(
        name: name,
        email: email,
        password: password,
      );
      emit(AuthAuthenticated(user));
    } on DioException catch (e) {
      if (isDemoEmail) {
        // Backend offline — still let demo user through.
        await Future.delayed(const Duration(milliseconds: 300));
        emit(AuthAuthenticated(User(id: 'demo', name: name, email: email)));
        return;
      }
      final msg = e.response?.data?['detail'] as String? ?? 'Registration failed';
      emit(AuthError(msg));
    } catch (_) {
      if (isDemoEmail) {
        await Future.delayed(const Duration(milliseconds: 300));
        emit(AuthAuthenticated(User(id: 'demo', name: name, email: email)));
        return;
      }
      emit(const AuthError('Unexpected error — please try again'));
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {
      // Ignore errors on logout (e.g. backend offline).
    }
    emit(const AuthUnauthenticated());
  }
}
