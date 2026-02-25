import 'package:asip_fitness_analytics/features/plan/repository/plan_repository.dart';
import 'package:asip_fitness_analytics/shared/models/plan_workout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plan_provider.g.dart';

@riverpod
PlanRepository planRepository(PlanRepositoryRef ref) {
  return PlanRepository();
}

@riverpod
Future<List<PlanWorkout>> weeklyPlan(WeeklyPlanRef ref) {
  final repository = ref.watch(planRepositoryProvider);
  return repository.getWeeklyPlan();
}

@riverpod
Future<Map<String, dynamic>> planRecommendation(PlanRecommendationRef ref) {
  final repository = ref.watch(planRepositoryProvider);
  return repository.getRecommendation();
}