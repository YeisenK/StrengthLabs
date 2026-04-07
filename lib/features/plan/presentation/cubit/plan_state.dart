import 'package:equatable/equatable.dart';
import 'package:strengthlabs_beta/features/plan/domain/entities/training_plan.dart';

abstract class PlanState extends Equatable {
  const PlanState();

  @override
  List<Object?> get props => [];
}

class PlanInitial extends PlanState {
  const PlanInitial();
}

class PlanLoading extends PlanState {
  const PlanLoading();
}

class PlanLoaded extends PlanState {
  const PlanLoaded(this.plan);
  final TrainingPlan plan;

  @override
  List<Object?> get props => [plan];
}

class PlanError extends PlanState {
  const PlanError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
