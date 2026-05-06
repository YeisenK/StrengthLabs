import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:strengthlabs_beta/core/constants/app_strings.dart';
import 'package:strengthlabs_beta/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:strengthlabs_beta/features/auth/presentation/cubit/auth_state.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/exercise.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/workout.dart';
import 'package:strengthlabs_beta/features/workouts/presentation/cubit/workouts_cubit.dart';
import 'package:strengthlabs_beta/features/workouts/presentation/cubit/workouts_state.dart';
import 'package:strengthlabs_beta/shared/utils/formatters.dart';
import 'package:strengthlabs_beta/shared/widgets/app_button.dart';
import 'package:strengthlabs_beta/shared/widgets/loading_widget.dart';

class WorkoutListPage extends StatefulWidget {
  const WorkoutListPage({super.key});

  @override
  State<WorkoutListPage> createState() => _WorkoutListPageState();
}

class _WorkoutListPageState extends State<WorkoutListPage> {
  DateTimeRange? _dateRange;
  final Set<MuscleGroup> _selectedGroups = {};

  @override
  void initState() {
    super.initState();
    context.read<WorkoutsCubit>().loadWorkouts();
  }

  bool get _hasFilters => _dateRange != null || _selectedGroups.isNotEmpty;

  List<Workout> _applyFilters(List<Workout> all) {
    return all.where((w) {
      if (_dateRange != null) {
        if (w.date.isBefore(_dateRange!.start)) return false;
        if (w.date.isAfter(_dateRange!.end.add(const Duration(days: 1)))) return false;
      }
      if (_selectedGroups.isNotEmpty) {
        final workoutGroups =
            w.exercises.map((e) => e.exercise.muscleGroup).toSet();
        if (workoutGroups.intersection(_selectedGroups).isEmpty) return false;
      }
      return true;
    }).toList();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (picked != null && mounted) {
      setState(() => _dateRange = picked);
    }
  }

  void _toggleGroup(MuscleGroup mg) {
    setState(() {
      if (_selectedGroups.contains(mg)) {
        _selectedGroups.remove(mg);
      } else {
        _selectedGroups.add(mg);
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _dateRange = null;
      _selectedGroups.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => context.read<WorkoutsCubit>().loadWorkouts(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: _FilterBar(
                dateRange: _dateRange,
                selectedGroups: _selectedGroups,
                hasFilters: _hasFilters,
                onDateTap: _pickDateRange,
                onGroupToggle: _toggleGroup,
                onClearAll: _clearFilters,
              ),
            ),
            BlocBuilder<WorkoutsCubit, WorkoutsState>(
              builder: (context, state) {
                if (state is WorkoutsLoading) {
                  return const SliverFillRemaining(
                    child: LoadingWidget(message: 'Loading workouts...'),
                  );
                }
                if (state is WorkoutsError) {
                  return SliverFillRemaining(
                    child: EmptyStateWidget(
                      icon: Icons.error_outline,
                      title: 'Could not load workouts',
                      subtitle: state.message,
                      action: AppButton(
                        label: 'Retry',
                        icon: Icons.refresh,
                        expand: false,
                        onPressed: () =>
                            context.read<WorkoutsCubit>().loadWorkouts(),
                      ),
                    ),
                  );
                }
                if (state is WorkoutsLoaded) {
                  if (state.workouts.isEmpty) {
                    return SliverFillRemaining(
                      child: EmptyStateWidget(
                        icon: Icons.fitness_center,
                        title: AppStrings.noWorkoutsYet,
                        subtitle: AppStrings.noWorkoutsSubtitle,
                        action: AppButton(
                          label: AppStrings.startWorkout,
                          icon: Icons.add,
                          expand: false,
                          onPressed: () => context.push('/active-workout'),
                        ),
                      ),
                    );
                  }
                  final filtered = _applyFilters(state.workouts);
                  if (filtered.isEmpty) {
                    return SliverFillRemaining(
                      child: EmptyStateWidget(
                        icon: Icons.filter_list_off,
                        title: 'No results',
                        subtitle:
                            'No workouts match the applied filters',
                        action: AppButton(
                          label: 'Clear filters',
                          icon: Icons.close,
                          expand: false,
                          onPressed: _clearFilters,
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _WorkoutCard(
                          workout: filtered[i],
                          onTap: () => context.push(
                            '/workouts/detail/${filtered[i].id}',
                          ),
                        ),
                        childCount: filtered.length,
                      ),
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/active-workout'),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.startWorkout),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar.large(
      title: const Text(
        AppStrings.workouts,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () => _showProfileSheet(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<AuthCubit>(),
        child: const _ProfileSheet(),
      ),
    );
  }
}

// ── Filter bar ────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.dateRange,
    required this.selectedGroups,
    required this.hasFilters,
    required this.onDateTap,
    required this.onGroupToggle,
    required this.onClearAll,
  });

  final DateTimeRange? dateRange;
  final Set<MuscleGroup> selectedGroups;
  final bool hasFilters;
  final VoidCallback onDateTap;
  final ValueChanged<MuscleGroup> onGroupToggle;
  final VoidCallback onClearAll;

  String get _dateLabel {
    if (dateRange == null) return 'Date';
    final f = Formatters.dateShort;
    return '${f(dateRange!.start)} – ${f(dateRange!.end)}';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          if (hasFilters) ...[
            _Chip(
              label: 'Clear',
              icon: Icons.close,
              isSelected: false,
              onTap: onClearAll,
            ),
            const SizedBox(width: 4),
          ],
          _Chip(
            label: _dateLabel,
            icon: Icons.calendar_today_outlined,
            isSelected: dateRange != null,
            onTap: onDateTap,
          ),
          ...MuscleGroup.values.map(
            (mg) => _Chip(
              label: mg.label,
              isSelected: selectedGroups.contains(mg),
              onTap: () => onGroupToggle(mg),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Workout card ──────────────────────────────────────────────────────────────

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({required this.workout, required this.onTap});

  final Workout workout;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        workout.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      Formatters.dateShort(workout.date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _Stat(
                      icon: Icons.timer_outlined,
                      label: Formatters.duration(workout.duration),
                    ),
                    const SizedBox(width: 20),
                    _Stat(
                      icon: Icons.fitness_center_outlined,
                      label: Formatters.exerciseCount(workout.exercises.length),
                    ),
                    const SizedBox(width: 20),
                    _Stat(
                      icon: Icons.monitor_weight_outlined,
                      label: Formatters.volume(workout.totalVolume),
                    ),
                  ],
                ),
                if (workout.exercises.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    children: workout.exercises
                        .map((e) => e.exercise.muscleGroup)
                        .toSet()
                        .map((mg) => _MuscleChip(label: mg.label))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _MuscleChip extends StatelessWidget {
  const _MuscleChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

// ── Profile sheet ─────────────────────────────────────────────────────────────

class _ProfileSheet extends StatelessWidget {
  const _ProfileSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthCubit>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(Icons.person,
                size: 32, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 12),
          Text(
            user?.name ?? 'Guest',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            user?.email ?? '—',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text(AppStrings.logout),
            onTap: () async {
              Navigator.pop(context);
              await context.read<AuthCubit>().logout();
            },
          ),
        ],
      ),
    );
  }
}
