import 'package:dio/dio.dart';
import 'package:strengthlabs_beta/core/constants/api_constants.dart';

// Fetches and in-memory caches the server JWKS (GET /auth/.well-known/jwks.json).
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

  Future<Map<String, dynamic>> fetch({bool forceRefresh = false}) async {
    if (_cached != null && !forceRefresh) return _cached!;

    final response = await _dio.get(ApiConstants.jwks);
    _cached = Map<String, dynamic>.from(response.data as Map);
    return _cached!;
  }

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

  void invalidate() => _cached = null; // call after key rotation
}
