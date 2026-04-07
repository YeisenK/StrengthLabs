import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strengthlabs_beta/features/auth/domain/entities/user.dart';
import 'package:strengthlabs_beta/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial());

  // Mock user — replace with real API calls when backend is ready
  static const _mockUser = User(
    id: '1',
    name: 'Example User',
    email: 'example@example.com',
  );

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 800)); // simulate network

    // TODO: call AuthRepository.login(email, password)
    // Store tokens via SecureStorage, then emit authenticated
    emit(const AuthAuthenticated(_mockUser));
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 800));

    // TODO: call AuthRepository.register(name, email, password)
    emit(const AuthAuthenticated(_mockUser));
  }

  Future<void> logout() async {
    // TODO: clear tokens from SecureStorage
    emit(const AuthUnauthenticated());
  }
}
