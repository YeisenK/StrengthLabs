import 'package:equatable/equatable.dart';

class ComputeMetrics extends Equatable {
  const ComputeMetrics({
    required this.atl,
    required this.ctl,
    required this.tsb,
    required this.acwr,
    required this.monotony,
    required this.strain,
    required this.rampRate,
    required this.readinessScore,
    required this.riskFlags,
    required this.injuryRiskScore,
    required this.overtrainingRiskScore,
    required this.compositeRiskScore,
    required this.riskLevel,
    required this.dominantFactor,
    required this.recommendations,
  });

  final double atl;
  final double ctl;
  final double tsb;
  final double acwr;
  final double monotony;
  final double strain;
  final double rampRate;
  final double readinessScore;
  final List<String> riskFlags;
  final double injuryRiskScore;
  final double overtrainingRiskScore;
  final double compositeRiskScore;
  final String riskLevel;
  final String dominantFactor;
  final List<String> recommendations;

  @override
  List<Object?> get props => [
        atl, ctl, tsb, acwr, monotony, strain, rampRate, readinessScore,
        riskFlags, injuryRiskScore, overtrainingRiskScore, compositeRiskScore,
        riskLevel, dominantFactor, recommendations,
      ];
}
