import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:strengthlabs_beta/core/constants/app_strings.dart';
import 'package:strengthlabs_beta/features/routines/domain/entities/routine.dart';
import 'package:strengthlabs_beta/features/routines/presentation/cubit/routines_cubit.dart';
import 'package:strengthlabs_beta/features/routines/presentation/cubit/routines_state.dart';
import 'package:strengthlabs_beta/shared/widgets/app_button.dart';
import 'package:strengthlabs_beta/shared/widgets/loading_widget.dart';

class RoutinesPage extends StatefulWidget {
  const RoutinesPage({super.key});

  @override
  State<RoutinesPage> createState() => _RoutinesPageState();
}

class _RoutinesPageState extends State<RoutinesPage> {
  RoutineLevel? _selectedLevel;

  @override
  void initState() {
    super.initState();
    context.read<RoutinesCubit>().loadRoutines();
  }

  void _filter(RoutineLevel? level) {
    setState(() => _selectedLevel = level);
    context.read<RoutinesCubit>().loadRoutines(level: level);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text(
              AppStrings.routines,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SliverToBoxAdapter(
            child: _LevelFilterRow(
              selected: _selectedLevel,
              onChanged: _filter,
            ),
          ),
          BlocBuilder<RoutinesCubit, RoutinesState>(
            builder: (context, state) {
              if (state is RoutinesLoading) {
                return const SliverFillRemaining(
                  child: LoadingWidget(message: 'Loading routines...'),
                );
              }
              if (state is RoutinesError) {
                return SliverFillRemaining(
                  child: EmptyStateWidget(
                    icon: Icons.error_outline,
                    title: 'Could not load routines',
                    subtitle: state.message,
                    action: AppButton(
                      label: 'Retry',
                      icon: Icons.refresh,
                      expand: false,
                      onPressed: () => context
                          .read<RoutinesCubit>()
                          .loadRoutines(level: _selectedLevel),
                    ),
                  ),
                );
              }
              if (state is RoutinesLoaded) {
                if (state.routines.isEmpty) {
                  return const SliverFillRemaining(
                    child: EmptyStateWidget(
                      icon: Icons.view_list_outlined,
                      title: 'No routines found',
                      subtitle: 'Try a different filter',
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _RoutineCard(
                        routine: state.routines[i],
                        onTap: () => context.push(
                          '/routines/detail/${state.routines[i].id}',
                        ),
                      ),
                      childCount: state.routines.length,
                    ),
                  ),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
        ],
      ),
    );
  }
}

class _LevelFilterRow extends StatelessWidget {
  const _LevelFilterRow({required this.selected, required this.onChanged});
  final RoutineLevel? selected;
  final ValueChanged<RoutineLevel?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _Chip(
            label: 'All',
            isSelected: selected == null,
            onTap: () => onChanged(null),
          ),
          ...RoutineLevel.values.map(
            (l) => _Chip(
              label: l.label,
              isSelected: selected == l,
              onTap: () => onChanged(selected == l ? null : l),
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
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: isSelected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({required this.routine, required this.onTap});
  final Routine routine;
  final VoidCallback onTap;

  Color _levelColor(BuildContext context, RoutineLevel level) {
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
    final levelColor = _levelColor(context, routine.level);

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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: levelColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        routine.level.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: levelColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        routine.goal.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  routine.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  routine.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${routine.daysPerWeek} days / week',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.view_day_outlined,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${routine.days.length} training days',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
