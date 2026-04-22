import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:strengthlabs_beta/core/constants/app_colors.dart';
import 'package:strengthlabs_beta/core/constants/app_strings.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/exercise.dart';
import 'package:strengthlabs_beta/features/workouts/presentation/cubit/active_workout_cubit.dart';
import 'package:strengthlabs_beta/features/workouts/presentation/cubit/active_workout_state.dart';
import 'package:strengthlabs_beta/features/workouts/presentation/cubit/workouts_cubit.dart';
import 'package:strengthlabs_beta/shared/utils/formatters.dart';
import 'package:strengthlabs_beta/shared/widgets/app_button.dart';
import 'package:strengthlabs_beta/shared/widgets/loading_widget.dart';

class ActiveWorkoutPage extends StatefulWidget {
  const ActiveWorkoutPage({super.key, this.template});

  final ActiveWorkoutTemplate? template;

  @override
  State<ActiveWorkoutPage> createState() => _ActiveWorkoutPageState();
}

class _ActiveWorkoutPageState extends State<ActiveWorkoutPage> {
  late final ActiveWorkoutCubit _cubit;
  final ValueNotifier<Duration> _elapsed = ValueNotifier(Duration.zero);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _cubit = ActiveWorkoutCubit();
    if (widget.template != null) _cubit.loadTemplate(widget.template!);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed.value = _cubit.state.elapsed;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _elapsed.dispose();
    _cubit.close();
    super.dispose();
  }

  void _finishWorkout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Finish workout?'),
        content: const Text('Only completed sets will be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep going'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final workout = _cubit.finish();
              try {
                await context.read<WorkoutsCubit>().saveWorkout(workout);
                if (mounted) context.go('/workouts');
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString().replaceFirst('Exception: ', ''),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  void _discardWorkout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Discard workout?'),
        content: const Text('All progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep going'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<ActiveWorkoutCubit, ActiveWorkoutState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _discardWorkout,
              ),
              title: _WorkoutNameField(
                initialName: state.name,
                onChanged: _cubit.setName,
              ),
              actions: [
                ValueListenableBuilder<Duration>(
                  valueListenable: _elapsed,
                  builder: (_, elapsed, _) => _TimerChip(elapsed: elapsed),
                ),
                const SizedBox(width: 12),
              ],
            ),
            body: SafeArea(
              top: false,
              bottom: false,
              child: state.exercises.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.add_circle_outline,
                      title: 'No exercises yet',
                      subtitle: 'Add your first exercise to get started',
                      action: AppButton(
                        label: AppStrings.addExercise,
                        icon: Icons.add,
                        expand: false,
                        onPressed: () => _showExercisePicker(context, state),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      itemCount: state.exercises.length,
                      itemBuilder: (context, i) {
                        final ae = state.exercises[i];
                        return _ActiveExerciseCard(
                          activeExercise: ae,
                          cubit: _cubit,
                        );
                      },
                    ),
            ),
            bottomNavigationBar: _BottomBar(
              onAddExercise: () => _showExercisePicker(context, state),
              onFinish: _finishWorkout,
              exerciseCount: state.exercises.length,
            ),
          );
        },
      ),
    );
  }

  void _showExercisePicker(BuildContext context, ActiveWorkoutState state) {
    final exercises = context.read<WorkoutsCubit>().exercises;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ExercisePickerSheet(
        exercises: exercises,
        onPick: (exercise) {
          _cubit.addExercise(exercise);
          Navigator.pop(context);
        },
        onCreateExercise: (name, mg) =>
            context.read<WorkoutsCubit>().createExercise(name, mg),
      ),
    );
  }
}

class _WorkoutNameField extends StatefulWidget {
  const _WorkoutNameField({
    required this.initialName,
    required this.onChanged,
  });
  final String initialName;
  final ValueChanged<String> onChanged;

  @override
  State<_WorkoutNameField> createState() => _WorkoutNameFieldState();
}

class _WorkoutNameFieldState extends State<_WorkoutNameField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => FocusScope.of(context).unfocus(),
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

class _TimerChip extends StatelessWidget {
  const _TimerChip({required this.elapsed});
  final Duration elapsed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 14,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            Formatters.stopwatch(elapsed),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
          ),
        ],
      ),
    );
  }
}

class _ActiveExerciseCard extends StatelessWidget {
  const _ActiveExerciseCard({
    required this.activeExercise,
    required this.cubit,
  });

  final ActiveExercise activeExercise;
  final ActiveWorkoutCubit cubit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeExercise.exercise.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (activeExercise.targetReps != null &&
                          activeExercise.targetReps!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Target: ${activeExercise.sets.length} × ${activeExercise.targetReps!}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () =>
                      cubit.removeExercise(activeExercise.id),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Header row
            Row(
              children: const [
                SizedBox(width: 32),
                Expanded(flex: 2, child: _ColHeader('WEIGHT')),
                SizedBox(width: 8),
                Expanded(flex: 2, child: _ColHeader('REPS')),
                SizedBox(width: 8),
                Expanded(flex: 1, child: _ColHeader('RPE')),
                SizedBox(width: 8),
                SizedBox(width: 32),
              ],
            ),
            const SizedBox(height: 4),
            ...activeExercise.sets.asMap().entries.map(
                  (entry) => _ActiveSetRow(
                    setNumber: entry.key + 1,
                    activeSet: entry.value,
                    exerciseId: activeExercise.id,
                    cubit: cubit,
                  ),
                ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => cubit.addSet(activeExercise.id),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add set'),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColHeader extends StatelessWidget {
  const _ColHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
    );
  }
}

class _ActiveSetRow extends StatefulWidget {
  const _ActiveSetRow({
    required this.setNumber,
    required this.activeSet,
    required this.exerciseId,
    required this.cubit,
  });

  final int setNumber;
  final ActiveSet activeSet;
  final String exerciseId;
  final ActiveWorkoutCubit cubit;

  @override
  State<_ActiveSetRow> createState() => _ActiveSetRowState();
}

class _ActiveSetRowState extends State<_ActiveSetRow> {
  late final TextEditingController _weightCtrl;
  late final TextEditingController _repsCtrl;
  double? _rpe;

  @override
  void initState() {
    super.initState();
    _weightCtrl = TextEditingController(text: widget.activeSet.weight);
    _repsCtrl = TextEditingController(text: widget.activeSet.reps);
    _rpe = widget.activeSet.rpe;
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  void _sync({bool? completed}) {
    widget.cubit.updateSet(
      widget.exerciseId,
      widget.activeSet.id,
      weight: _weightCtrl.text,
      reps: _repsCtrl.text,
      rpe: _rpe,
      isCompleted: completed ?? widget.activeSet.isCompleted,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = widget.activeSet.isCompleted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.green.withOpacity(0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '${widget.setNumber}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _SetInput(
              controller: _weightCtrl,
              hint: '0',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _sync(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _SetInput(
              controller: _repsCtrl,
              hint: '0',
              keyboardType: TextInputType.number,
              onChanged: (_) => _sync(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: _RpeDropdown(
              value: _rpe,
              onChanged: (v) {
                setState(() => _rpe = v);
                _sync();
              },
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              final newCompleted = !isCompleted;
              _sync(completed: newCompleted);
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.green
                    : theme.colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: 16,
                color: isCompleted
                    ? Colors.white
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetInput extends StatelessWidget {
  const _SetInput({
    required this.controller,
    required this.hint,
    required this.keyboardType,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      textAlign: TextAlign.center,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _RpeDropdown extends StatelessWidget {
  const _RpeDropdown({required this.value, required this.onChanged});
  final double? value;
  final ValueChanged<double?> onChanged;

  static final _options = [
    6.0, 6.5, 7.0, 7.5, 8.0, 8.5, 9.0, 9.5, 10.0,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<double>(
          value: value,
          hint: Text(
            '—',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          isDense: true,
          isExpanded: true,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          items: _options
              .map((v) => DropdownMenuItem(
                    value: v,
                    child: Text(
                      '$v',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ExercisePickerSheet extends StatefulWidget {
  const _ExercisePickerSheet({
    required this.exercises,
    required this.onPick,
    required this.onCreateExercise,
  });
  final List<Exercise> exercises;
  final ValueChanged<Exercise> onPick;
  final Future<Exercise> Function(String name, MuscleGroup mg) onCreateExercise;

  @override
  State<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<_ExercisePickerSheet> {
  final _searchCtrl = TextEditingController();
  MuscleGroup? _selectedGroup;
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Exercise> get _filtered {
    return widget.exercises.where((e) {
      final matchesQuery =
          _query.isEmpty || e.name.toLowerCase().contains(_query.toLowerCase());
      final matchesGroup =
          _selectedGroup == null || e.muscleGroup == _selectedGroup;
      return matchesQuery && matchesGroup;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Add Exercise',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: 8),
          // Muscle group filter chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedGroup == null,
                  onTap: () => setState(() => _selectedGroup = null),
                ),
                ...MuscleGroup.values.map(
                  (mg) => _FilterChip(
                    label: mg.label,
                    isSelected: _selectedGroup == mg,
                    onTap: () => setState(
                      () => _selectedGroup =
                          _selectedGroup == mg ? null : mg,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Exercise list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.45,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final ex = _filtered[i];
                return ListTile(
                  title: Text(ex.name),
                  subtitle: Text(ex.muscleGroup.label),
                  trailing: const Icon(Icons.add_circle_outline),
                  onTap: () => widget.onPick(ex),
                );
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Create custom exercise'),
            onTap: () => _showCreateDialog(context),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext sheetContext) async {
    // Capture before first async gap.
    final messenger = ScaffoldMessenger.of(sheetContext);
    final errorColor = Theme.of(sheetContext).colorScheme.error;

    final nameCtrl = TextEditingController();
    MuscleGroup selectedGroup = MuscleGroup.chest;

    final confirmed = await showDialog<bool>(
      context: sheetContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('New exercise'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                textCapitalization: TextCapitalization.words,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<MuscleGroup>(
                value: selectedGroup,
                decoration: const InputDecoration(labelText: 'Muscle group'),
                items: MuscleGroup.values
                    .map((mg) => DropdownMenuItem(
                          value: mg,
                          child: Text(mg.label),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setDialogState(() => selectedGroup = v);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    final name = nameCtrl.text.trim(); // read before dispose
    nameCtrl.dispose();
    if (confirmed != true || !mounted) return;
    if (name.isEmpty) return;

    try {
      final exercise = await widget.onCreateExercise(name, selectedGroup);
      if (mounted) widget.onPick(exercise);
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
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.onAddExercise,
    required this.onFinish,
    required this.exerciseCount,
  });

  final VoidCallback onAddExercise;
  final VoidCallback onFinish;
  final int exerciseCount;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onAddExercise,
                icon: const Icon(Icons.add, size: 18),
                label: const Text(AppStrings.addExercise),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: exerciseCount > 0 ? onFinish : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(AppStrings.finishWorkout),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
