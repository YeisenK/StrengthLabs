import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strengthlabs_beta/features/fatigue/data/compute_repository.dart';
import 'package:strengthlabs_beta/features/fatigue/data/fatigue_repository.dart';
import 'package:strengthlabs_beta/features/fatigue/domain/entities/fatigue_metrics.dart';
import 'package:strengthlabs_beta/features/fatigue/domain/entities/fatigue_summary.dart';
import 'package:strengthlabs_beta/features/fatigue/presentation/cubit/fatigue_state.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/exercise.dart';

class FatigueCubit extends Cubit<FatigueState> {
  FatigueCubit(this._repository, this._computeRepo) : super(const FatigueInitial());

  final FatigueRepository _repository;
  final ComputeRepository _computeRepo;

  Future<void> loadSummary() async {
    emit(const FatigueLoading());

    // Try basic summary from API (weeklyVolume + trend)
    FatigueSummary base;
    try {
      base = await _repository.getSummary();
    } on DioException {
      base = _emptyFallback();
    } catch (_) {
      base = _emptyFallback();
    }

    // Enrich with compute metrics (independent server, may be offline)
    ComputeMetrics? metrics;
    try {
      metrics = await _computeRepo.computeMetrics();
    } catch (_) {
      // Compute server unavailable — show base summary only
    }

    if (metrics != null) {
      emit(FatigueLoaded(FatigueSummary(
        overallIndex: metrics.readinessScore,
        isOvertraining: metrics.riskLevel == 'critical',
        weeklyVolume: base.weeklyVolume,
        trend: base.trend,
        atl: metrics.atl,
        ctl: metrics.ctl,
        tsb: metrics.tsb,
        acwr: metrics.acwr,
        monotony: metrics.monotony,
        strain: metrics.strain,
        rampRate: metrics.rampRate,
        readinessScore: metrics.readinessScore,
        riskFlags: metrics.riskFlags,
        injuryRiskScore: metrics.injuryRiskScore,
        overtrainingRiskScore: metrics.overtrainingRiskScore,
        compositeRiskScore: metrics.compositeRiskScore,
        riskLevel: metrics.riskLevel,
        dominantFactor: metrics.dominantFactor,
        recommendations: metrics.recommendations,
      )));
    } else {
      emit(FatigueLoaded(base));
    }
  }

  FatigueSummary _emptyFallback() {
    final now = DateTime.now();
    return FatigueSummary(
      overallIndex: 0,
      isOvertraining: false,
      weeklyVolume: {
        for (final mg in MuscleGroup.values) mg: 0.0,
      },
      trend: List.generate(
        7,
        (i) => FatigueDataPoint(
          date: now.subtract(Duration(days: 6 - i)),
          index: 0,
        ),
      ),
    );
  }
}
