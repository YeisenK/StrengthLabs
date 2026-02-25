// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plan_workout.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlanWorkout {
  String get id;
  String get day;
  String get exerciseName;
  int get sets;
  int get repetitions;
  double get targetWeight;
  String get intensity;
  String? get notes;
  bool get isCompleted;

  /// Create a copy of PlanWorkout
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PlanWorkoutCopyWith<PlanWorkout> get copyWith =>
      _$PlanWorkoutCopyWithImpl<PlanWorkout>(this as PlanWorkout, _$identity);

  /// Serializes this PlanWorkout to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PlanWorkout &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.day, day) || other.day == day) &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.sets, sets) || other.sets == sets) &&
            (identical(other.repetitions, repetitions) ||
                other.repetitions == repetitions) &&
            (identical(other.targetWeight, targetWeight) ||
                other.targetWeight == targetWeight) &&
            (identical(other.intensity, intensity) ||
                other.intensity == intensity) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, day, exerciseName, sets,
      repetitions, targetWeight, intensity, notes, isCompleted);

  @override
  String toString() {
    return 'PlanWorkout(id: $id, day: $day, exerciseName: $exerciseName, sets: $sets, repetitions: $repetitions, targetWeight: $targetWeight, intensity: $intensity, notes: $notes, isCompleted: $isCompleted)';
  }
}

/// @nodoc
abstract mixin class $PlanWorkoutCopyWith<$Res> {
  factory $PlanWorkoutCopyWith(
          PlanWorkout value, $Res Function(PlanWorkout) _then) =
      _$PlanWorkoutCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String day,
      String exerciseName,
      int sets,
      int repetitions,
      double targetWeight,
      String intensity,
      String? notes,
      bool isCompleted});
}

/// @nodoc
class _$PlanWorkoutCopyWithImpl<$Res> implements $PlanWorkoutCopyWith<$Res> {
  _$PlanWorkoutCopyWithImpl(this._self, this._then);

  final PlanWorkout _self;
  final $Res Function(PlanWorkout) _then;

  /// Create a copy of PlanWorkout
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? day = null,
    Object? exerciseName = null,
    Object? sets = null,
    Object? repetitions = null,
    Object? targetWeight = null,
    Object? intensity = null,
    Object? notes = freezed,
    Object? isCompleted = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      day: null == day
          ? _self.day
          : day // ignore: cast_nullable_to_non_nullable
              as String,
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
      targetWeight: null == targetWeight
          ? _self.targetWeight
          : targetWeight // ignore: cast_nullable_to_non_nullable
              as double,
      intensity: null == intensity
          ? _self.intensity
          : intensity // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _self.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [PlanWorkout].
extension PlanWorkoutPatterns on PlanWorkout {
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
    TResult Function(_PlanWorkout value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PlanWorkout() when $default != null:
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
    TResult Function(_PlanWorkout value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlanWorkout():
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
    TResult? Function(_PlanWorkout value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlanWorkout() when $default != null:
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
            String day,
            String exerciseName,
            int sets,
            int repetitions,
            double targetWeight,
            String intensity,
            String? notes,
            bool isCompleted)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PlanWorkout() when $default != null:
        return $default(
            _that.id,
            _that.day,
            _that.exerciseName,
            _that.sets,
            _that.repetitions,
            _that.targetWeight,
            _that.intensity,
            _that.notes,
            _that.isCompleted);
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
            String day,
            String exerciseName,
            int sets,
            int repetitions,
            double targetWeight,
            String intensity,
            String? notes,
            bool isCompleted)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlanWorkout():
        return $default(
            _that.id,
            _that.day,
            _that.exerciseName,
            _that.sets,
            _that.repetitions,
            _that.targetWeight,
            _that.intensity,
            _that.notes,
            _that.isCompleted);
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
            String day,
            String exerciseName,
            int sets,
            int repetitions,
            double targetWeight,
            String intensity,
            String? notes,
            bool isCompleted)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlanWorkout() when $default != null:
        return $default(
            _that.id,
            _that.day,
            _that.exerciseName,
            _that.sets,
            _that.repetitions,
            _that.targetWeight,
            _that.intensity,
            _that.notes,
            _that.isCompleted);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PlanWorkout implements PlanWorkout {
  const _PlanWorkout(
      {required this.id,
      required this.day,
      required this.exerciseName,
      required this.sets,
      required this.repetitions,
      required this.targetWeight,
      required this.intensity,
      this.notes,
      this.isCompleted = false});
  factory _PlanWorkout.fromJson(Map<String, dynamic> json) =>
      _$PlanWorkoutFromJson(json);

  @override
  final String id;
  @override
  final String day;
  @override
  final String exerciseName;
  @override
  final int sets;
  @override
  final int repetitions;
  @override
  final double targetWeight;
  @override
  final String intensity;
  @override
  final String? notes;
  @override
  @JsonKey()
  final bool isCompleted;

  /// Create a copy of PlanWorkout
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PlanWorkoutCopyWith<_PlanWorkout> get copyWith =>
      __$PlanWorkoutCopyWithImpl<_PlanWorkout>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PlanWorkoutToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PlanWorkout &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.day, day) || other.day == day) &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.sets, sets) || other.sets == sets) &&
            (identical(other.repetitions, repetitions) ||
                other.repetitions == repetitions) &&
            (identical(other.targetWeight, targetWeight) ||
                other.targetWeight == targetWeight) &&
            (identical(other.intensity, intensity) ||
                other.intensity == intensity) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, day, exerciseName, sets,
      repetitions, targetWeight, intensity, notes, isCompleted);

  @override
  String toString() {
    return 'PlanWorkout(id: $id, day: $day, exerciseName: $exerciseName, sets: $sets, repetitions: $repetitions, targetWeight: $targetWeight, intensity: $intensity, notes: $notes, isCompleted: $isCompleted)';
  }
}

/// @nodoc
abstract mixin class _$PlanWorkoutCopyWith<$Res>
    implements $PlanWorkoutCopyWith<$Res> {
  factory _$PlanWorkoutCopyWith(
          _PlanWorkout value, $Res Function(_PlanWorkout) _then) =
      __$PlanWorkoutCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String day,
      String exerciseName,
      int sets,
      int repetitions,
      double targetWeight,
      String intensity,
      String? notes,
      bool isCompleted});
}

/// @nodoc
class __$PlanWorkoutCopyWithImpl<$Res> implements _$PlanWorkoutCopyWith<$Res> {
  __$PlanWorkoutCopyWithImpl(this._self, this._then);

  final _PlanWorkout _self;
  final $Res Function(_PlanWorkout) _then;

  /// Create a copy of PlanWorkout
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? day = null,
    Object? exerciseName = null,
    Object? sets = null,
    Object? repetitions = null,
    Object? targetWeight = null,
    Object? intensity = null,
    Object? notes = freezed,
    Object? isCompleted = null,
  }) {
    return _then(_PlanWorkout(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      day: null == day
          ? _self.day
          : day // ignore: cast_nullable_to_non_nullable
              as String,
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
      targetWeight: null == targetWeight
          ? _self.targetWeight
          : targetWeight // ignore: cast_nullable_to_non_nullable
              as double,
      intensity: null == intensity
          ? _self.intensity
          : intensity // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _self.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
