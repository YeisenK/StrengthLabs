import 'package:equatable/equatable.dart';

class WorkoutSet extends Equatable {
  const WorkoutSet({
    required this.id,
    required this.weight,
    required this.reps,
    this.rpe,
    this.isCompleted = true,
  });

  final String id;
  final double weight;
  final int reps;
  final double? rpe;
  final bool isCompleted;

  double get volume => weight * reps;

  Map<String, dynamic> toJson() => {
        'id': id,
        'weight': weight,
        'reps': reps,
        'rpe': rpe,
        'isCompleted': isCompleted,
      };

  factory WorkoutSet.fromJson(Map<String, dynamic> json) => WorkoutSet(
        id: json['id'] as String,
        weight: (json['weight'] as num).toDouble(),
        reps: json['reps'] as int,
        rpe: json['rpe'] != null ? (json['rpe'] as num).toDouble() : null,
        isCompleted: json['isCompleted'] as bool? ?? true,
      );

  @override
  List<Object?> get props => [id, weight, reps, rpe, isCompleted];
}
