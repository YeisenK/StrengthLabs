import 'package:asip_fitness_analytics/shared/models/plan_workout.dart';
import 'package:flutter/material.dart';

class WeeklyPlanList extends StatefulWidget {
  final List<PlanWorkout> workouts;

  const WeeklyPlanList({super.key, required this.workouts});

  @override
  State<WeeklyPlanList> createState() => _WeeklyPlanListState();
}

class _WeeklyPlanListState extends State<WeeklyPlanList> {
  final Map<String, bool> _expandedDays = {};

  @override
  Widget build(BuildContext context) {
    final workoutsByDay = _groupWorkoutsByDay(widget.workouts);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Plan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...workoutsByDay.entries.map((entry) {
              return _buildDaySection(entry.key, entry.value);
            }),
          ],
        ),
      ),
    );
  }

  Map<String, List<PlanWorkout>> _groupWorkoutsByDay(List<PlanWorkout> workouts) {
    final map = <String, List<PlanWorkout>>{};
    for (var workout in workouts) {
      map.putIfAbsent(workout.day, () => []).add(workout);
    }
    return map;
  }

  Widget _buildDaySection(String day, List<PlanWorkout> workouts) {
    final isExpanded = _expandedDays[day] ?? true;

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            day,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          trailing: IconButton(
            icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onPressed: () {
              setState(() {
                _expandedDays[day] = !isExpanded;
              });
            },
          ),
        ),
        if (isExpanded) ...[
          ...workouts.map((workout) => _buildWorkoutTile(workout)),
        ],
        const Divider(),
      ],
    );
  }

  Widget _buildWorkoutTile(PlanWorkout workout) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        children: [
          Checkbox(
            value: workout.isCompleted,
            onChanged: (value) {
              // Toggle completion state
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.exerciseName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  '${workout.sets}x${workout.repetitions} @ ${workout.targetWeight}kg',
                  style: const TextStyle(fontSize: 12),
                ),
                if (workout.notes != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    workout.notes!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getIntensityColor(workout.intensity).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              workout.intensity,
              style: TextStyle(
                fontSize: 12,
                color: _getIntensityColor(workout.intensity),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getIntensityColor(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'moderate':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}