import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:strengthlabs_beta/core/constants/api_constants.dart';
import 'package:strengthlabs_beta/core/demo/demo_mode.dart';
import 'package:strengthlabs_beta/core/network/dio_client.dart';
import 'package:strengthlabs_beta/core/storage/token_storage.dart';
import 'package:strengthlabs_beta/features/auth/domain/entities/user.dart';

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
    await Future.wait([
      _tokenStorage.clearTokens(),
      _googleSignIn.signOut(),
    ]);
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
    if (status == 400 || status == 422) return 'Invalid input — please check your fields';
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Cannot reach server — check your connection';
    }
    return 'Something went wrong — please try again';
  }
}
