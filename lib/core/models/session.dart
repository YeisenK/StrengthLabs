// lib/core/models/session.dart

class TrainingSession {
  final String id;
  final DateTime date;
  final List<ExerciseLog> exercises;
  final int rpeGlobal;
  final int? avgHeartRate;
  final double? sleepHours;
  final double? bodyweight;

  const TrainingSession({
    required this.id,
    required this.date,
    required this.exercises,
    required this.rpeGlobal,
    this.avgHeartRate,
    this.sleepHours,
    this.bodyweight,
  });

  int get totalSets => exercises.fold(0, (sum, e) => sum + e.sets.length);

  double get totalVolume => exercises.fold(
        0,
        (sum, e) => sum +
            e.sets.fold(
              0.0,
              (s, set) => s + (set.weight ?? 0) * (set.reps ?? 0),
            ),
      );

  static List<TrainingSession> mockRecentSessions() => [
        TrainingSession(
          id: '1',
          date: DateTime.now().subtract(const Duration(days: 1)),
          exercises: [
            const ExerciseLog(
              name: 'Sentadilla Trasera',
              muscleGroup: 'Cuádriceps · Glúteos',
              sets: [
                SetLog(weight: 80, reps: 8, rpe: 7, rir: 1),
                SetLog(weight: 82.5, reps: 7, rpe: 8, rir: 1),
                SetLog(weight: 82.5, reps: 6, rpe: 9, rir: 0),
              ],
            ),
            const ExerciseLog(
              name: 'Press Banca',
              muscleGroup: 'Pectoral · Tríceps',
              sets: [
                SetLog(weight: 60, reps: 10, rpe: 6, rir: 2),
                SetLog(weight: 62.5, reps: 9, rpe: 7, rir: 1),
              ],
            ),
          ],
          rpeGlobal: 7,
          avgHeartRate: 142,
          sleepHours: 7.5,
        ),
      ];
}

class ExerciseLog {
  final String name;
  final String muscleGroup;
  final List<SetLog> sets;

  const ExerciseLog({
    required this.name,
    required this.muscleGroup,
    required this.sets,
  });
}

class SetLog {
  final double? weight;
  final int? reps;
  final int? rpe;
  final int? rir;
  final bool completed;

  const SetLog({
    this.weight,
    this.reps,
    this.rpe,
    this.rir,
    this.completed = true,
  });
}
