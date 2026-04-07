import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:strengthlabs_beta/core/constants/api_constants.dart';
import 'package:strengthlabs_beta/core/storage/workout_local_storage.dart';
import 'package:strengthlabs_beta/features/fatigue/domain/entities/fatigue_metrics.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/workout.dart';

class ComputeRepository {
  ComputeRepository(this._localStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.computeBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  final WorkoutLocalStorage _localStorage;
  late final Dio _dio;

  static final _dateFmt = DateFormat('yyyy-MM-dd');

  Future<ComputeMetrics> computeMetrics() async {
    final workouts = await _localStorage.load();
    final sessions = _toSessions(workouts);

    final fatigueResp = await _dio.post(
      ApiConstants.computeFatigue,
      data: {'sessions': sessions},
    );
    final f = fatigueResp.data as Map<String, dynamic>;

    final riskResp = await _dio.post(
      ApiConstants.computeRisk,
      data: {
        'acwr': f['acwr'],
        'tsb': f['tsb'],
        'ramp_rate': f['ramp_rate'],
        'monotony': f['monotony'],
      },
    );
    final r = riskResp.data as Map<String, dynamic>;

    return ComputeMetrics(
      atl: _d(f['atl']),
      ctl: _d(f['ctl']),
      tsb: _d(f['tsb']),
      acwr: _d(f['acwr']),
      monotony: _d(f['monotony']),
      strain: _d(f['strain']),
      rampRate: _d(f['ramp_rate']),
      readinessScore: _d(f['readiness_score']),
      riskFlags: (f['risk_flags'] as List).cast<String>(),
      injuryRiskScore: _d(r['injury_risk_score']),
      overtrainingRiskScore: _d(r['overtraining_risk_score']),
      compositeRiskScore: _d(r['composite_risk_score']),
      riskLevel: r['risk_level'] as String,
      dominantFactor: r['dominant_factor'] as String,
      recommendations: (r['recommendations'] as List).cast<String>(),
    );
  }

  Future<Map<String, dynamic>> computePlan({
    required ComputeMetrics metrics,
    int? daysToEvent,
    int weeksInPhase = 0,
  }) async {
    final resp = await _dio.post(
      ApiConstants.computePlan,
      data: {
        'ctl': metrics.ctl,
        'atl': metrics.atl,
        'tsb': metrics.tsb,
        'acwr': metrics.acwr,
        'monotony': metrics.monotony,
        'ramp_rate': metrics.rampRate,
        'readiness_score': metrics.readinessScore,
        'composite_risk': metrics.compositeRiskScore,
        'injury_risk_score': metrics.injuryRiskScore,
        'overtraining_risk_score': metrics.overtrainingRiskScore,
        if (daysToEvent != null) 'days_to_event': daysToEvent,
        'weeks_in_phase': weeksInPhase,
      },
    );
    return resp.data as Map<String, dynamic>;
  }

  List<Map<String, dynamic>> _toSessions(List<Workout> workouts) {
    return workouts.map((w) {
      final allSets = w.exercises.expand((e) => e.sets).toList();
      final rpeValues = allSets.map((s) => s.rpe ?? 7.0).toList();
      final avgRpe = rpeValues.isEmpty
          ? 7.0
          : rpeValues.reduce((a, b) => a + b) / rpeValues.length;

      return {
        'user_id': 1,
        'date': _dateFmt.format(w.date),
        'duration_minutes': w.duration.inMinutes.clamp(1, 1440),
        'rpe': double.parse(avgRpe.toStringAsFixed(1)),
      };
    }).toList();
  }

  double _d(dynamic v) => (v as num).toDouble();
}
