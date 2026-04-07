import 'package:dio/dio.dart';
import 'package:strengthlabs_beta/core/constants/api_constants.dart';
import 'package:strengthlabs_beta/core/storage/secure_storage.dart';

class DioClient {
  late final Dio _dio;

  DioClient(SecureStorage storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.getAccessToken();
          if (token != null) {
            options.headers[ApiConstants.tokenHeader] =
                ApiConstants.bearerToken(token);
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // TODO: handle 401 — refresh token then retry
          handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
