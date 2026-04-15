import 'package:dio/dio.dart';
import 'package:strengthlabs_beta/core/constants/api_constants.dart';

/// Fetches and caches the server's RSA public key in JWKS format.
///
/// The JWKS endpoint (`GET /auth/.well-known/jwks.json`) returns the server's
/// RSA-2048 public key so that clients can verify token signatures locally
/// without a round-trip, or simply cache the key for auditing purposes.
///
/// Usage: call [fetch] once at startup via [JwksService.instance]; the result
/// is cached for the session so subsequent calls are free.
class JwksService {
  JwksService._(this._dio);

  final Dio _dio;
  Map<String, dynamic>? _cached;

  static JwksService? _instance;

  static JwksService init(Dio dio) {
    _instance = JwksService._(dio);
    return _instance!;
  }

  static JwksService get instance {
    assert(_instance != null, 'JwksService.init() must be called first');
    return _instance!;
  }

  /// Returns the raw JWKS document.
  ///
  /// `{ "keys": [ { "kty": "RSA", "alg": "RS256", "use": "sig", "n": "...", "e": "..." } ] }`
  Future<Map<String, dynamic>> fetch({bool forceRefresh = false}) async {
    if (_cached != null && !forceRefresh) return _cached!;

    final response = await _dio.get(ApiConstants.jwks);
    _cached = Map<String, dynamic>.from(response.data as Map);
    return _cached!;
  }

  /// Returns the first RSA key entry from the JWKS, or `null` if unavailable.
  Future<Map<String, dynamic>?> firstKey({bool forceRefresh = false}) async {
    try {
      final jwks = await fetch(forceRefresh: forceRefresh);
      final keys = jwks['keys'] as List<dynamic>?;
      if (keys == null || keys.isEmpty) return null;
      return Map<String, dynamic>.from(keys.first as Map);
    } catch (_) {
      return null;
    }
  }

  /// Clears the cached JWKS (call after key rotation).
  void invalidate() => _cached = null;
}
