// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Alert _$AlertFromJson(Map<String, dynamic> json) => _Alert(
      id: json['id'] as String,
      message: json['message'] as String,
      severity: $enumDecode(_$AlertSeverityEnumMap, json['severity']),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$AlertToJson(_Alert instance) => <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'severity': _$AlertSeverityEnumMap[instance.severity]!,
      'timestamp': instance.timestamp.toIso8601String(),
    };

const _$AlertSeverityEnumMap = {
  AlertSeverity.info: 'info',
  AlertSeverity.warning: 'warning',
  AlertSeverity.critical: 'critical',
};
