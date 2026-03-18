import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/models/training_metrics.dart';
import '../../auth/providers/auth_provider.dart';

class MetricsRepository {
  final http.Client client;
  final String baseUrl;
  final String token;

  const MetricsRepository({
    required this.client,
    required this.baseUrl,
    required this.token,
  });

  Future<TrainingMetrics> fetchDashboard() async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/dashboard'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }

    final Map<String, dynamic> jsonMap =
        jsonDecode(response.body) as Map<String, dynamic>;

    return TrainingMetrics.fromJson(jsonMap);
  }
}

final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

final metricsRepositoryProvider = Provider<MetricsRepository>((ref) {
  final authState = ref.watch(authProvider);

  if (authState is! AuthAuthenticated) {
    throw Exception('Usuario no autenticado');
  }

  return MetricsRepository(
    client: ref.watch(httpClientProvider),
    baseUrl: const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:8080',
    ),
    token: authState.user.token,
  );
});

final metricsProvider = FutureProvider<TrainingMetrics>((ref) async {
  return ref.watch(metricsRepositoryProvider).fetchDashboard();
});