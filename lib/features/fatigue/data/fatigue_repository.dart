import 'package:strengthlabs_beta/core/storage/workout_local_storage.dart';
import 'package:strengthlabs_beta/features/fatigue/domain/entities/fatigue_summary.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/exercise.dart';

class FatigueRepository {
  FatigueRepository(this._localStorage);

  final WorkoutLocalStorage _localStorage;

  // Sets per muscle group per week considered 100% volume
  static const _maxSetsPerWeek = 20.0;

  Future<FatigueSummary> getSummary() async {
    final workouts = await _localStorage.load();
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    // Weekly volume per muscle group (set count → 0–100 %)
    final volumeMap = <MuscleGroup, double>{
      for (final mg in MuscleGroup.values) mg: 0.0,
    };

    for (final w in workouts.where((w) => w.date.isAfter(weekAgo))) {
      for (final we in w.exercises) {
        final mg = we.exercise.muscleGroup;
        volumeMap[mg] = (volumeMap[mg] ?? 0.0) + we.sets.length;
      }
    }

    final weeklyVolume = volumeMap.map(
      (mg, sets) =>
          MapEntry(mg, (sets / _maxSetsPerWeek * 100).clamp(0.0, 100.0)),
    );

    // 7-day daily fatigue trend
    final trend = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayWorkouts = workouts.where(
        (w) =>
            !w.date.isBefore(dayStart) &&
            w.date.isBefore(dayEnd),
      );

      double index = 0;
      for (final w in dayWorkouts) {
        final allSets = w.exercises.expand((e) => e.sets).toList();
        final rpeList = allSets.map((s) => s.rpe ?? 7.0).toList();
        final avgRpe = rpeList.isEmpty
            ? 7.0
            : rpeList.reduce((a, b) => a + b) / rpeList.length;
        index += (w.duration.inMinutes * avgRpe / 10).clamp(0.0, 100.0);
      }

      return FatigueDataPoint(
        date: day,
        index: index.clamp(0.0, 100.0),
      );
    });

    final avgLoad = trend.map((p) => p.index).reduce((a, b) => a + b) / 7;
    final overallIndex = (100 - avgLoad).clamp(0.0, 100.0);

    return FatigueSummary(
      overallIndex: overallIndex,
      isOvertraining: avgLoad > 70,
      weeklyVolume: weeklyVolume,
      trend: trend,
    );
  }
}
