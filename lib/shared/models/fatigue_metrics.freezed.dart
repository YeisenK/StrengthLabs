// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fatigue_metrics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FatigueMetrics {
  double get atl;
  double get ctl;
  double get tsb;
  double get acwr;
  List<double> get atlHistory;
  List<double> get ctlHistory;
  List<DateTime> get dates;

  /// Create a copy of FatigueMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FatigueMetricsCopyWith<FatigueMetrics> get copyWith =>
      _$FatigueMetricsCopyWithImpl<FatigueMetrics>(
          this as FatigueMetrics, _$identity);

  /// Serializes this FatigueMetrics to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FatigueMetrics &&
            (identical(other.atl, atl) || other.atl == atl) &&
            (identical(other.ctl, ctl) || other.ctl == ctl) &&
            (identical(other.tsb, tsb) || other.tsb == tsb) &&
            (identical(other.acwr, acwr) || other.acwr == acwr) &&
            const DeepCollectionEquality()
                .equals(other.atlHistory, atlHistory) &&
            const DeepCollectionEquality()
                .equals(other.ctlHistory, ctlHistory) &&
            const DeepCollectionEquality().equals(other.dates, dates));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      atl,
      ctl,
      tsb,
      acwr,
      const DeepCollectionEquality().hash(atlHistory),
      const DeepCollectionEquality().hash(ctlHistory),
      const DeepCollectionEquality().hash(dates));

  @override
  String toString() {
    return 'FatigueMetrics(atl: $atl, ctl: $ctl, tsb: $tsb, acwr: $acwr, atlHistory: $atlHistory, ctlHistory: $ctlHistory, dates: $dates)';
  }
}

/// @nodoc
abstract mixin class $FatigueMetricsCopyWith<$Res> {
  factory $FatigueMetricsCopyWith(
          FatigueMetrics value, $Res Function(FatigueMetrics) _then) =
      _$FatigueMetricsCopyWithImpl;
  @useResult
  $Res call(
      {double atl,
      double ctl,
      double tsb,
      double acwr,
      List<double> atlHistory,
      List<double> ctlHistory,
      List<DateTime> dates});
}

/// @nodoc
class _$FatigueMetricsCopyWithImpl<$Res>
    implements $FatigueMetricsCopyWith<$Res> {
  _$FatigueMetricsCopyWithImpl(this._self, this._then);

  final FatigueMetrics _self;
  final $Res Function(FatigueMetrics) _then;

  /// Create a copy of FatigueMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? atl = null,
    Object? ctl = null,
    Object? tsb = null,
    Object? acwr = null,
    Object? atlHistory = null,
    Object? ctlHistory = null,
    Object? dates = null,
  }) {
    return _then(_self.copyWith(
      atl: null == atl
          ? _self.atl
          : atl // ignore: cast_nullable_to_non_nullable
              as double,
      ctl: null == ctl
          ? _self.ctl
          : ctl // ignore: cast_nullable_to_non_nullable
              as double,
      tsb: null == tsb
          ? _self.tsb
          : tsb // ignore: cast_nullable_to_non_nullable
              as double,
      acwr: null == acwr
          ? _self.acwr
          : acwr // ignore: cast_nullable_to_non_nullable
              as double,
      atlHistory: null == atlHistory
          ? _self.atlHistory
          : atlHistory // ignore: cast_nullable_to_non_nullable
              as List<double>,
      ctlHistory: null == ctlHistory
          ? _self.ctlHistory
          : ctlHistory // ignore: cast_nullable_to_non_nullable
              as List<double>,
      dates: null == dates
          ? _self.dates
          : dates // ignore: cast_nullable_to_non_nullable
              as List<DateTime>,
    ));
  }
}

/// Adds pattern-matching-related methods to [FatigueMetrics].
extension FatigueMetricsPatterns on FatigueMetrics {
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
    TResult Function(_FatigueMetrics value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FatigueMetrics() when $default != null:
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
    TResult Function(_FatigueMetrics value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FatigueMetrics():
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
    TResult? Function(_FatigueMetrics value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FatigueMetrics() when $default != null:
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
            double atl,
            double ctl,
            double tsb,
            double acwr,
            List<double> atlHistory,
            List<double> ctlHistory,
            List<DateTime> dates)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FatigueMetrics() when $default != null:
        return $default(_that.atl, _that.ctl, _that.tsb, _that.acwr,
            _that.atlHistory, _that.ctlHistory, _that.dates);
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
            double atl,
            double ctl,
            double tsb,
            double acwr,
            List<double> atlHistory,
            List<double> ctlHistory,
            List<DateTime> dates)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FatigueMetrics():
        return $default(_that.atl, _that.ctl, _that.tsb, _that.acwr,
            _that.atlHistory, _that.ctlHistory, _that.dates);
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
            double atl,
            double ctl,
            double tsb,
            double acwr,
            List<double> atlHistory,
            List<double> ctlHistory,
            List<DateTime> dates)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FatigueMetrics() when $default != null:
        return $default(_that.atl, _that.ctl, _that.tsb, _that.acwr,
            _that.atlHistory, _that.ctlHistory, _that.dates);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _FatigueMetrics implements FatigueMetrics {
  const _FatigueMetrics(
      {required this.atl,
      required this.ctl,
      required this.tsb,
      required this.acwr,
      required final List<double> atlHistory,
      required final List<double> ctlHistory,
      required final List<DateTime> dates})
      : _atlHistory = atlHistory,
        _ctlHistory = ctlHistory,
        _dates = dates;
  factory _FatigueMetrics.fromJson(Map<String, dynamic> json) =>
      _$FatigueMetricsFromJson(json);

  @override
  final double atl;
  @override
  final double ctl;
  @override
  final double tsb;
  @override
  final double acwr;
  final List<double> _atlHistory;
  @override
  List<double> get atlHistory {
    if (_atlHistory is EqualUnmodifiableListView) return _atlHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_atlHistory);
  }

  final List<double> _ctlHistory;
  @override
  List<double> get ctlHistory {
    if (_ctlHistory is EqualUnmodifiableListView) return _ctlHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ctlHistory);
  }

  final List<DateTime> _dates;
  @override
  List<DateTime> get dates {
    if (_dates is EqualUnmodifiableListView) return _dates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dates);
  }

  /// Create a copy of FatigueMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$FatigueMetricsCopyWith<_FatigueMetrics> get copyWith =>
      __$FatigueMetricsCopyWithImpl<_FatigueMetrics>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$FatigueMetricsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FatigueMetrics &&
            (identical(other.atl, atl) || other.atl == atl) &&
            (identical(other.ctl, ctl) || other.ctl == ctl) &&
            (identical(other.tsb, tsb) || other.tsb == tsb) &&
            (identical(other.acwr, acwr) || other.acwr == acwr) &&
            const DeepCollectionEquality()
                .equals(other._atlHistory, _atlHistory) &&
            const DeepCollectionEquality()
                .equals(other._ctlHistory, _ctlHistory) &&
            const DeepCollectionEquality().equals(other._dates, _dates));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      atl,
      ctl,
      tsb,
      acwr,
      const DeepCollectionEquality().hash(_atlHistory),
      const DeepCollectionEquality().hash(_ctlHistory),
      const DeepCollectionEquality().hash(_dates));

  @override
  String toString() {
    return 'FatigueMetrics(atl: $atl, ctl: $ctl, tsb: $tsb, acwr: $acwr, atlHistory: $atlHistory, ctlHistory: $ctlHistory, dates: $dates)';
  }
}

/// @nodoc
abstract mixin class _$FatigueMetricsCopyWith<$Res>
    implements $FatigueMetricsCopyWith<$Res> {
  factory _$FatigueMetricsCopyWith(
          _FatigueMetrics value, $Res Function(_FatigueMetrics) _then) =
      __$FatigueMetricsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {double atl,
      double ctl,
      double tsb,
      double acwr,
      List<double> atlHistory,
      List<double> ctlHistory,
      List<DateTime> dates});
}

/// @nodoc
class __$FatigueMetricsCopyWithImpl<$Res>
    implements _$FatigueMetricsCopyWith<$Res> {
  __$FatigueMetricsCopyWithImpl(this._self, this._then);

  final _FatigueMetrics _self;
  final $Res Function(_FatigueMetrics) _then;

  /// Create a copy of FatigueMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? atl = null,
    Object? ctl = null,
    Object? tsb = null,
    Object? acwr = null,
    Object? atlHistory = null,
    Object? ctlHistory = null,
    Object? dates = null,
  }) {
    return _then(_FatigueMetrics(
      atl: null == atl
          ? _self.atl
          : atl // ignore: cast_nullable_to_non_nullable
              as double,
      ctl: null == ctl
          ? _self.ctl
          : ctl // ignore: cast_nullable_to_non_nullable
              as double,
      tsb: null == tsb
          ? _self.tsb
          : tsb // ignore: cast_nullable_to_non_nullable
              as double,
      acwr: null == acwr
          ? _self.acwr
          : acwr // ignore: cast_nullable_to_non_nullable
              as double,
      atlHistory: null == atlHistory
          ? _self._atlHistory
          : atlHistory // ignore: cast_nullable_to_non_nullable
              as List<double>,
      ctlHistory: null == ctlHistory
          ? _self._ctlHistory
          : ctlHistory // ignore: cast_nullable_to_non_nullable
              as List<double>,
      dates: null == dates
          ? _self._dates
          : dates // ignore: cast_nullable_to_non_nullable
              as List<DateTime>,
    ));
  }
}

// dart format on
