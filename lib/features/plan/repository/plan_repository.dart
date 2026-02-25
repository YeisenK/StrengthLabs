import 'package:asip_fitness_analytics/shared/models/plan_workout.dart';

class PlanRepository {
  Future<List<PlanWorkout>> getWeeklyPlan() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    
    return [
      PlanWorkout(
        id: '1',
        day: 'Monday',
        exerciseName: 'Barbell Squat',
        sets: 5,
        repetitions: 5,
        targetWeight: 100.0,
        intensity: 'High',
        notes: 'Focus on depth',
      ),
      PlanWorkout(
        id: '2',
        day: 'Monday',
        exerciseName: 'Bench Press',
        sets: 5,
        repetitions: 5,
        targetWeight: 80.0,
        intensity: 'High',
      ),
      PlanWorkout(
        id: '3',
        day: 'Wednesday',
        exerciseName: 'Deadlift',
        sets: 3,
        repetitions: 5,
        targetWeight: 140.0,
        intensity: 'High',
        notes: 'Use straps if needed',
      ),
      PlanWorkout(
        id: '4',
        day: 'Wednesday',
        exerciseName: 'Overhead Press',
        sets: 4,
        repetitions: 8,
        targetWeight: 50.0,
        intensity: 'Moderate',
      ),
      PlanWorkout(
        id: '5',
        day: 'Friday',
        exerciseName: 'Barbell Row',
        sets: 4,
        repetitions: 8,
        targetWeight: 70.0,
        intensity: 'Moderate',
      ),
      PlanWorkout(
        id: '6',
        day: 'Friday',
        exerciseName: 'Pull-ups',
        sets: 3,
        repetitions: 10,
        targetWeight: 0.0,
        intensity: 'Moderate',
      ),
    ];
  }

  Future<Map<String, dynamic>> getRecommendation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return {
      'title': 'Volume Adjustment',
      'description': 'Based on your TSB of 13.2, you are in a recovered state. Consider increasing volume by 5-10% this week.',
      'adjustments': [
        'Increase squat volume by 2 sets',
        'Maintain deadlift intensity',
        'Add accessory work',
      ],
    };
  }
}