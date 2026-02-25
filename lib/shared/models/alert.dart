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
      
        @override
        // TODO: implement id
        String get id => throw UnimplementedError();
      
        @override
        // TODO: implement message
        String get message => throw UnimplementedError();
      
        @override
        // TODO: implement severity
        AlertSeverity get severity => throw UnimplementedError();
      
        @override
        // TODO: implement timestamp
        DateTime get timestamp => throw UnimplementedError();
      
        @override
        Map<String, dynamic> toJson() {
          // TODO: implement toJson
          throw UnimplementedError();
        }
}