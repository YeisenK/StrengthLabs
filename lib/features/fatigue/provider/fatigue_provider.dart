import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:asip_fitness_analytics/features/fatigue/repository/fatigue_repository.dart';
import 'package:asip_fitness_analytics/shared/models/fatigue_metrics.dart';

part 'fatigue_provider.g.dart';

@riverpod
FatigueRepository fatigueRepository(Ref ref) {
  return FatigueRepository();
}

@riverpod
Future<FatigueMetrics> fatigueMetrics(Ref ref) {
  final repository = ref.watch(fatigueRepositoryProvider);
  return repository.getFatigueMetrics();
}