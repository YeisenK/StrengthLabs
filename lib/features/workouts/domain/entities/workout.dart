import 'package:equatable/equatable.dart';
import 'package:strengthlabs/features/workouts/domain/entities/exercise.dart';
import 'package:strengthlabs/features/workouts/domain/entities/workout_set.dart';

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
    this.clientRequestId,
  });

  final String id;
  final String name;
  final DateTime date;
  final Duration duration;
  final List<WorkoutExercise> exercises;
  final String? notes;

  /// Client-generated UUID for idempotent retries. Sent on POST so the server
  /// can deduplicate when the same request is retried after a timeout.
  final String? clientRequestId;

  double get totalVolume => exercises.fold(0, (sum, e) => sum + e.totalVolume);
  int get totalSets => exercises.fold(0, (sum, e) => sum + e.sets.length);

  Workout copyWith({
    String? id,
    String? name,
    DateTime? date,
    Duration? duration,
    List<WorkoutExercise>? exercises,
    String? notes,
    String? clientRequestId,
  }) =>
      Workout(
        id: id ?? this.id,
        name: name ?? this.name,
        date: date ?? this.date,
        duration: duration ?? this.duration,
        exercises: exercises ?? this.exercises,
        notes: notes ?? this.notes,
        clientRequestId: clientRequestId ?? this.clientRequestId,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'date': date.toUtc().toIso8601String(),
        'duration_seconds': duration.inSeconds,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'notes': notes,
        if (clientRequestId != null) 'client_request_id': clientRequestId,
      };

  factory Workout.fromJson(Map<String, dynamic> json) {
    final durationSeconds =
        (json['duration_seconds'] ?? json['durationSeconds'] ?? 0) as int;
    return Workout(
      id: json['id'] as String,
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      duration: Duration(seconds: durationSeconds),
      exercises: (json['exercises'] as List? ?? const [])
          .map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      clientRequestId:
          (json['client_request_id'] ?? json['clientRequestId']) as String?,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, date, duration, exercises, notes, clientRequestId];
}
