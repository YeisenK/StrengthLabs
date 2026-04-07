import 'package:strengthlabs_beta/features/routines/domain/entities/routine.dart';
import 'package:strengthlabs_beta/features/workouts/data/mock_workouts.dart';

final List<Routine> kMockRoutines = [
  Routine(
    id: 'r1',
    name: 'Beginner Full Body',
    level: RoutineLevel.beginner,
    goal: RoutineGoal.generalFitness,
    daysPerWeek: 3,
    description:
        'A 3-day full-body program ideal for those starting out. Covers all major muscle groups each session with basic compound movements.',
    days: [
      RoutineDay(
        name: 'Day A',
        exercises: [
          RoutineExercise(
            exercise: kExerciseCatalog[3], // Barbell Squat
            sets: 3,
            repsScheme: '5',
          ),
          RoutineExercise(
            exercise: kExerciseCatalog[0], // Bench Press
            sets: 3,
            repsScheme: '5',
          ),
          RoutineExercise(
            exercise: kExerciseCatalog[8], // Seated Row
            sets: 3,
            repsScheme: '5',
          ),
        ],
      ),
      RoutineDay(
        name: 'Day B',
        exercises: [
          RoutineExercise(
            exercise: kExerciseCatalog[3], // Squat
            sets: 3,
            repsScheme: '5',
          ),
          RoutineExercise(
            exercise: kExerciseCatalog[9], // OHP
            sets: 3,
            repsScheme: '5',
          ),
          RoutineExercise(
            exercise: kExerciseCatalog[6], // Deadlift
            sets: 1,
            repsScheme: '5',
          ),
        ],
      ),
    ],
  ),
  Routine(
    id: 'r2',
    name: 'Push Pull Legs',
    level: RoutineLevel.intermediate,
    goal: RoutineGoal.hypertrophy,
    daysPerWeek: 6,
    description:
        'Classic PPL split for intermediate lifters. Each muscle group trained twice per week with high volume for maximum hypertrophy.',
    days: [
      RoutineDay(
        name: 'Push',
        exercises: [
          RoutineExercise(exercise: kExerciseCatalog[0], sets: 4, repsScheme: '6-8'),
          RoutineExercise(exercise: kExerciseCatalog[1], sets: 3, repsScheme: '8-12'),
          RoutineExercise(exercise: kExerciseCatalog[9], sets: 3, repsScheme: '8-12'),
          RoutineExercise(exercise: kExerciseCatalog[10], sets: 4, repsScheme: '12-15'),
          RoutineExercise(exercise: kExerciseCatalog[12], sets: 3, repsScheme: '12-15'),
        ],
      ),
      RoutineDay(
        name: 'Pull',
        exercises: [
          RoutineExercise(exercise: kExerciseCatalog[6], sets: 3, repsScheme: '5'),
          RoutineExercise(exercise: kExerciseCatalog[7], sets: 4, repsScheme: '6-10'),
          RoutineExercise(exercise: kExerciseCatalog[8], sets: 4, repsScheme: '8-12'),
          RoutineExercise(exercise: kExerciseCatalog[14], sets: 3, repsScheme: '12-15'),
          RoutineExercise(exercise: kExerciseCatalog[15], sets: 3, repsScheme: '12-15'),
        ],
      ),
      RoutineDay(
        name: 'Legs',
        exercises: [
          RoutineExercise(exercise: kExerciseCatalog[3], sets: 4, repsScheme: '6-8'),
          RoutineExercise(exercise: kExerciseCatalog[4], sets: 3, repsScheme: '8-12'),
          RoutineExercise(exercise: kExerciseCatalog[5], sets: 3, repsScheme: '10-15'),
          RoutineExercise(exercise: kExerciseCatalog[17], sets: 3, repsScheme: '10-15'),
        ],
      ),
    ],
  ),
  Routine(
    id: 'r3',
    name: 'Upper / Lower Split',
    level: RoutineLevel.intermediate,
    goal: RoutineGoal.strength,
    daysPerWeek: 4,
    description:
        'A 4-day upper/lower program balancing strength and hypertrophy. Each session alternates between heavy compound work and accessory volume.',
    days: [
      RoutineDay(
        name: 'Upper — Strength',
        exercises: [
          RoutineExercise(exercise: kExerciseCatalog[0], sets: 4, repsScheme: '4-6', notes: 'Increase weight each week'),
          RoutineExercise(exercise: kExerciseCatalog[7], sets: 4, repsScheme: '4-6'),
          RoutineExercise(exercise: kExerciseCatalog[9], sets: 3, repsScheme: '6-8'),
          RoutineExercise(exercise: kExerciseCatalog[8], sets: 3, repsScheme: '8-10'),
        ],
      ),
      RoutineDay(
        name: 'Lower — Strength',
        exercises: [
          RoutineExercise(exercise: kExerciseCatalog[3], sets: 4, repsScheme: '4-6'),
          RoutineExercise(exercise: kExerciseCatalog[6], sets: 3, repsScheme: '4-5'),
          RoutineExercise(exercise: kExerciseCatalog[5], sets: 3, repsScheme: '8-10'),
        ],
      ),
      RoutineDay(
        name: 'Upper — Hypertrophy',
        exercises: [
          RoutineExercise(exercise: kExerciseCatalog[1], sets: 4, repsScheme: '8-12'),
          RoutineExercise(exercise: kExerciseCatalog[8], sets: 4, repsScheme: '10-12'),
          RoutineExercise(exercise: kExerciseCatalog[10], sets: 3, repsScheme: '12-15'),
          RoutineExercise(exercise: kExerciseCatalog[12], sets: 3, repsScheme: '12-15'),
          RoutineExercise(exercise: kExerciseCatalog[14], sets: 3, repsScheme: '12-15'),
        ],
      ),
      RoutineDay(
        name: 'Lower — Hypertrophy',
        exercises: [
          RoutineExercise(exercise: kExerciseCatalog[4], sets: 4, repsScheme: '10-12'),
          RoutineExercise(exercise: kExerciseCatalog[5], sets: 4, repsScheme: '12-15'),
          RoutineExercise(exercise: kExerciseCatalog[16], sets: 3, repsScheme: '60s hold'),
        ],
      ),
    ],
  ),
  Routine(
    id: 'r4',
    name: '5/3/1 Powerlifting',
    level: RoutineLevel.advanced,
    goal: RoutineGoal.strength,
    daysPerWeek: 4,
    description:
        'Jim Wendler\'s 5/3/1 program. Built around four main lifts with percentage-based loading and a simple weekly progression model.',
    days: [
      RoutineDay(
        name: 'Squat Day',
        exercises: [
          RoutineExercise(
            exercise: kExerciseCatalog[3],
            sets: 3,
            repsScheme: '5/3/1+',
            notes: 'Week 1: 65/75/85%  Week 2: 70/80/90%  Week 3: 75/85/95%',
          ),
          RoutineExercise(exercise: kExerciseCatalog[5], sets: 5, repsScheme: '10'),
          RoutineExercise(exercise: kExerciseCatalog[4], sets: 3, repsScheme: '10'),
        ],
      ),
      RoutineDay(
        name: 'Bench Day',
        exercises: [
          RoutineExercise(
            exercise: kExerciseCatalog[0],
            sets: 3,
            repsScheme: '5/3/1+',
            notes: 'Week 1: 65/75/85%  Week 2: 70/80/90%  Week 3: 75/85/95%',
          ),
          RoutineExercise(exercise: kExerciseCatalog[8], sets: 5, repsScheme: '10'),
          RoutineExercise(exercise: kExerciseCatalog[12], sets: 5, repsScheme: '10'),
        ],
      ),
      RoutineDay(
        name: 'Deadlift Day',
        exercises: [
          RoutineExercise(
            exercise: kExerciseCatalog[6],
            sets: 3,
            repsScheme: '5/3/1+',
            notes: 'Week 1: 65/75/85%  Week 2: 70/80/90%  Week 3: 75/85/95%',
          ),
          RoutineExercise(exercise: kExerciseCatalog[3], sets: 5, repsScheme: '10'),
          RoutineExercise(exercise: kExerciseCatalog[7], sets: 5, repsScheme: '10'),
        ],
      ),
      RoutineDay(
        name: 'OHP Day',
        exercises: [
          RoutineExercise(
            exercise: kExerciseCatalog[9],
            sets: 3,
            repsScheme: '5/3/1+',
            notes: 'Week 1: 65/75/85%  Week 2: 70/80/90%  Week 3: 75/85/95%',
          ),
          RoutineExercise(exercise: kExerciseCatalog[1], sets: 5, repsScheme: '10'),
          RoutineExercise(exercise: kExerciseCatalog[14], sets: 5, repsScheme: '10'),
        ],
      ),
    ],
  ),
];
