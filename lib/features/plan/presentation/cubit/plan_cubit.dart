import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strengthlabs/features/fatigue/domain/entities/fatigue_metrics.dart';
import 'package:strengthlabs/features/plan/data/plan_builder.dart';
import 'package:strengthlabs/features/plan/presentation/cubit/plan_state.dart';

class PlanCubit extends Cubit<PlanState> {
  PlanCubit(this._repository) : super(const PlanInitial());

  final PlanBuilder _repository;

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
