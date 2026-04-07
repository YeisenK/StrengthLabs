import 'package:strengthlabs_beta/features/fatigue/data/compute_repository.dart';
import 'package:strengthlabs_beta/features/fatigue/domain/entities/fatigue_metrics.dart';
import 'package:strengthlabs_beta/features/plan/domain/entities/training_plan.dart';

class PlanRepository {
  const PlanRepository(this._computeRepo);

  final ComputeRepository _computeRepo;

  Future<TrainingPlan> getPlan({
    required ComputeMetrics metrics,
    int? daysToEvent,
    int weeksInPhase = 0,
  }) async {
    final data = await _computeRepo.computePlan(
      metrics: metrics,
      daysToEvent: daysToEvent,
      weeksInPhase: weeksInPhase,
    );
    return TrainingPlan.fromJson(data);
  }
}
