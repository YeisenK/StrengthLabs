import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_session.freezed.dart';
part 'workout_session.g.dart';

@freezed
class WorkoutSession with _$WorkoutSession {
  const factory WorkoutSession({
    required String id,
    required DateTime date,
    required String exerciseName,
    required int sets,
    required int repetitions,
    required double weight,
    int? rpe,
    int? rir,
    int? heartRate,
    double? bodyweight,
    int? sleepHours,
    required double sessionLoad,
  }) = _WorkoutSession;

  factory WorkoutSession.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionFromJson(json);
}