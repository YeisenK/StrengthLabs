import 'package:asip_fitness_analytics/shared/models/workout_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class RecentSessionsList extends ConsumerWidget {
  final AsyncValue<List<WorkoutSession>> sessionsAsync;

  const RecentSessionsList({super.key, required this.sessionsAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Sessions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            sessionsAsync.when(
              data: (sessions) => Column(
                children: sessions.map((session) => _buildSessionTile(session)).toList(),
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTile(WorkoutSession session) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(session.exerciseName),
      subtitle: Text(
        '${session.sets}x${session.repetitions} @ ${session.weight}kg',
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${session.sessionLoad}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            DateFormat('MM/dd').format(session.date),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}