import 'package:equatable/equatable.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/exercise.dart';

enum RoutineLevel { beginner, intermediate, advanced }

enum RoutineGoal { strength, hypertrophy, endurance, generalFitness }

extension RoutineLevelLabel on RoutineLevel {
  String get label {
    switch (this) {
      case RoutineLevel.beginner:
        return 'Beginner';
      case RoutineLevel.intermediate:
        return 'Intermediate';
      case RoutineLevel.advanced:
        return 'Advanced';
    }
  }
}

extension RoutineGoalLabel on RoutineGoal {
  String get label {
    switch (this) {
      case RoutineGoal.strength:
        return 'Strength';
      case RoutineGoal.hypertrophy:
        return 'Hypertrophy';
      case RoutineGoal.endurance:
        return 'Endurance';
      case RoutineGoal.generalFitness:
        return 'General Fitness';
    }
  }
}

class RoutineExercise extends Equatable {
  const RoutineExercise({
    required this.exercise,
    required this.sets,
    required this.repsScheme,
    this.notes,
  });

  final Exercise exercise;
  final int sets;
  final String repsScheme; // e.g. "5", "8-12", "3×5"
  final String? notes;

  @override
  List<Object?> get props => [exercise, sets, repsScheme, notes];
}

class RoutineDay extends Equatable {
  const RoutineDay({
    required this.name,
    required this.exercises,
  });

  final String name;
  final List<RoutineExercise> exercises;

  @override
  List<Object?> get props => [name, exercises];
}

class Routine extends Equatable {
  const Routine({
    required this.id,
    required this.name,
    required this.level,
    required this.goal,
    required this.daysPerWeek,
    required this.description,
    required this.days,
  });

  final String id;
  final String name;
  final RoutineLevel level;
  final RoutineGoal goal;
  final int daysPerWeek;
  final String description;
  final List<RoutineDay> days;

  @override
  List<Object?> get props => [id, name, level, goal, daysPerWeek, description, days];
}
