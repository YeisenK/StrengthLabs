import 'package:freezed_annotation/freezed_annotation.dart';

part 'fatigue_metrics.freezed.dart';
part 'fatigue_metrics.g.dart';

@freezed
class FatigueMetrics with _$FatigueMetrics {
  const factory FatigueMetrics({
    required double atl,
    required double ctl,
    required double tsb,
    required double acwr,
    required List<double> atlHistory,
    required List<double> ctlHistory,
    required List<DateTime> dates,
  }) = _FatigueMetrics;

  factory FatigueMetrics.initial() => const FatigueMetrics(
        atl: 0,
        ctl: 0,
        tsb: 0,
        acwr: 0,
        atlHistory: [],
        ctlHistory: [],
        dates: [],
      );

  factory FatigueMetrics.fromJson(Map<String, dynamic> json) =>
      _$FatigueMetricsFromJson(json);
}