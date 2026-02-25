// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutSession _$WorkoutSessionFromJson(Map<String, dynamic> json) =>
    _WorkoutSession(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      exerciseName: json['exerciseName'] as String,
      sets: (json['sets'] as num).toInt(),
      repetitions: (json['repetitions'] as num).toInt(),
      weight: (json['weight'] as num).toDouble(),
      rpe: (json['rpe'] as num?)?.toInt(),
      rir: (json['rir'] as num?)?.toInt(),
      heartRate: (json['heartRate'] as num?)?.toInt(),
      bodyweight: (json['bodyweight'] as num?)?.toDouble(),
      sleepHours: (json['sleepHours'] as num?)?.toInt(),
      sessionLoad: (json['sessionLoad'] as num).toDouble(),
    );

Map<String, dynamic> _$WorkoutSessionToJson(_WorkoutSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'exerciseName': instance.exerciseName,
      'sets': instance.sets,
      'repetitions': instance.repetitions,
      'weight': instance.weight,
      'rpe': instance.rpe,
      'rir': instance.rir,
      'heartRate': instance.heartRate,
      'bodyweight': instance.bodyweight,
      'sleepHours': instance.sleepHours,
      'sessionLoad': instance.sessionLoad,
    };
