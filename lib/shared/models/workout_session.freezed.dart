// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WorkoutSession _$WorkoutSessionFromJson(Map<String, dynamic> json) {
  return _WorkoutSession.fromJson(json);
}

/// @nodoc
mixin _$WorkoutSession {
  String get id => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get exerciseName => throw _privateConstructorUsedError;
  int get sets => throw _privateConstructorUsedError;
  int get repetitions => throw _privateConstructorUsedError;
  double get weight => throw _privateConstructorUsedError;
  int? get rpe => throw _privateConstructorUsedError;
  int? get rir => throw _privateConstructorUsedError;
  int? get heartRate => throw _privateConstructorUsedError;
  double? get bodyweight => throw _privateConstructorUsedError;
  int? get sleepHours => throw _privateConstructorUsedError;
  double get sessionLoad => throw _privateConstructorUsedError;

  /// Serializes this WorkoutSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkoutSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkoutSessionCopyWith<WorkoutSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutSessionCopyWith<$Res> {
  factory $WorkoutSessionCopyWith(
          WorkoutSession value, $Res Function(WorkoutSession) then) =
      _$WorkoutSessionCopyWithImpl<$Res, WorkoutSession>;
  @useResult
  $Res call(
      {String id,
      DateTime date,
      String exerciseName,
      int sets,
      int repetitions,
      double weight,
      int? rpe,
      int? rir,
      int? heartRate,
      double? bodyweight,
      int? sleepHours,
      double sessionLoad});
}

/// @nodoc
class _$WorkoutSessionCopyWithImpl<$Res, $Val extends WorkoutSession>
    implements $WorkoutSessionCopyWith<$Res> {
  _$WorkoutSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkoutSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? exerciseName = null,
    Object? sets = null,
    Object? repetitions = null,
    Object? weight = null,
    Object? rpe = freezed,
    Object? rir = freezed,
    Object? heartRate = freezed,
    Object? bodyweight = freezed,
    Object? sleepHours = freezed,
    Object? sessionLoad = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      sets: null == sets
          ? _value.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as int,
      repetitions: null == repetitions
          ? _value.repetitions
          : repetitions // ignore: cast_nullable_to_non_nullable
              as int,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      rpe: freezed == rpe
          ? _value.rpe
          : rpe // ignore: cast_nullable_to_non_nullable
              as int?,
      rir: freezed == rir
          ? _value.rir
          : rir // ignore: cast_nullable_to_non_nullable
              as int?,
      heartRate: freezed == heartRate
          ? _value.heartRate
          : heartRate // ignore: cast_nullable_to_non_nullable
              as int?,
      bodyweight: freezed == bodyweight
          ? _value.bodyweight
          : bodyweight // ignore: cast_nullable_to_non_nullable
              as double?,
      sleepHours: freezed == sleepHours
          ? _value.sleepHours
          : sleepHours // ignore: cast_nullable_to_non_nullable
              as int?,
      sessionLoad: null == sessionLoad
          ? _value.sessionLoad
          : sessionLoad // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutSessionImplCopyWith<$Res>
    implements $WorkoutSessionCopyWith<$Res> {
  factory _$$WorkoutSessionImplCopyWith(_$WorkoutSessionImpl value,
          $Res Function(_$WorkoutSessionImpl) then) =
      __$$WorkoutSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime date,
      String exerciseName,
      int sets,
      int repetitions,
      double weight,
      int? rpe,
      int? rir,
      int? heartRate,
      double? bodyweight,
      int? sleepHours,
      double sessionLoad});
}

/// @nodoc
class __$$WorkoutSessionImplCopyWithImpl<$Res>
    extends _$WorkoutSessionCopyWithImpl<$Res, _$WorkoutSessionImpl>
    implements _$$WorkoutSessionImplCopyWith<$Res> {
  __$$WorkoutSessionImplCopyWithImpl(
      _$WorkoutSessionImpl _value, $Res Function(_$WorkoutSessionImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorkoutSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? exerciseName = null,
    Object? sets = null,
    Object? repetitions = null,
    Object? weight = null,
    Object? rpe = freezed,
    Object? rir = freezed,
    Object? heartRate = freezed,
    Object? bodyweight = freezed,
    Object? sleepHours = freezed,
    Object? sessionLoad = null,
  }) {
    return _then(_$WorkoutSessionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      sets: null == sets
          ? _value.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as int,
      repetitions: null == repetitions
          ? _value.repetitions
          : repetitions // ignore: cast_nullable_to_non_nullable
              as int,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      rpe: freezed == rpe
          ? _value.rpe
          : rpe // ignore: cast_nullable_to_non_nullable
              as int?,
      rir: freezed == rir
          ? _value.rir
          : rir // ignore: cast_nullable_to_non_nullable
              as int?,
      heartRate: freezed == heartRate
          ? _value.heartRate
          : heartRate // ignore: cast_nullable_to_non_nullable
              as int?,
      bodyweight: freezed == bodyweight
          ? _value.bodyweight
          : bodyweight // ignore: cast_nullable_to_non_nullable
              as double?,
      sleepHours: freezed == sleepHours
          ? _value.sleepHours
          : sleepHours // ignore: cast_nullable_to_non_nullable
              as int?,
      sessionLoad: null == sessionLoad
          ? _value.sessionLoad
          : sessionLoad // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutSessionImpl implements _WorkoutSession {
  const _$WorkoutSessionImpl(
      {required this.id,
      required this.date,
      required this.exerciseName,
      required this.sets,
      required this.repetitions,
      required this.weight,
      this.rpe,
      this.rir,
      this.heartRate,
      this.bodyweight,
      this.sleepHours,
      required this.sessionLoad});

  factory _$WorkoutSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutSessionImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime date;
  @override
  final String exerciseName;
  @override
  final int sets;
  @override
  final int repetitions;
  @override
  final double weight;
  @override
  final int? rpe;
  @override
  final int? rir;
  @override
  final int? heartRate;
  @override
  final double? bodyweight;
  @override
  final int? sleepHours;
  @override
  final double sessionLoad;

  @override
  String toString() {
    return 'WorkoutSession(id: $id, date: $date, exerciseName: $exerciseName, sets: $sets, repetitions: $repetitions, weight: $weight, rpe: $rpe, rir: $rir, heartRate: $heartRate, bodyweight: $bodyweight, sleepHours: $sleepHours, sessionLoad: $sessionLoad)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.sets, sets) || other.sets == sets) &&
            (identical(other.repetitions, repetitions) ||
                other.repetitions == repetitions) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.rpe, rpe) || other.rpe == rpe) &&
            (identical(other.rir, rir) || other.rir == rir) &&
            (identical(other.heartRate, heartRate) ||
                other.heartRate == heartRate) &&
            (identical(other.bodyweight, bodyweight) ||
                other.bodyweight == bodyweight) &&
            (identical(other.sleepHours, sleepHours) ||
                other.sleepHours == sleepHours) &&
            (identical(other.sessionLoad, sessionLoad) ||
                other.sessionLoad == sessionLoad));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      date,
      exerciseName,
      sets,
      repetitions,
      weight,
      rpe,
      rir,
      heartRate,
      bodyweight,
      sleepHours,
      sessionLoad);

  /// Create a copy of WorkoutSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutSessionImplCopyWith<_$WorkoutSessionImpl> get copyWith =>
      __$$WorkoutSessionImplCopyWithImpl<_$WorkoutSessionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutSessionImplToJson(
      this,
    );
  }
}

abstract class _WorkoutSession implements WorkoutSession {
  const factory _WorkoutSession(
      {required final String id,
      required final DateTime date,
      required final String exerciseName,
      required final int sets,
      required final int repetitions,
      required final double weight,
      final int? rpe,
      final int? rir,
      final int? heartRate,
      final double? bodyweight,
      final int? sleepHours,
      required final double sessionLoad}) = _$WorkoutSessionImpl;

  factory _WorkoutSession.fromJson(Map<String, dynamic> json) =
      _$WorkoutSessionImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get date;
  @override
  String get exerciseName;
  @override
  int get sets;
  @override
  int get repetitions;
  @override
  double get weight;
  @override
  int? get rpe;
  @override
  int? get rir;
  @override
  int? get heartRate;
  @override
  double? get bodyweight;
  @override
  int? get sleepHours;
  @override
  double get sessionLoad;

  /// Create a copy of WorkoutSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkoutSessionImplCopyWith<_$WorkoutSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
