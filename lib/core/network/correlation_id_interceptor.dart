import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

/// Tags each outgoing request with a unique `X-Request-Id` header so server
/// logs and crash reports can be correlated with a specific client action.
///
/// Honours a caller-supplied id (useful when the SyncManager retries the same
/// pending mutation — same id lets the backend log all attempts as one
/// logical request).
class CorrelationIdInterceptor extends Interceptor {
  CorrelationIdInterceptor({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  static const headerName = 'X-Request-Id';

  final Uuid _uuid;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final existing = options.headers[headerName];
    if (existing == null || (existing is String && existing.isEmpty)) {
      options.headers[headerName] = _uuid.v4();
    }
    handler.next(options);
  }
}
