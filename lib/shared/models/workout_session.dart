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
      
        @override
        // TODO: implement bodyweight
        double? get bodyweight => throw UnimplementedError();
      
        @override
        // TODO: implement date
        DateTime get date => throw UnimplementedError();
      
        @override
        // TODO: implement exerciseName
        String get exerciseName => throw UnimplementedError();
      
        @override
        // TODO: implement heartRate
        int? get heartRate => throw UnimplementedError();
      
        @override
        // TODO: implement id
        String get id => throw UnimplementedError();
      
        @override
        // TODO: implement repetitions
        int get repetitions => throw UnimplementedError();
      
        @override
        // TODO: implement rir
        int? get rir => throw UnimplementedError();
      
        @override
        // TODO: implement rpe
        int? get rpe => throw UnimplementedError();
      
        @override
        // TODO: implement sessionLoad
        double get sessionLoad => throw UnimplementedError();
      
        @override
        // TODO: implement sets
        int get sets => throw UnimplementedError();
      
        @override
        // TODO: implement sleepHours
        int? get sleepHours => throw UnimplementedError();
      
        @override
        Map<String, dynamic> toJson() {
          // TODO: implement toJson
          throw UnimplementedError();
        }
      
        @override
        // TODO: implement weight
        double get weight => throw UnimplementedError();
}