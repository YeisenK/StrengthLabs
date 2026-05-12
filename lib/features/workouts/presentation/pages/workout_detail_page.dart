import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:strengthlabs/features/workouts/domain/entities/exercise.dart';
import 'package:strengthlabs/features/workouts/domain/entities/workout.dart';
import 'package:strengthlabs/features/workouts/domain/entities/workout_set.dart';
import 'package:strengthlabs/features/workouts/presentation/cubit/workouts_cubit.dart';
import 'package:strengthlabs/features/workouts/presentation/cubit/workouts_state.dart';
import 'package:strengthlabs/l10n/app_localizations.dart';
import 'package:strengthlabs/shared/utils/formatters.dart';
import 'package:strengthlabs/shared/widgets/loading_widget.dart';

class WorkoutDetailPage extends StatefulWidget {
  const WorkoutDetailPage({super.key, required this.id});
  final String id;

  @override
  State<WorkoutDetailPage> createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends State<WorkoutDetailPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutsCubit, WorkoutsState>(
      builder: (context, _) {
        final workout = context.read<WorkoutsCubit>().findById(widget.id);

        if (workout == null) {
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
            appBar: AppBar(),
            body: EmptyStateWidget(
              icon: Icons.search_off,
              title: l10n.workoutNotFound,
              subtitle: l10n.workoutNotFoundSubtitle,
            ),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, workout),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _StatsRow(workout: workout),
                    const SizedBox(height: 24),
                    if (workout.notes != null && workout.notes!.isNotEmpty) ...[
                      _SectionHeader(title: AppLocalizations.of(context)!.notes),
                      const SizedBox(height: 8),
                      _NotesCard(notes: workout.notes!),
                      const SizedBox(height: 24),
                    ],
                    _SectionHeader(title: AppLocalizations.of(context)!.exercises),
                    const SizedBox(height: 8),
                    ...workout.exercises.map(
                      (we) => _ExerciseCard(workoutExercise: we),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, Workout workout) {
    return SliverAppBar.medium(
      title: Hero(
        tag: 'workout-title-${workout.id}',
        child: Material(
          type: MaterialType.transparency,
          child: Text(
            workout.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => _editWorkout(context, workout),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _confirmDelete(context, workout),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Future<void> _editWorkout(BuildContext context, Workout workout) async {
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController(text: workout.name);
    final notesCtrl = TextEditingController(text: workout.notes ?? '');

    final cubit = context.read<WorkoutsCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.editWorkout),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: l10n.name),
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: InputDecoration(labelText: l10n.notesOptional),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              minLines: 1,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    final name = nameCtrl.text.trim();
    final notes = notesCtrl.text.trim();

    nameCtrl.dispose();
    notesCtrl.dispose();

    if (confirmed != true) return;
    if (name.isEmpty) return;

    try {
      await cubit.updateWorkout(
        workout.id,
        name: name,
        notes: notes.isEmpty ? null : notes,
      );
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context, Workout workout) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteWorkoutTitle),
        content: Text(l10n.deleteWorkoutHint),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              final cubit = context.read<WorkoutsCubit>();
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(dialogContext);
              context.pop();

              final reason = await messenger.showSnackBar(
                SnackBar(
                  content: Text(l10n.workoutDeleted),
                  action: SnackBarAction(label: l10n.undo, onPressed: () {}),
                  duration: const Duration(seconds: 4),
                ),
              ).closed;

              if (reason != SnackBarClosedReason.action) {
                await cubit.deleteWorkout(workout.id);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.workout});
  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.calendar_today_outlined,
            label: l10n.date,
            value: Formatters.dateWithYear(workout.date),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.timer_outlined,
            label: l10n.duration,
            value: Formatters.duration(workout.duration),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.monitor_weight_outlined,
            label: l10n.volume,
            value: Formatters.volume(workout.totalVolume),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Column(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.notes});
  final String notes;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          notes,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.workoutExercise});
  final WorkoutExercise workoutExercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      workoutExercise.exercise.muscleGroup.localized(AppLocalizations.of(context)!),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                workoutExercise.exercise.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              // Table header
              Row(
                children: [
                  _HeaderCell('SET', flex: 1),
                  _HeaderCell('WEIGHT', flex: 2),
                  _HeaderCell('REPS', flex: 2),
                  _HeaderCell('RPE', flex: 1),
                ],
              ),
              const Divider(height: 8),
              ...workoutExercise.sets.asMap().entries.map(
                    (entry) => _SetRow(
                      setNumber: entry.key + 1,
                      workoutSet: entry.value,
                    ),
                  ),
              const SizedBox(height: 4),
              Text(
                'Total: ${Formatters.volume(workoutExercise.totalVolume)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.text, {required this.flex});
  final String text;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({required this.setNumber, required this.workoutSet});
  final int setNumber;
  final WorkoutSet workoutSet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '$setNumber',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              workoutSet.weight > 0 ? '${workoutSet.weight} kg' : 'BW',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${workoutSet.reps}',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              workoutSet.rpe != null ? '${workoutSet.rpe}' : '—',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
