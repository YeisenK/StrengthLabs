import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:strengthlabs_beta/core/constants/api_constants.dart';
import 'package:strengthlabs_beta/core/storage/token_storage.dart';

class DioClient {
  DioClient(this._tokenStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(_AuthInterceptor(_tokenStorage));
  }

  final TokenStorage _tokenStorage;
  late final Dio _dio;

  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._tokenStorage);

  final TokenStorage _tokenStorage;

  // separate instance — avoids re-triggering this interceptor
  final _refreshDio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Completer<bool>? _refreshCompleter;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // proactive refresh before 401
    if (_refreshCompleter == null &&
        await _tokenStorage.isAccessTokenExpired()) {
      await _tryRefresh();
    } else if (_refreshCompleter != null) {
      await _refreshCompleter!.future;
    }

    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final newToken = await _tokenStorage.getAccessToken();
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newToken';
        try {
          final retryResponse = await _refreshDio.fetch(opts);
          handler.resolve(retryResponse);
          return;
        } on DioException catch (retryErr) {
          handler.next(retryErr);
          return;
        }
      }
    }
    handler.next(err);
  }

  Future<bool> _tryRefresh() async {
    // Coalesce concurrent refreshes.
    final inFlight = _refreshCompleter;
    if (inFlight != null) return inFlight.future;

    final completer = Completer<bool>();
    _refreshCompleter = completer;
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        await _tokenStorage.clearTokens();
        completer.complete(false);
        return false;
      }

      final response = await _refreshDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      await _tokenStorage.saveTokens(
        accessToken: response.data['access_token'] as String,
        refreshToken: response.data['refresh_token'] as String,
      );
      completer.complete(true);
      return true;
    } catch (e, stack) {
      debugPrint('Token refresh failed: $e');
      debugPrintStack(stackTrace: stack);
      await _tokenStorage.clearTokens();
      completer.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }
}
