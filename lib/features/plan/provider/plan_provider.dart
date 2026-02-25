import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:asip_fitness_analytics/features/plan/repository/plan_repository.dart';
import 'package:asip_fitness_analytics/shared/models/plan_workout.dart';

part 'plan_provider.g.dart';

@riverpod
PlanRepository planRepository(Ref ref) {
  return PlanRepository();
}

@riverpod
Future<List<PlanWorkout>> weeklyPlan(Ref ref) {
  final repository = ref.watch(planRepositoryProvider);
  return repository.getWeeklyPlan();
}

@riverpod
Future<Map<String, dynamic>> planRecommendation(Ref ref) {
  final repository = ref.watch(planRepositoryProvider);
  return repository.getRecommendation();
}