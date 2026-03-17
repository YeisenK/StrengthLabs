import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/training_metrics.dart';

// ─────────────────────────────────────────────────────────
// REPOSITORY
// TODO: inject Dio and fetch from real API:
//   GET /users/{id}/metrics  → TrainingMetrics
//   GET /users/{id}/metrics/history?days=28 → List<ChartPoint>
// ─────────────────────────────────────────────────────────
class MetricsRepository {
  const MetricsRepository();

  Future<TrainingMetrics> fetchMetrics() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return TrainingMetrics.mock();
  }

  Future<List<ChartPoint>> fetchHistory() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ChartPoint.mockHistory();
  }
}

// ─────────────────────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────────────────────
final metricsRepositoryProvider = Provider<MetricsRepository>(
  (_) => const MetricsRepository(),
);

final metricsProvider = FutureProvider<TrainingMetrics>((ref) {
  return ref.read(metricsRepositoryProvider).fetchMetrics();
});

final chartHistoryProvider = FutureProvider<List<ChartPoint>>((ref) {
  return ref.read(metricsRepositoryProvider).fetchHistory();
});
