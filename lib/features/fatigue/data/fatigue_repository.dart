import 'package:strengthlabs_beta/core/demo/demo_mode.dart';
import 'package:strengthlabs_beta/core/network/dio_client.dart';
import 'package:strengthlabs_beta/features/fatigue/domain/entities/fatigue_summary.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/exercise.dart';

class FatigueRepository {
  FatigueRepository(this._dioClient);

  final DioClient _dioClient;

  Future<FatigueSummary> getSummary() async {
    if (DemoMode.isActive) return DemoMode.fatigueSummary();
    final response = await _dioClient.dio.get('/fatigue/summary');
    final data = response.data as Map<String, dynamic>;

    // weekly_volume: string keys → MuscleGroup enum (accumulate into the 6 app groups)
    final rawVolume = data['weekly_volume'] as Map<String, dynamic>? ?? {};
    final weeklyVolume = <MuscleGroup, double>{
      for (final mg in MuscleGroup.values) mg: 0.0,
    };
    rawVolume.forEach((key, value) {
      final mg = _parseMuscleGroup(key);
      weeklyVolume[mg] = (weeklyVolume[mg] ?? 0.0) + (value as num).toDouble();
    });

    // trend: [{date, index}]
    final rawTrend = data['trend'] as List? ?? [];
    final trend = rawTrend.map((t) {
      final tm = t as Map<String, dynamic>;
      return FatigueDataPoint(
        date: DateTime.parse(tm['date'] as String),
        index: (tm['index'] as num).toDouble(),
      );
    }).toList();

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
      riskFlags: (data['risk_flags'] as List?)?.cast<String>() ?? [],
      injuryRiskScore: (data['injury_risk_score'] as num?)?.toDouble() ?? 0.0,
      overtrainingRiskScore:
          (data['overtraining_risk_score'] as num?)?.toDouble() ?? 0.0,
      compositeRiskScore:
          (data['composite_risk_score'] as num?)?.toDouble() ?? 0.0,
      riskLevel: data['risk_level'] as String? ?? 'low',
      dominantFactor: data['dominant_factor'] as String? ?? '',
      recommendations:
          (data['recommendations'] as List?)?.cast<String>() ?? [],
    );
  }

  static MuscleGroup _parseMuscleGroup(String mg) {
    switch (mg.toLowerCase()) {
      case 'chest':
        return MuscleGroup.chest;
      case 'back':
        return MuscleGroup.back;
      case 'shoulders':
        return MuscleGroup.shoulders;
      case 'arms':
      case 'biceps':
      case 'triceps':
      case 'forearms':
        return MuscleGroup.arms;
      case 'legs':
      case 'quads':
      case 'hamstrings':
      case 'glutes':
      case 'calves':
        return MuscleGroup.legs;
      default:
        return MuscleGroup.core;
    }
  }
}
