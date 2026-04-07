import 'package:dio/dio.dart';
import 'package:strengthlabs_beta/core/constants/api_constants.dart';
import 'package:strengthlabs_beta/core/storage/secure_storage.dart';

class DioClient {
  DioClient(this._storage, {this.onUnauthorized}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getAccessToken();
          if (token != null) {
            options.headers[ApiConstants.tokenHeader] =
                ApiConstants.bearerToken(token);
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshed = await _tryRefresh();
            if (refreshed) {
              // Retry original request with new token
              final opts = error.requestOptions;
              final token = await _storage.getAccessToken();
              opts.headers[ApiConstants.tokenHeader] =
                  ApiConstants.bearerToken(token!);
              try {
                final retried = await _dio.fetch(opts);
                handler.resolve(retried);
                return;
              } catch (_) {}
            }
            // Refresh failed — clear tokens and notify app
            await _storage.clearTokens();
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  late final Dio _dio;
  final SecureStorage _storage;

  /// Called when refresh fails so the app can redirect to login.
  final void Function()? onUnauthorized;

  Dio get dio => _dio;

  Future<bool> _tryRefresh() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) return false;
    try {
      // Use a bare Dio to avoid recursive interceptor calls
      final resp = await Dio().post(
        '${ApiConstants.baseUrl}${ApiConstants.refresh}',
        data: {'refresh_token': refreshToken},
      );
      await _storage.saveTokens(
        accessToken: resp.data['access_token'] as String,
        refreshToken: resp.data['refresh_token'] as String,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
