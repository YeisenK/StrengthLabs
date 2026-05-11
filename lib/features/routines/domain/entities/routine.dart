import 'package:equatable/equatable.dart';
import 'package:strengthlabs/features/workouts/domain/entities/exercise.dart';
import 'package:strengthlabs/l10n/app_localizations.dart';

enum RoutineLevel { beginner, intermediate, advanced }

enum RoutineGoal { strength, hypertrophy, endurance, generalFitness }

extension RoutineLevelLabel on RoutineLevel {
  String localized(AppLocalizations l10n) {
    switch (this) {
      case RoutineLevel.beginner:
        return l10n.levelBeginner;
      case RoutineLevel.intermediate:
        return l10n.levelIntermediate;
      case RoutineLevel.advanced:
        return l10n.levelAdvanced;
    }
  }
}

extension RoutineGoalLabel on RoutineGoal {
  String localized(AppLocalizations l10n) {
    switch (this) {
      case RoutineGoal.strength:
        return l10n.goalStrength;
      case RoutineGoal.hypertrophy:
        return l10n.goalHypertrophy;
      case RoutineGoal.endurance:
        return l10n.goalEndurance;
      case RoutineGoal.generalFitness:
        return l10n.goalGeneralFitness;
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
