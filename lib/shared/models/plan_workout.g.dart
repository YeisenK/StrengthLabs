// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_workout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlanWorkoutImpl _$$PlanWorkoutImplFromJson(Map<String, dynamic> json) =>
    _$PlanWorkoutImpl(
      id: json['id'] as String,
      day: json['day'] as String,
      exerciseName: json['exerciseName'] as String,
      sets: (json['sets'] as num).toInt(),
      repetitions: (json['repetitions'] as num).toInt(),
      targetWeight: (json['targetWeight'] as num).toDouble(),
      intensity: json['intensity'] as String,
      notes: json['notes'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$PlanWorkoutImplToJson(_$PlanWorkoutImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'day': instance.day,
      'exerciseName': instance.exerciseName,
      'sets': instance.sets,
      'repetitions': instance.repetitions,
      'targetWeight': instance.targetWeight,
      'intensity': instance.intensity,
      'notes': instance.notes,
      'isCompleted': instance.isCompleted,
    };
