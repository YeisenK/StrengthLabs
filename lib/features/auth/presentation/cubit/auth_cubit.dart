import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strengthlabs_beta/features/auth/data/auth_repository.dart';
import 'package:strengthlabs_beta/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthInitial());

  final AuthRepository _repository;

  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());
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
    try {
      final user = await _repository.register(
        name: name,
        email: email,
        password: password,
      );
      emit(AuthAuthenticated(user));
    } on DioException catch (e) {
      final msg = e.response?.data?['detail'] as String? ?? 'Registration failed';
      emit(AuthError(msg));
    } catch (_) {
      emit(const AuthError('Unexpected error — please try again'));
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthUnauthenticated());
  }
}
