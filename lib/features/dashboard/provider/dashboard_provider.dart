import 'package:asip_fitness_analytics/features/dashboard/repository/dashboard_repository.dart';
import 'package:asip_fitness_analytics/shared/models/workout_session.dart';
import 'package:asip_fitness_analytics/shared/models/alert.dart';
import 'package:asip_fitness_analytics/shared/models/fatigue_metrics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_provider.g.dart';

@riverpod
DashboardRepository dashboardRepository(DashboardRepositoryRef ref) {
  return DashboardRepository();
}

@riverpod
Future<FatigueMetrics> fatigueMetrics(FatigueMetricsRef ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getCurrentMetrics();
}

@riverpod
Future<List<WorkoutSession>> recentSessions(RecentSessionsRef ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getRecentSessions();
}

@riverpod
Future<List<Alert>> activeAlerts(ActiveAlertsRef ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getActiveAlerts();
}