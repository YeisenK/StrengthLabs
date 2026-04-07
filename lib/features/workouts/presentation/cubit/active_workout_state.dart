import 'package:equatable/equatable.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/exercise.dart';

class ActiveSet extends Equatable {
  const ActiveSet({
    required this.id,
    this.weight = '',
    this.reps = '',
    this.rpe,
    this.isCompleted = false,
  });

  final String id;
  final String weight;
  final String reps;
  final double? rpe;
  final bool isCompleted;

  ActiveSet copyWith({
    String? weight,
    String? reps,
    double? rpe,
    bool? isCompleted,
  }) =>
      ActiveSet(
        id: id,
        weight: weight ?? this.weight,
        reps: reps ?? this.reps,
        rpe: rpe ?? this.rpe,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  @override
  List<Object?> get props => [id, weight, reps, rpe, isCompleted];
}

class ActiveExercise extends Equatable {
  const ActiveExercise({
    required this.id,
    required this.exercise,
    required this.sets,
  });

  final String id;
  final Exercise exercise;
  final List<ActiveSet> sets;

  ActiveExercise copyWith({List<ActiveSet>? sets}) =>
      ActiveExercise(id: id, exercise: exercise, sets: sets ?? this.sets);

  @override
  List<Object?> get props => [id, exercise, sets];
}

class ActiveWorkoutState extends Equatable {
  const ActiveWorkoutState({
    required this.name,
    required this.startTime,
    required this.exercises,
    this.isFinished = false,
  });

  final String name;
  final DateTime startTime;
  final List<ActiveExercise> exercises;
  final bool isFinished;

  Duration get elapsed => DateTime.now().difference(startTime);

  ActiveWorkoutState copyWith({
    String? name,
    List<ActiveExercise>? exercises,
    bool? isFinished,
  }) =>
      ActiveWorkoutState(
        name: name ?? this.name,
        startTime: startTime,
        exercises: exercises ?? this.exercises,
        isFinished: isFinished ?? this.isFinished,
      );

  @override
  List<Object?> get props => [name, startTime, exercises, isFinished];
}
