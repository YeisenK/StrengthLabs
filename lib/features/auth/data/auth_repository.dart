import 'package:strengthlabs_beta/core/constants/api_constants.dart';
import 'package:strengthlabs_beta/core/network/dio_client.dart';
import 'package:strengthlabs_beta/core/storage/secure_storage.dart';
import 'package:strengthlabs_beta/features/auth/domain/entities/user.dart';

class AuthRepository {
  const AuthRepository(this._client, this._storage);

  final DioClient _client;
  final SecureStorage _storage;

  Future<User> login({required String email, required String password}) async {
    final resp = await _client.dio.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    await _saveTokens(resp.data);
    return _fetchMe();
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final resp = await _client.dio.post(
      ApiConstants.register,
      data: {'name': name, 'email': email, 'password': password},
    );
    await _saveTokens(resp.data);
    return _fetchMe();
  }

  Future<User> getMe() => _fetchMe();

  Future<void> logout() => _storage.clearTokens();

  // ── helpers ────────────────────────────────────────────────────────────────

  Future<void> _saveTokens(Map<String, dynamic> data) =>
      _storage.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );

  Future<User> _fetchMe() async {
    final resp = await _client.dio.get(ApiConstants.me);
    final d = resp.data as Map<String, dynamic>;
    return User(
      id: d['id'] as String,
      name: d['name'] as String,
      email: d['email'] as String,
    );
  }
}
