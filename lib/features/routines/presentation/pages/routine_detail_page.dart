import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:strengthlabs/features/routines/domain/entities/routine.dart';
import 'package:strengthlabs/features/workouts/domain/entities/exercise.dart';
import 'package:strengthlabs/features/routines/presentation/cubit/routines_cubit.dart';
import 'package:strengthlabs/features/workouts/presentation/cubit/active_workout_cubit.dart';
import 'package:strengthlabs/features/workouts/presentation/cubit/workouts_cubit.dart';
import 'package:strengthlabs/l10n/app_localizations.dart';
import 'package:strengthlabs/shared/widgets/app_button.dart';
import 'package:strengthlabs/shared/widgets/loading_widget.dart';

class RoutineDetailPage extends StatefulWidget {
  const RoutineDetailPage({super.key, required this.id});
  final String id;

  @override
  State<RoutineDetailPage> createState() => _RoutineDetailPageState();
}

class _RoutineDetailPageState extends State<RoutineDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Routine? _routine;

  @override
  void initState() {
    super.initState();
    _routine = context.read<RoutinesCubit>().findById(widget.id);
    _tabController = TabController(
      length: _routine?.days.length ?? 0,
      vsync: this,
    );
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final detail = await context.read<RoutinesCubit>().fetchDetail(widget.id);
    if (detail == null || !mounted) return;
    // Only swap the TabController when the tab count actually changes —
    // disposing+recreating it on every load allocates a new Ticker, and
    // with SingleTickerProviderStateMixin this throws. TickerProviderState
    // would allow it, but skipping the recreate is also cheaper.
    final needsRebuild = detail.days.length != _tabController.length;
    if (needsRebuild) _tabController.dispose();
    setState(() {
      _routine = detail;
      if (needsRebuild) {
        _tabController =
            TabController(length: detail.days.length, vsync: this);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _startRoutine(Routine routine) {
    if (routine.days.isEmpty) return;
    final dayIndex = _tabController.index.clamp(0, routine.days.length - 1);
    final day = routine.days[dayIndex];

    // The backend serialises routine exercises with synthetic ids like
    // "ex-barbell-bench-press" that aren't in the `exercises` table. Mock
    // routines reference mock-only ids for the same reason. Either way,
    // posting the resulting workout would 400 on /workouts. Resolve to a
    // real catalogue exercise by name so finish-workout actually persists.
    final catalog = context.read<WorkoutsCubit>().exercises;
    final entries = day.exercises.map((re) {
      final match = catalog.cast<Exercise?>().firstWhere(
            (e) => e!.name.toLowerCase() == re.exercise.name.toLowerCase(),
            orElse: () => null,
          ) ??
          re.exercise;
      return TemplateEntry(
        exercise: match,
        sets: re.sets,
        targetReps: re.repsScheme,
      );
    }).toList();

    context.push(
      '/active-workout',
      extra: ActiveWorkoutTemplate(
        name: '${routine.name} — ${day.name}',
        entries: entries,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routine = _routine;

    if (routine == null) {
      final l10n = AppLocalizations.of(context)!;
      return Scaffold(
        appBar: AppBar(),
        body: EmptyStateWidget(
          icon: Icons.search_off,
          title: l10n.routineNotFound,
          subtitle: l10n.routineNotFoundSubtitle,
        ),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            title: Hero(
              tag: 'routine-${routine.id}',
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  routine.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _RoutineHeader(routine: routine),
            ),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: routine.days.length > 3,
              tabs: routine.days
                  .map((d) => Tab(text: d.name))
                  .toList(),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: routine.days
              .map((day) => _DayView(day: day))
              .toList(),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: AppButton(
            label: AppLocalizations.of(context)!.startThisRoutine,
            icon: Icons.play_arrow_rounded,
            onPressed: routine.days.isEmpty ? null : () => _startRoutine(routine),
          ),
        ),
      ),
    );
  }
}

class _RoutineHeader extends StatelessWidget {
  const _RoutineHeader({required this.routine});
  final Routine routine;

  Color _levelColor(RoutineLevel level) {
    switch (level) {
      case RoutineLevel.beginner:
        return const Color(0xFF10B981);
      case RoutineLevel.intermediate:
        return const Color(0xFFF59E0B);
      case RoutineLevel.advanced:
        return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final levelColor = _levelColor(routine.level);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
            theme.colorScheme.surface,
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              _Badge(
                label: routine.level.localized(AppLocalizations.of(context)!),
                color: levelColor,
              ),
              const SizedBox(width: 8),
              _Badge(
                label: routine.goal.localized(AppLocalizations.of(context)!),
                color: theme.colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${AppLocalizations.of(context)!.daysPerWeek(routine.daysPerWeek)}  ·  ${AppLocalizations.of(context)!.trainingDaysCount(routine.days.length)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _DayView extends StatelessWidget {
  const _DayView({required this.day});
  final RoutineDay day;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          AppLocalizations.of(context)!.exercisesCount(day.exercises.length),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 12),
        ...day.exercises.asMap().entries.map(
              (entry) => _ExerciseRow(
                index: entry.key + 1,
                routineExercise: entry.value,
              ),
            ),
      ],
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.index, required this.routineExercise});
  final int index;
  final RoutineExercise routineExercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routineExercise.exercise.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      routineExercise.exercise.muscleGroup.localized(AppLocalizations.of(context)!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (routineExercise.notes != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        routineExercise.notes!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${routineExercise.sets} × ${routineExercise.repsScheme}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
