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
  });

  final double overallIndex; // 0–100
  final bool isOvertraining;
  final Map<MuscleGroup, double> weeklyVolume; // 0–100 % of weekly limit
  final List<FatigueDataPoint> trend; // last 7 days

  @override
  List<Object?> get props => [overallIndex, isOvertraining, weeklyVolume, trend];
}
