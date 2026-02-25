// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fatigue_metrics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FatigueMetricsImpl _$$FatigueMetricsImplFromJson(Map<String, dynamic> json) =>
    _$FatigueMetricsImpl(
      atl: (json['atl'] as num).toDouble(),
      ctl: (json['ctl'] as num).toDouble(),
      tsb: (json['tsb'] as num).toDouble(),
      acwr: (json['acwr'] as num).toDouble(),
      atlHistory: (json['atlHistory'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      ctlHistory: (json['ctlHistory'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      dates: (json['dates'] as List<dynamic>)
          .map((e) => DateTime.parse(e as String))
          .toList(),
    );

Map<String, dynamic> _$$FatigueMetricsImplToJson(
        _$FatigueMetricsImpl instance) =>
    <String, dynamic>{
      'atl': instance.atl,
      'ctl': instance.ctl,
      'tsb': instance.tsb,
      'acwr': instance.acwr,
      'atlHistory': instance.atlHistory,
      'ctlHistory': instance.ctlHistory,
      'dates': instance.dates.map((e) => e.toIso8601String()).toList(),
    };
