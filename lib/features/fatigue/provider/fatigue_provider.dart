import 'package:asip_fitness_analytics/features/fatigue/repository/fatigue_repository.dart';
import 'package:asip_fitness_analytics/shared/models/fatigue_metrics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fatigue_provider.g.dart';

@riverpod
FatigueRepository fatigueRepository(FatigueRepositoryRef ref) {
  return FatigueRepository();
}

@riverpod
Future<FatigueMetrics> fatigueMetrics(FatigueMetricsRef ref) {
  final repository = ref.watch(fatigueRepositoryProvider);
  return repository.getFatigueMetrics();
}