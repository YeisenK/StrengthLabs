import 'package:dio/dio.dart';
import 'package:strengthlabs_beta/core/network/dio_client.dart';
import 'package:strengthlabs_beta/core/storage/token_storage.dart';
import 'package:strengthlabs_beta/features/auth/domain/entities/user.dart';

class AuthRepository {
  const AuthRepository(this._dioClient, this._tokenStorage);

  final DioClient _dioClient;
  final TokenStorage _tokenStorage;

  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      await _saveTokens(response.data);
      return await getCurrentUser();
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );
      await _saveTokens(response.data);
      return await getCurrentUser();
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _dioClient.dio.get('/auth/me');
      final data = response.data as Map<String, dynamic>;
      return User(
        id: data['id'] as String,
        name: data['name'] as String,
        email: data['email'] as String,
      );
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<bool> hasStoredTokens() => _tokenStorage.hasTokens();

  Future<void> logout() => _tokenStorage.clearTokens();

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    await _tokenStorage.saveTokens(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
    );
  }

  String _mapError(DioException e) {
    final status = e.response?.statusCode;
    if (status == 401) return 'Invalid email or password';
    if (status == 409) return 'Email already registered';
    if (status == 400 || status == 422) return 'Invalid input — please check your fields';
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Cannot reach server — check your connection';
    }
    return 'Something went wrong — please try again';
  }
}
