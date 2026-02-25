import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_workout.freezed.dart';
part 'plan_workout.g.dart';

@freezed
class PlanWorkout with _$PlanWorkout {
  const factory PlanWorkout({
    required String id,
    required String day,
    required String exerciseName,
    required int sets,
    required int repetitions,
    required double targetWeight,
    required String intensity,
    String? notes,
    @Default(false) bool isCompleted,
  }) = _PlanWorkout;

  factory PlanWorkout.fromJson(Map<String, dynamic> json) =>
      _$PlanWorkoutFromJson(json);
}