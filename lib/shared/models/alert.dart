import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert.freezed.dart';
part 'alert.g.dart';

enum AlertSeverity { info, warning, critical }

@freezed
class Alert with _$Alert {
  const factory Alert({
    required String id,
    required String message,
    required AlertSeverity severity,
    required DateTime timestamp,
  }) = _Alert;

  factory Alert.fromJson(Map<String, dynamic> json) =>
      _$AlertFromJson(json);
}