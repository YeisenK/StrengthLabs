// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fatigue_metrics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FatigueMetrics _$FatigueMetricsFromJson(Map<String, dynamic> json) {
  return _FatigueMetrics.fromJson(json);
}

/// @nodoc
mixin _$FatigueMetrics {
  double get atl => throw _privateConstructorUsedError;
  double get ctl => throw _privateConstructorUsedError;
  double get tsb => throw _privateConstructorUsedError;
  double get acwr => throw _privateConstructorUsedError;
  List<double> get atlHistory => throw _privateConstructorUsedError;
  List<double> get ctlHistory => throw _privateConstructorUsedError;
  List<DateTime> get dates => throw _privateConstructorUsedError;

  /// Serializes this FatigueMetrics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FatigueMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FatigueMetricsCopyWith<FatigueMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FatigueMetricsCopyWith<$Res> {
  factory $FatigueMetricsCopyWith(
          FatigueMetrics value, $Res Function(FatigueMetrics) then) =
      _$FatigueMetricsCopyWithImpl<$Res, FatigueMetrics>;
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
class _$FatigueMetricsCopyWithImpl<$Res, $Val extends FatigueMetrics>
    implements $FatigueMetricsCopyWith<$Res> {
  _$FatigueMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      atl: null == atl
          ? _value.atl
          : atl // ignore: cast_nullable_to_non_nullable
              as double,
      ctl: null == ctl
          ? _value.ctl
          : ctl // ignore: cast_nullable_to_non_nullable
              as double,
      tsb: null == tsb
          ? _value.tsb
          : tsb // ignore: cast_nullable_to_non_nullable
              as double,
      acwr: null == acwr
          ? _value.acwr
          : acwr // ignore: cast_nullable_to_non_nullable
              as double,
      atlHistory: null == atlHistory
          ? _value.atlHistory
          : atlHistory // ignore: cast_nullable_to_non_nullable
              as List<double>,
      ctlHistory: null == ctlHistory
          ? _value.ctlHistory
          : ctlHistory // ignore: cast_nullable_to_non_nullable
              as List<double>,
      dates: null == dates
          ? _value.dates
          : dates // ignore: cast_nullable_to_non_nullable
              as List<DateTime>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FatigueMetricsImplCopyWith<$Res>
    implements $FatigueMetricsCopyWith<$Res> {
  factory _$$FatigueMetricsImplCopyWith(_$FatigueMetricsImpl value,
          $Res Function(_$FatigueMetricsImpl) then) =
      __$$FatigueMetricsImplCopyWithImpl<$Res>;
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
class __$$FatigueMetricsImplCopyWithImpl<$Res>
    extends _$FatigueMetricsCopyWithImpl<$Res, _$FatigueMetricsImpl>
    implements _$$FatigueMetricsImplCopyWith<$Res> {
  __$$FatigueMetricsImplCopyWithImpl(
      _$FatigueMetricsImpl _value, $Res Function(_$FatigueMetricsImpl) _then)
      : super(_value, _then);

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
    return _then(_$FatigueMetricsImpl(
      atl: null == atl
          ? _value.atl
          : atl // ignore: cast_nullable_to_non_nullable
              as double,
      ctl: null == ctl
          ? _value.ctl
          : ctl // ignore: cast_nullable_to_non_nullable
              as double,
      tsb: null == tsb
          ? _value.tsb
          : tsb // ignore: cast_nullable_to_non_nullable
              as double,
      acwr: null == acwr
          ? _value.acwr
          : acwr // ignore: cast_nullable_to_non_nullable
              as double,
      atlHistory: null == atlHistory
          ? _value._atlHistory
          : atlHistory // ignore: cast_nullable_to_non_nullable
              as List<double>,
      ctlHistory: null == ctlHistory
          ? _value._ctlHistory
          : ctlHistory // ignore: cast_nullable_to_non_nullable
              as List<double>,
      dates: null == dates
          ? _value._dates
          : dates // ignore: cast_nullable_to_non_nullable
              as List<DateTime>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FatigueMetricsImpl implements _FatigueMetrics {
  const _$FatigueMetricsImpl(
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

  factory _$FatigueMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$FatigueMetricsImplFromJson(json);

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

  @override
  String toString() {
    return 'FatigueMetrics(atl: $atl, ctl: $ctl, tsb: $tsb, acwr: $acwr, atlHistory: $atlHistory, ctlHistory: $ctlHistory, dates: $dates)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FatigueMetricsImpl &&
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

  /// Create a copy of FatigueMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FatigueMetricsImplCopyWith<_$FatigueMetricsImpl> get copyWith =>
      __$$FatigueMetricsImplCopyWithImpl<_$FatigueMetricsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FatigueMetricsImplToJson(
      this,
    );
  }
}

abstract class _FatigueMetrics implements FatigueMetrics {
  const factory _FatigueMetrics(
      {required final double atl,
      required final double ctl,
      required final double tsb,
      required final double acwr,
      required final List<double> atlHistory,
      required final List<double> ctlHistory,
      required final List<DateTime> dates}) = _$FatigueMetricsImpl;

  factory _FatigueMetrics.fromJson(Map<String, dynamic> json) =
      _$FatigueMetricsImpl.fromJson;

  @override
  double get atl;
  @override
  double get ctl;
  @override
  double get tsb;
  @override
  double get acwr;
  @override
  List<double> get atlHistory;
  @override
  List<double> get ctlHistory;
  @override
  List<DateTime> get dates;

  /// Create a copy of FatigueMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FatigueMetricsImplCopyWith<_$FatigueMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
