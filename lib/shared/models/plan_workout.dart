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
      
        @override
        // TODO: implement day
        String get day => throw UnimplementedError();
      
        @override
        // TODO: implement exerciseName
        String get exerciseName => throw UnimplementedError();
      
        @override
        // TODO: implement id
        String get id => throw UnimplementedError();
      
        @override
        // TODO: implement intensity
        String get intensity => throw UnimplementedError();
      
        @override
        // TODO: implement isCompleted
        bool get isCompleted => throw UnimplementedError();
      
        @override
        // TODO: implement notes
        String? get notes => throw UnimplementedError();
      
        @override
        // TODO: implement repetitions
        int get repetitions => throw UnimplementedError();
      
        @override
        // TODO: implement sets
        int get sets => throw UnimplementedError();
      
        @override
        // TODO: implement targetWeight
        double get targetWeight => throw UnimplementedError();
      
        @override
        Map<String, dynamic> toJson() {
          // TODO: implement toJson
          throw UnimplementedError();
        }
}