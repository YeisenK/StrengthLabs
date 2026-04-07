import 'package:strengthlabs_beta/features/auth/domain/entities/user.dart';

class AuthRepository {
  const AuthRepository();

  static const _demoEmail = 'example@example.com';
  static const _demoPassword = 'example';

  Future<User> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (email.trim().toLowerCase() == _demoEmail &&
        password == _demoPassword) {
      return const User(id: 'demo', name: 'Demo User', email: _demoEmail);
    }
    throw Exception('Invalid email or password');
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
    );
  }

  Future<void> logout() async {}
}
