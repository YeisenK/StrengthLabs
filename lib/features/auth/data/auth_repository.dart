import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:strengthlabs/core/constants/api_constants.dart';
import 'package:strengthlabs/core/demo/demo_mode.dart';
import 'package:strengthlabs/core/network/dio_client.dart';
import 'package:strengthlabs/core/storage/token_storage.dart';
import 'package:strengthlabs/features/auth/data/session_restore_result.dart';
import 'package:strengthlabs/features/auth/data/user_cache.dart';
import 'package:strengthlabs/features/auth/domain/entities/user.dart';

class AuthRepository {
  AuthRepository(
    this._dioClient,
    this._tokenStorage, {
    UserCache? userCache,
    GoogleSignIn? googleSignIn,
  })  : _userCache = userCache ?? UserCache(),
        _googleSignIn =
            googleSignIn ?? GoogleSignIn(scopes: const ['email', 'profile']);

  final DioClient _dioClient;
  final TokenStorage _tokenStorage;
  final UserCache _userCache;
  final GoogleSignIn _googleSignIn;

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
      final user = await getCurrentUser();
      await _userCache.save(user);
      return user;
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
      final user = await getCurrentUser();
      await _userCache.save(user);
      return user;
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<User> getCurrentUser() async {
    if (DemoMode.isActive) return DemoMode.user;
    try {
      return await _fetchMe();
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  /// Raw `/auth/me` fetch — propagates [DioException] so callers (e.g.
  /// [restoreSession]) can branch on status codes.
  Future<User> _fetchMe() async {
    final response = await _dioClient.dio.get('/auth/me');
    final data = response.data as Map<String, dynamic>;
    return User(
      id: data['id'] as String,
      name: data['name'] as String,
      email: data['email'] as String,
    );
  }

  /// Restore a session on app start, tolerating a flaky network.
  ///
  /// Decision tree:
  /// - No token on disk → [SessionMissing].
  /// - `/auth/me` succeeds → cache + [SessionRestored].
  /// - `/auth/me` returns 401 → clear tokens + [SessionExpired].
  /// - Network error & cached user → [SessionRestored] with `fromCache: true`.
  /// - Network error & no cache → [SessionOfflineNoCache].
  Future<SessionRestoreResult> restoreSession() async {
    if (DemoMode.isActive) return const SessionRestored(DemoMode.user);
    if (!await _tokenStorage.hasTokens()) return const SessionMissing();
    try {
      final user = await _fetchMe();
      await _userCache.save(user);
      return SessionRestored(user);
    } on DioException catch (e) {
      if (_isAuthFailure(e)) {
        await _tokenStorage.clearTokens();
        await _userCache.clear();
        return const SessionExpired();
      }
      final cached = await _userCache.read();
      if (cached != null) return SessionRestored(cached, fromCache: true);
      return const SessionOfflineNoCache();
    }
  }

  Future<bool> hasStoredTokens() async {
    if (DemoMode.isActive) return true;
    return _tokenStorage.hasTokens();
  }

  Future<User> loginWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) throw Exception('Google Sign-In cancelled');

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) throw Exception('Could not retrieve Google ID token');

    try {
      final response = await _dioClient.dio.post(
        ApiConstants.authGoogle,
        data: {'id_token': idToken},
      );
      await _saveTokens(response.data as Map<String, dynamic>);
      final user = await getCurrentUser();
      await _userCache.save(user);
      return user;
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
    await _userCache.clear();
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

  bool _isAuthFailure(DioException e) {
    final status = e.response?.statusCode;
    return status == 401 || status == 403;
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
