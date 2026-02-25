import 'package:asip_fitness_analytics/shared/models/workout_session.dart';
import 'package:asip_fitness_analytics/shared/models/alert.dart';
import 'package:asip_fitness_analytics/shared/models/fatigue_metrics.dart';

class DashboardRepository {
  // Mock API call
  Future<FatigueMetrics> getCurrentMetrics() async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    return FatigueMetrics(
      atl: 85.5,
      ctl: 72.3,
      tsb: 13.2,
      acwr: 1.18,
      atlHistory: [65.2, 70.1, 75.3, 78.4, 82.1, 84.6, 85.5],
      ctlHistory: [68.1, 68.9, 69.8, 70.5, 71.2, 71.8, 72.3],
      dates: List.generate(7, (i) => DateTime.now().subtract(Duration(days: 6 - i))),
    );
  }

  Future<List<WorkoutSession>> getRecentSessions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      WorkoutSession(
        id: '1',
        date: DateTime.now().subtract(const Duration(days: 1)),
        exerciseName: 'Barbell Squat',
        sets: 5,
        repetitions: 5,
        weight: 100.0,
        rpe: 8,
        sessionLoad: 2500,
      ),
      WorkoutSession(
        id: '2',
        date: DateTime.now().subtract(const Duration(days: 2)),
        exerciseName: 'Bench Press',
        sets: 4,
        repetitions: 8,
        weight: 80.0,
        rpe: 7,
        sessionLoad: 2560,
      ),
      WorkoutSession(
        id: '3',
        date: DateTime.now().subtract(const Duration(days: 3)),
        exerciseName: 'Deadlift',
        sets: 3,
        repetitions: 5,
        weight: 140.0,
        rpe: 9,
        sessionLoad: 2100,
      ),
      WorkoutSession(
        id: '4',
        date: DateTime.now().subtract(const Duration(days: 4)),
        exerciseName: 'Overhead Press',
        sets: 3,
        repetitions: 10,
        weight: 50.0,
        rpe: 6,
        sessionLoad: 1500,
      ),
      WorkoutSession(
        id: '5',
        date: DateTime.now().subtract(const Duration(days: 5)),
        exerciseName: 'Barbell Row',
        sets: 4,
        repetitions: 8,
        weight: 70.0,
        rpe: 7,
        sessionLoad: 2240,
      ),
    ];
  }

  Future<List<Alert>> getActiveAlerts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      Alert(
        id: '1',
        message: 'ACWR above optimal range. Monitor fatigue.',
        severity: AlertSeverity.warning,
        timestamp: DateTime.now(),
      ),
    ];
  }
}