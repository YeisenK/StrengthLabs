// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkoutSession {
  String get id;
  DateTime get date;
  String get exerciseName;
  int get sets;
  int get repetitions;
  double get weight;
  int? get rpe;
  int? get rir;
  int? get heartRate;
  double? get bodyweight;
  int? get sleepHours;
  double get sessionLoad;

  /// Create a copy of WorkoutSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WorkoutSessionCopyWith<WorkoutSession> get copyWith =>
      _$WorkoutSessionCopyWithImpl<WorkoutSession>(
          this as WorkoutSession, _$identity);

  /// Serializes this WorkoutSession to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is WorkoutSession &&
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

  @override
  String toString() {
    return 'WorkoutSession(id: $id, date: $date, exerciseName: $exerciseName, sets: $sets, repetitions: $repetitions, weight: $weight, rpe: $rpe, rir: $rir, heartRate: $heartRate, bodyweight: $bodyweight, sleepHours: $sleepHours, sessionLoad: $sessionLoad)';
  }
}

/// @nodoc
abstract mixin class $WorkoutSessionCopyWith<$Res> {
  factory $WorkoutSessionCopyWith(
          WorkoutSession value, $Res Function(WorkoutSession) _then) =
      _$WorkoutSessionCopyWithImpl;
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
class _$WorkoutSessionCopyWithImpl<$Res>
    implements $WorkoutSessionCopyWith<$Res> {
  _$WorkoutSessionCopyWithImpl(this._self, this._then);

  final WorkoutSession _self;
  final $Res Function(WorkoutSession) _then;

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
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      exerciseName: null == exerciseName
          ? _self.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      sets: null == sets
          ? _self.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as int,
      repetitions: null == repetitions
          ? _self.repetitions
          : repetitions // ignore: cast_nullable_to_non_nullable
              as int,
      weight: null == weight
          ? _self.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      rpe: freezed == rpe
          ? _self.rpe
          : rpe // ignore: cast_nullable_to_non_nullable
              as int?,
      rir: freezed == rir
          ? _self.rir
          : rir // ignore: cast_nullable_to_non_nullable
              as int?,
      heartRate: freezed == heartRate
          ? _self.heartRate
          : heartRate // ignore: cast_nullable_to_non_nullable
              as int?,
      bodyweight: freezed == bodyweight
          ? _self.bodyweight
          : bodyweight // ignore: cast_nullable_to_non_nullable
              as double?,
      sleepHours: freezed == sleepHours
          ? _self.sleepHours
          : sleepHours // ignore: cast_nullable_to_non_nullable
              as int?,
      sessionLoad: null == sessionLoad
          ? _self.sessionLoad
          : sessionLoad // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [WorkoutSession].
extension WorkoutSessionPatterns on WorkoutSession {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_WorkoutSession value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WorkoutSession() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_WorkoutSession value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkoutSession():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_WorkoutSession value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkoutSession() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
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
            double sessionLoad)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WorkoutSession() when $default != null:
        return $default(
            _that.id,
            _that.date,
            _that.exerciseName,
            _that.sets,
            _that.repetitions,
            _that.weight,
            _that.rpe,
            _that.rir,
            _that.heartRate,
            _that.bodyweight,
            _that.sleepHours,
            _that.sessionLoad);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
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
            double sessionLoad)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkoutSession():
        return $default(
            _that.id,
            _that.date,
            _that.exerciseName,
            _that.sets,
            _that.repetitions,
            _that.weight,
            _that.rpe,
            _that.rir,
            _that.heartRate,
            _that.bodyweight,
            _that.sleepHours,
            _that.sessionLoad);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
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
            double sessionLoad)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkoutSession() when $default != null:
        return $default(
            _that.id,
            _that.date,
            _that.exerciseName,
            _that.sets,
            _that.repetitions,
            _that.weight,
            _that.rpe,
            _that.rir,
            _that.heartRate,
            _that.bodyweight,
            _that.sleepHours,
            _that.sessionLoad);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _WorkoutSession implements WorkoutSession {
  const _WorkoutSession(
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
  factory _WorkoutSession.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionFromJson(json);

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

  /// Create a copy of WorkoutSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WorkoutSessionCopyWith<_WorkoutSession> get copyWith =>
      __$WorkoutSessionCopyWithImpl<_WorkoutSession>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$WorkoutSessionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _WorkoutSession &&
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

  @override
  String toString() {
    return 'WorkoutSession(id: $id, date: $date, exerciseName: $exerciseName, sets: $sets, repetitions: $repetitions, weight: $weight, rpe: $rpe, rir: $rir, heartRate: $heartRate, bodyweight: $bodyweight, sleepHours: $sleepHours, sessionLoad: $sessionLoad)';
  }
}

/// @nodoc
abstract mixin class _$WorkoutSessionCopyWith<$Res>
    implements $WorkoutSessionCopyWith<$Res> {
  factory _$WorkoutSessionCopyWith(
          _WorkoutSession value, $Res Function(_WorkoutSession) _then) =
      __$WorkoutSessionCopyWithImpl;
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
class __$WorkoutSessionCopyWithImpl<$Res>
    implements _$WorkoutSessionCopyWith<$Res> {
  __$WorkoutSessionCopyWithImpl(this._self, this._then);

  final _WorkoutSession _self;
  final $Res Function(_WorkoutSession) _then;

  /// Create a copy of WorkoutSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_WorkoutSession(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      exerciseName: null == exerciseName
          ? _self.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      sets: null == sets
          ? _self.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as int,
      repetitions: null == repetitions
          ? _self.repetitions
          : repetitions // ignore: cast_nullable_to_non_nullable
              as int,
      weight: null == weight
          ? _self.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      rpe: freezed == rpe
          ? _self.rpe
          : rpe // ignore: cast_nullable_to_non_nullable
              as int?,
      rir: freezed == rir
          ? _self.rir
          : rir // ignore: cast_nullable_to_non_nullable
              as int?,
      heartRate: freezed == heartRate
          ? _self.heartRate
          : heartRate // ignore: cast_nullable_to_non_nullable
              as int?,
      bodyweight: freezed == bodyweight
          ? _self.bodyweight
          : bodyweight // ignore: cast_nullable_to_non_nullable
              as double?,
      sleepHours: freezed == sleepHours
          ? _self.sleepHours
          : sleepHours // ignore: cast_nullable_to_non_nullable
              as int?,
      sessionLoad: null == sessionLoad
          ? _self.sessionLoad
          : sessionLoad // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

// dart format on
