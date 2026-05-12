import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:strengthlabs/core/constants/api_constants.dart';
import 'package:strengthlabs/core/demo/demo_mode.dart';
import 'package:strengthlabs/core/network/dio_client.dart';
import 'package:strengthlabs/core/storage/token_storage.dart';
import 'package:strengthlabs/features/auth/domain/entities/user.dart';

class AuthRepository {
  AuthRepository(this._dioClient, this._tokenStorage);

  final DioClient _dioClient;
  final TokenStorage _tokenStorage;

  final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  Future<User> login({
    required String email,
    required String password,
  }) async {
    if (DemoMode.credentialsMatch(email, password)) {
      DemoMode.enable();
      return DemoMode.user;
    }
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
    if (DemoMode.isActive) return DemoMode.user;
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

  Future<bool> hasStoredTokens() async {
    if (DemoMode.isActive) return true;
    return _tokenStorage.hasTokens();
  }

  Future<User> loginWithGoogle() async {
    // 1. Native Google Sign-In dialog
    final account = await _googleSignIn.signIn();
    if (account == null) throw Exception('Google Sign-In cancelled');

    // 2. Obtain the raw ID token
    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) throw Exception('Could not retrieve Google ID token');

    // 3. Exchange the ID token for our own JWT pair
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.authGoogle,
        data: {'id_token': idToken},
      );
      await _saveTokens(response.data as Map<String, dynamic>);
      return await getCurrentUser();
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<void> logout() async {
    DemoMode.disable();
    final refreshToken = await _tokenStorage.getRefreshToken();
    try {
      await _dioClient.dio.post(
        '/auth/logout',
        data: refreshToken != null ? {'refresh_token': refreshToken} : null,
      );
    } catch (_) {
      // Best-effort: even if the network call fails (offline, server down)
      // we still clear local tokens. Server-side blacklist will catch up
      // on the next successful logout or just expire naturally.
    }
    await _tokenStorage.clearTokens();
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // google_sign_in has no implementation on Linux/Windows
    }
  }

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
    if (status == 429) {
      final retryAfter = e.response?.headers.value('retry-after');
      return retryAfter != null
          ? 'Too many attempts. Try again in $retryAfter seconds.'
          : 'Too many attempts. Please wait a moment and try again.';
    }
    if (status == 400 || status == 422) {
      return 'Invalid input — please check your fields';
    }
    if (status != null && status >= 500) {
      return 'The server is having trouble. Please try again in a moment.';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'No connection — please check your internet';
    }
    return 'Something went wrong — please try again';
  }
}
