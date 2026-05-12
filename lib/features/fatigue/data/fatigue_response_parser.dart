import 'package:strengthlabs/features/fatigue/domain/entities/fatigue_summary.dart';
import 'package:strengthlabs/features/workouts/domain/entities/exercise.dart';

/// Pure deserializer for the /fatigue/summary payload.
///
/// Extracted from [FatigueRepository] so it can be unit-tested without a Dio
/// instance and so the network layer doesn't carry parsing logic that needs to
/// stay defensive against backend shape drift.
FatigueSummary parseFatigueSummary(Map<String, dynamic> data) {
  final rawVolume = (data['weekly_volume'] as Map?) ?? const {};
  final weeklyVolume = <MuscleGroup, double>{
    for (final mg in MuscleGroup.values) mg: 0.0,
  };
  rawVolume.forEach((key, value) {
    final mg = MuscleGroupParsing.fromString(key.toString());
    final amount = (value as num?)?.toDouble() ?? 0.0;
    weeklyVolume[mg] = (weeklyVolume[mg] ?? 0.0) + amount;
  });

  final rawTrend = (data['trend'] as List?) ?? const [];
  final trend = rawTrend
      .whereType<Map>()
      .map((t) => FatigueDataPoint(
            date: DateTime.parse(t['date'] as String),
            index: (t['index'] as num?)?.toDouble() ?? 0.0,
          ))
      .toList();

  return FatigueSummary(
    overallIndex: (data['overall_index'] as num?)?.toDouble() ?? 0.0,
    isOvertraining: data['is_overtraining'] as bool? ?? false,
    weeklyVolume: weeklyVolume,
    trend: trend,
    atl: (data['atl'] as num?)?.toDouble() ?? 0.0,
    ctl: (data['ctl'] as num?)?.toDouble() ?? 0.0,
    tsb: (data['tsb'] as num?)?.toDouble() ?? 0.0,
    acwr: (data['acwr'] as num?)?.toDouble() ?? 0.0,
    monotony: (data['monotony'] as num?)?.toDouble() ?? 0.0,
    strain: (data['strain'] as num?)?.toDouble() ?? 0.0,
    rampRate: (data['ramp_rate'] as num?)?.toDouble() ?? 0.0,
    readinessScore: (data['readiness_score'] as num?)?.toDouble() ?? 0.0,
    riskFlags: _parseFlagList(data['risk_flags']),
    injuryRiskScore: (data['injury_risk_score'] as num?)?.toDouble() ?? 0.0,
    overtrainingRiskScore:
        (data['overtraining_risk_score'] as num?)?.toDouble() ?? 0.0,
    compositeRiskScore:
        (data['composite_risk_score'] as num?)?.toDouble() ?? 0.0,
    riskLevel: data['risk_level'] as String? ?? 'low',
    dominantFactor: data['dominant_factor'] as String? ?? '',
    recommendations: _parseFlagList(data['recommendations']),
  );
}

/// Accepts the historical wire format (`List<String>`) and the structured
/// shape (`List<Map>` with `code` / `text`). Either way we end up with a list
/// of human-readable strings, never crashing on shape drift.
List<String> _parseFlagList(dynamic raw) {
  if (raw is! List) return const [];
  final out = <String>[];
  for (final item in raw) {
    if (item == null) continue;
    if (item is String) {
      out.add(item);
    } else if (item is Map) {
      final text = item['text'] ?? item['message'] ?? item['code'];
      if (text != null) out.add(text.toString());
    } else {
      out.add(item.toString());
    }
  }
  return out;
}
