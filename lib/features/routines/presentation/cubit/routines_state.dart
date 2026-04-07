import 'package:equatable/equatable.dart';
import 'package:strengthlabs_beta/features/routines/domain/entities/routine.dart';

abstract class RoutinesState extends Equatable {
  const RoutinesState();

  @override
  List<Object?> get props => [];
}

class RoutinesInitial extends RoutinesState {
  const RoutinesInitial();
}

class RoutinesLoading extends RoutinesState {
  const RoutinesLoading();
}

class RoutinesLoaded extends RoutinesState {
  const RoutinesLoaded(this.routines);
  final List<Routine> routines;

  @override
  List<Object?> get props => [routines];
}

class RoutinesError extends RoutinesState {
  const RoutinesError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
