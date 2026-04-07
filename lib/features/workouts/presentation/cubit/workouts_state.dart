import 'package:equatable/equatable.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/workout.dart';

abstract class WorkoutsState extends Equatable {
  const WorkoutsState();

  @override
  List<Object?> get props => [];
}

class WorkoutsInitial extends WorkoutsState {
  const WorkoutsInitial();
}

class WorkoutsLoading extends WorkoutsState {
  const WorkoutsLoading();
}

class WorkoutsLoaded extends WorkoutsState {
  const WorkoutsLoaded(this.workouts);
  final List<Workout> workouts;

  @override
  List<Object?> get props => [workouts];
}

class WorkoutsError extends WorkoutsState {
  const WorkoutsError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
