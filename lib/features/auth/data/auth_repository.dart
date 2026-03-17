import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/models/auth_user.dart';

const _keyToken = 'auth_token';
const _keyId = 'user_id';
const _keyEmail = 'user_email';
const _keyFirstName = 'user_first_name';
const _keyLastName = 'user_last_name';

class AuthRepository {
  final FlutterSecureStorage _storage;

  const AuthRepository(this._storage);

  /// Restores session from storage on app start.
  /// Returns null if no token is stored.
  Future<AuthUser?> restoreSession() async {
    final token = await _storage.read(key: _keyToken);
    if (token == null) return null;

    return AuthUser(
      id: await _storage.read(key: _keyId) ?? '',
      email: await _storage.read(key: _keyEmail) ?? '',
      firstName: await _storage.read(key: _keyFirstName) ?? '',
      lastName: await _storage.read(key: _keyLastName) ?? '',
      token: token,
    );
  }

  /// Authenticates the user and persists the token.
  Future<AuthUser> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email y contraseña son requeridos');
    }

    // ── Mock network delay ───────────────────────────────
    await Future.delayed(const Duration(milliseconds: 900));

    // ── TODO: replace with real API call ─────────────────
    // final res = await _dio.post('/auth/login', data: {
    //   'email': email,
    //   'password': password,
    // });
    // final user = AuthUser.fromJson(res.data);
    // await _persistUser(user);
    // return user;
    // ─────────────────────────────────────────────────────

    // Test credentials
    if (email != 'example@gmail.com' || password != 'admin123') {
      throw Exception('Credenciales incorrectas');
    }

    const user = AuthUser(
      id: 'user-001',
      email: 'example@gmail.com',
      firstName: 'Example',
      lastName: 'User',
      token: 'mock-jwt-token-abc123',
    );

    await _persistUser(user);
    return user;
  }

  /// Registers a new user and persists the session.
  Future<AuthUser> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    if (firstName.isEmpty || email.isEmpty || password.isEmpty) {
      throw Exception('Nombre, email y contraseña son requeridos');
    }
    if (!email.contains('@')) {
      throw Exception('Email inválido');
    }
    if (password.length < 6) {
      throw Exception('La contraseña debe tener al menos 6 caracteres');
    }

    // ── Mock network delay ───────────────────────────────
    await Future.delayed(const Duration(milliseconds: 1000));

    // ── TODO: replace with real API call ─────────────────
    // final res = await _dio.post('/auth/register', data: {
    //   'first_name': firstName,
    //   'last_name': lastName,
    //   'email': email,
    //   'password': password,
    // });
    // final user = AuthUser.fromJson(res.data);
    // await _persistUser(user);
    // return user;
    // ─────────────────────────────────────────────────────

    final user = AuthUser(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      firstName: firstName,
      lastName: lastName,
      token: 'mock-jwt-token-new-user',
    );

    await _persistUser(user);
    return user;
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<void> _persistUser(AuthUser user) async {
    await _storage.write(key: _keyToken, value: user.token);
    await _storage.write(key: _keyId, value: user.id);
    await _storage.write(key: _keyEmail, value: user.email);
    await _storage.write(key: _keyFirstName, value: user.firstName);
    await _storage.write(key: _keyLastName, value: user.lastName);
  }
}
