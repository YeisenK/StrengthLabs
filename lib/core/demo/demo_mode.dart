import 'package:flutter/foundation.dart';
import 'package:strengthlabs_beta/features/auth/domain/entities/user.dart';
import 'package:strengthlabs_beta/features/fatigue/domain/entities/fatigue_summary.dart';
import 'package:strengthlabs_beta/features/workouts/data/mock_workouts.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/exercise.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/workout.dart';

/// In-session demo mode. Activated when the user logs in with the
/// hardcoded `example@example.com` / `example` credentials. While active,
/// every repository short-circuits its API call and serves mock data from
/// here. Not persisted across restarts — closing the app returns to login.
class DemoMode {
  DemoMode._();

  static const email = 'example@example.com';
  static const password = 'example';

  static const User user = User(
    id: 'demo-user',
    name: 'Demo User',
    email: email,
  );

  static bool _active = false;
  static bool get isActive => _active;

  static final List<Workout> _workouts = List.of(kMockWorkouts);
  static final List<Exercise> _exercises = List.of(kExerciseCatalog);

  static List<Workout> get workouts => List<Workout>.of(_workouts);
  static List<Exercise> get exercises => List<Exercise>.of(_exercises);

  static bool credentialsMatch(String email, String password) {
    return email.trim().toLowerCase() == DemoMode.email &&
        password == DemoMode.password;
  }

  static void enable() {
    _active = true;
    if (kDebugMode) debugPrint('[demo] demo mode enabled');
  }

  static void disable() {
    _active = false;
    _workouts
      ..clear()
      ..addAll(kMockWorkouts);
    _exercises
      ..clear()
      ..addAll(kExerciseCatalog);
  }

  static void addWorkout(Workout w) => _workouts.insert(0, w);

  static void replaceWorkout(String id, Workout updated) {
    final i = _workouts.indexWhere((w) => w.id == id);
    if (i >= 0) _workouts[i] = updated;
  }

  static void removeWorkout(String id) =>
      _workouts.removeWhere((w) => w.id == id);

  static void addExercise(Exercise e) => _exercises.add(e);

  static String newId(String prefix) =>
      '${prefix}_${DateTime.now().millisecondsSinceEpoch}';

  /// Hand-tuned fatigue snapshot roughly consistent with [kMockWorkouts].
  static FatigueSummary fatigueSummary() {
    final now = DateTime.now();
    final trend = List.generate(14, (i) {
      final date = now.subtract(Duration(days: 13 - i));
      final base = 35.0 + (i * 1.5).clamp(0, 25).toDouble();
      final jitter = (i % 3) * 2.5;
      return FatigueDataPoint(date: date, index: base + jitter);
    });

    return FatigueSummary(
      overallIndex: 68.0,
      isOvertraining: false,
      weeklyVolume: const {
        MuscleGroup.chest: 4500,
        MuscleGroup.back: 5200,
        MuscleGroup.legs: 7800,
        MuscleGroup.shoulders: 2100,
        MuscleGroup.arms: 1800,
        MuscleGroup.core: 600,
      },
      trend: trend,
      atl: 42.5,
      ctl: 38.0,
      tsb: -4.5,
      acwr: 1.12,
      monotony: 1.4,
      strain: 260.0,
      rampRate: 2.3,
      readinessScore: 68.0,
      riskFlags: const [],
      injuryRiskScore: 0.20,
      overtrainingRiskScore: 0.18,
      compositeRiskScore: 0.19,
      riskLevel: 'low',
      dominantFactor: 'Acute workload',
      recommendations: const [
        'Training load is well balanced — maintain current plan',
        'Log every session and aim for 2–3% weight progression on main lifts',
      ],
    );
  }
}
