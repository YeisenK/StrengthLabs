import 'package:asip_fitness_analytics/shared/models/workout_session.dart';

class SessionRepository {
  Future<void> submitSession(WorkoutSession session) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    // Mock API call
    print('Session submitted: ${session.exerciseName}');
  }
}