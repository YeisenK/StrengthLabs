import 'package:equatable/equatable.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/exercise.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/workout_set.dart';

class WorkoutExercise extends Equatable {
  const WorkoutExercise({
    required this.exercise,
    required this.sets,
  });

  final Exercise exercise;
  final List<WorkoutSet> sets;

  double get totalVolume => sets.fold(0, (sum, s) => sum + s.volume);

  Map<String, dynamic> toJson() => {
        'exercise': exercise.toJson(),
        'sets': sets.map((s) => s.toJson()).toList(),
      };

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) =>
      WorkoutExercise(
        exercise: Exercise.fromJson(json['exercise'] as Map<String, dynamic>),
        sets: (json['sets'] as List)
            .map((s) => WorkoutSet.fromJson(s as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [exercise, sets];
}

class Workout extends Equatable {
  const Workout({
    required this.id,
    required this.name,
    required this.date,
    required this.duration,
    required this.exercises,
    this.notes,
  });

  final String id;
  final String name;
  final DateTime date;
  final Duration duration;
  final List<WorkoutExercise> exercises;
  final String? notes;

  double get totalVolume => exercises.fold(0, (sum, e) => sum + e.totalVolume);
  int get totalSets => exercises.fold(0, (sum, e) => sum + e.sets.length);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'date': date.toIso8601String(),
        'durationSeconds': duration.inSeconds,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'notes': notes,
      };

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
        id: json['id'] as String,
        name: json['name'] as String,
        date: DateTime.parse(json['date'] as String),
        duration: Duration(seconds: json['durationSeconds'] as int),
        exercises: (json['exercises'] as List)
            .map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
            .toList(),
        notes: json['notes'] as String?,
      );

  @override
  List<Object?> get props => [id, name, date, duration, exercises, notes];
}
