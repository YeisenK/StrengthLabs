import 'package:equatable/equatable.dart';
import 'package:strengthlabs_beta/features/fatigue/domain/entities/fatigue_summary.dart';

abstract class FatigueState extends Equatable {
  const FatigueState();

  @override
  List<Object?> get props => [];
}

class FatigueInitial extends FatigueState {
  const FatigueInitial();
}

class FatigueLoading extends FatigueState {
  const FatigueLoading();
}

class FatigueLoaded extends FatigueState {
  const FatigueLoaded(this.summary);
  final FatigueSummary summary;

  @override
  List<Object?> get props => [summary];
}

class FatigueError extends FatigueState {
  const FatigueError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
