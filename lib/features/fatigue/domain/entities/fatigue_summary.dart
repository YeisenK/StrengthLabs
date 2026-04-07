import 'package:equatable/equatable.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/exercise.dart';

class FatigueDataPoint extends Equatable {
  const FatigueDataPoint({required this.date, required this.index});
  final DateTime date;
  final double index; // 0–100

  @override
  List<Object?> get props => [date, index];
}

class FatigueSummary extends Equatable {
  const FatigueSummary({
    required this.overallIndex,
    required this.isOvertraining,
    required this.weeklyVolume,
    required this.trend,
    // From /compute/fatigue
    this.atl = 0.0,
    this.ctl = 0.0,
    this.tsb = 0.0,
    this.acwr = 0.0,
    this.monotony = 0.0,
    this.strain = 0.0,
    this.rampRate = 0.0,
    this.readinessScore = 0.0,
    this.riskFlags = const [],
    // From /compute/risk
    this.injuryRiskScore = 0.0,
    this.overtrainingRiskScore = 0.0,
    this.compositeRiskScore = 0.0,
    this.riskLevel = 'low',
    this.dominantFactor = '',
    this.recommendations = const [],
  });

  final double overallIndex; // readiness 0–100 (maps to readinessScore when available)
  final bool isOvertraining;
  final Map<MuscleGroup, double> weeklyVolume; // 0–100 % of weekly limit
  final List<FatigueDataPoint> trend; // last 7 days

  // Computed metrics from compute engine
  final double atl; // Acute Training Load (7-day EWMA)
  final double ctl; // Chronic Training Load (42-day EWMA)
  final double tsb; // Training Stress Balance = CTL - ATL
  final double acwr; // Acute:Chronic Workload Ratio
  final double monotony; // Training monotony index
  final double strain; // Weekly strain (load × monotony)
  final double rampRate; // CTL change last 7 days (ATU/week)
  final double readinessScore; // Composite readiness 0–100
  final List<String> riskFlags;

  // Risk model outputs
  final double injuryRiskScore; // 0.0–1.0
  final double overtrainingRiskScore; // 0.0–1.0
  final double compositeRiskScore; // 0.0–1.0
  final String riskLevel; // 'low' | 'moderate' | 'high' | 'critical'
  final String dominantFactor;
  final List<String> recommendations;

  bool get hasComputeData => atl > 0 || ctl > 0;

  @override
  List<Object?> get props => [
        overallIndex, isOvertraining, weeklyVolume, trend,
        atl, ctl, tsb, acwr, monotony, strain, rampRate, readinessScore,
        riskFlags, injuryRiskScore, overtrainingRiskScore, compositeRiskScore,
        riskLevel, dominantFactor, recommendations,
      ];
}
