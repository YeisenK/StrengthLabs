import 'package:strengthlabs_beta/features/workouts/domain/entities/exercise.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/workout.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/workout_set.dart';

// Global exercise catalog — also used by routines and the exercise picker
const List<Exercise> kExerciseCatalog = [
  Exercise(id: 'e1', name: 'Bench Press', muscleGroup: MuscleGroup.chest),
  Exercise(id: 'e2', name: 'Incline Dumbbell Press', muscleGroup: MuscleGroup.chest),
  Exercise(id: 'e3', name: 'Cable Fly', muscleGroup: MuscleGroup.chest),
  Exercise(id: 'e4', name: 'Barbell Squat', muscleGroup: MuscleGroup.legs),
  Exercise(id: 'e5', name: 'Romanian Deadlift', muscleGroup: MuscleGroup.legs),
  Exercise(id: 'e6', name: 'Leg Press', muscleGroup: MuscleGroup.legs),
  Exercise(id: 'e7', name: 'Deadlift', muscleGroup: MuscleGroup.back),
  Exercise(id: 'e8', name: 'Pull-up', muscleGroup: MuscleGroup.back),
  Exercise(id: 'e9', name: 'Seated Cable Row', muscleGroup: MuscleGroup.back),
  Exercise(id: 'e10', name: 'Overhead Press', muscleGroup: MuscleGroup.shoulders),
  Exercise(id: 'e11', name: 'Lateral Raise', muscleGroup: MuscleGroup.shoulders),
  Exercise(id: 'e12', name: 'Face Pull', muscleGroup: MuscleGroup.shoulders),
  Exercise(id: 'e13', name: 'Tricep Pushdown', muscleGroup: MuscleGroup.arms),
  Exercise(id: 'e14', name: 'Skull Crusher', muscleGroup: MuscleGroup.arms),
  Exercise(id: 'e15', name: 'Bicep Curl', muscleGroup: MuscleGroup.arms),
  Exercise(id: 'e16', name: 'Hammer Curl', muscleGroup: MuscleGroup.arms),
  Exercise(id: 'e17', name: 'Plank', muscleGroup: MuscleGroup.core),
  Exercise(id: 'e18', name: 'Ab Wheel Rollout', muscleGroup: MuscleGroup.core),
];

final List<Workout> kMockWorkouts = [
  Workout(
    id: 'w1',
    name: 'Push Day A',
    date: DateTime.now().subtract(const Duration(days: 2)),
    duration: const Duration(hours: 1, minutes: 15),
    exercises: [
      WorkoutExercise(
        exercise: kExerciseCatalog[0], // Bench Press
        sets: [
          WorkoutSet(id: 's1', weight: 90, reps: 5, rpe: 8.0),
          WorkoutSet(id: 's2', weight: 90, reps: 5, rpe: 8.5),
          WorkoutSet(id: 's3', weight: 90, reps: 4, rpe: 9.0),
          WorkoutSet(id: 's4', weight: 85, reps: 5, rpe: 8.0),
        ],
      ),
      WorkoutExercise(
        exercise: kExerciseCatalog[1], // Incline DB Press
        sets: [
          WorkoutSet(id: 's5', weight: 32, reps: 10, rpe: 8.0),
          WorkoutSet(id: 's6', weight: 32, reps: 9, rpe: 8.5),
          WorkoutSet(id: 's7', weight: 30, reps: 10, rpe: 8.0),
        ],
      ),
      WorkoutExercise(
        exercise: kExerciseCatalog[9], // OHP
        sets: [
          WorkoutSet(id: 's8', weight: 60, reps: 8, rpe: 7.5),
          WorkoutSet(id: 's9', weight: 60, reps: 8, rpe: 8.0),
          WorkoutSet(id: 's10', weight: 60, reps: 7, rpe: 8.5),
        ],
      ),
    ],
    notes: 'Felt strong today, bench is improving.',
  ),
  Workout(
    id: 'w2',
    name: 'Pull Day A',
    date: DateTime.now().subtract(const Duration(days: 4)),
    duration: const Duration(hours: 1, minutes: 5),
    exercises: [
      WorkoutExercise(
        exercise: kExerciseCatalog[6], // Deadlift
        sets: [
          WorkoutSet(id: 's11', weight: 140, reps: 5, rpe: 8.0),
          WorkoutSet(id: 's12', weight: 140, reps: 5, rpe: 8.5),
          WorkoutSet(id: 's13', weight: 140, reps: 4, rpe: 9.0),
        ],
      ),
      WorkoutExercise(
        exercise: kExerciseCatalog[7], // Pull-up
        sets: [
          WorkoutSet(id: 's14', weight: 0, reps: 10, rpe: 8.0),
          WorkoutSet(id: 's15', weight: 0, reps: 9, rpe: 8.5),
          WorkoutSet(id: 's16', weight: 0, reps: 8, rpe: 9.0),
          WorkoutSet(id: 's17', weight: 0, reps: 7, rpe: 9.5),
        ],
      ),
      WorkoutExercise(
        exercise: kExerciseCatalog[8], // Seated Row
        sets: [
          WorkoutSet(id: 's18', weight: 75, reps: 10, rpe: 7.5),
          WorkoutSet(id: 's19', weight: 75, reps: 10, rpe: 8.0),
          WorkoutSet(id: 's20', weight: 75, reps: 9, rpe: 8.5),
        ],
      ),
    ],
  ),
  Workout(
    id: 'w3',
    name: 'Leg Day',
    date: DateTime.now().subtract(const Duration(days: 6)),
    duration: const Duration(hours: 1, minutes: 30),
    exercises: [
      WorkoutExercise(
        exercise: kExerciseCatalog[3], // Squat
        sets: [
          WorkoutSet(id: 's21', weight: 110, reps: 5, rpe: 8.0),
          WorkoutSet(id: 's22', weight: 110, reps: 5, rpe: 8.5),
          WorkoutSet(id: 's23', weight: 110, reps: 5, rpe: 9.0),
          WorkoutSet(id: 's24', weight: 100, reps: 6, rpe: 8.0),
        ],
      ),
      WorkoutExercise(
        exercise: kExerciseCatalog[4], // RDL
        sets: [
          WorkoutSet(id: 's25', weight: 80, reps: 10, rpe: 7.5),
          WorkoutSet(id: 's26', weight: 80, reps: 10, rpe: 8.0),
          WorkoutSet(id: 's27', weight: 80, reps: 8, rpe: 8.5),
        ],
      ),
      WorkoutExercise(
        exercise: kExerciseCatalog[5], // Leg Press
        sets: [
          WorkoutSet(id: 's28', weight: 160, reps: 12, rpe: 7.0),
          WorkoutSet(id: 's29', weight: 160, reps: 12, rpe: 7.5),
          WorkoutSet(id: 's30', weight: 160, reps: 10, rpe: 8.0),
        ],
      ),
    ],
    notes: 'Legs are brutal today. Squats felt heavy.',
  ),
  Workout(
    id: 'w4',
    name: 'Upper Body',
    date: DateTime.now().subtract(const Duration(days: 9)),
    duration: const Duration(hours: 1, minutes: 20),
    exercises: [
      WorkoutExercise(
        exercise: kExerciseCatalog[0], // Bench Press
        sets: [
          WorkoutSet(id: 's31', weight: 87.5, reps: 5, rpe: 8.0),
          WorkoutSet(id: 's32', weight: 87.5, reps: 5, rpe: 8.0),
          WorkoutSet(id: 's33', weight: 87.5, reps: 5, rpe: 8.5),
        ],
      ),
      WorkoutExercise(
        exercise: kExerciseCatalog[7], // Pull-up
        sets: [
          WorkoutSet(id: 's34', weight: 0, reps: 11, rpe: 8.0),
          WorkoutSet(id: 's35', weight: 0, reps: 10, rpe: 8.5),
          WorkoutSet(id: 's36', weight: 0, reps: 9, rpe: 9.0),
        ],
      ),
      WorkoutExercise(
        exercise: kExerciseCatalog[9], // OHP
        sets: [
          WorkoutSet(id: 's37', weight: 57.5, reps: 8, rpe: 7.5),
          WorkoutSet(id: 's38', weight: 57.5, reps: 8, rpe: 8.0),
          WorkoutSet(id: 's39', weight: 57.5, reps: 7, rpe: 8.5),
        ],
      ),
    ],
  ),
  Workout(
    id: 'w5',
    name: 'Full Body',
    date: DateTime.now().subtract(const Duration(days: 12)),
    duration: const Duration(hours: 1, minutes: 45),
    exercises: [
      WorkoutExercise(
        exercise: kExerciseCatalog[3], // Squat
        sets: [
          WorkoutSet(id: 's40', weight: 105, reps: 5, rpe: 7.5),
          WorkoutSet(id: 's41', weight: 105, reps: 5, rpe: 8.0),
          WorkoutSet(id: 's42', weight: 105, reps: 5, rpe: 8.5),
        ],
      ),
      WorkoutExercise(
        exercise: kExerciseCatalog[0], // Bench Press
        sets: [
          WorkoutSet(id: 's43', weight: 85, reps: 5, rpe: 7.5),
          WorkoutSet(id: 's44', weight: 85, reps: 5, rpe: 8.0),
          WorkoutSet(id: 's45', weight: 85, reps: 5, rpe: 8.0),
        ],
      ),
      WorkoutExercise(
        exercise: kExerciseCatalog[6], // Deadlift
        sets: [
          WorkoutSet(id: 's46', weight: 135, reps: 5, rpe: 8.0),
          WorkoutSet(id: 's47', weight: 135, reps: 5, rpe: 8.5),
        ],
      ),
    ],
  ),
];
