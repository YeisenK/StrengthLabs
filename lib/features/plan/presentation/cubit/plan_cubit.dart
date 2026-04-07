import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strengthlabs_beta/features/fatigue/domain/entities/fatigue_metrics.dart';
import 'package:strengthlabs_beta/features/plan/data/plan_repository.dart';
import 'package:strengthlabs_beta/features/plan/presentation/cubit/plan_state.dart';

class PlanCubit extends Cubit<PlanState> {
  PlanCubit(this._repository) : super(const PlanInitial());

  final PlanRepository _repository;

  Future<void> generatePlan({
    required ComputeMetrics metrics,
    int? daysToEvent,
    int weeksInPhase = 0,
  }) async {
    emit(const PlanLoading());
    try {
      final plan = await _repository.getPlan(
        metrics: metrics,
        daysToEvent: daysToEvent,
        weeksInPhase: weeksInPhase,
      );
      emit(PlanLoaded(plan));
    } catch (_) {
      emit(const PlanError('Could not generate training plan. Please try again.'));
    }
  }
}
