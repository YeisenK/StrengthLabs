import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strengthlabs_beta/features/fatigue/domain/entities/fatigue_metrics.dart';
import 'package:strengthlabs_beta/features/fatigue/domain/entities/fatigue_summary.dart';
import 'package:strengthlabs_beta/features/fatigue/presentation/cubit/fatigue_cubit.dart';
import 'package:strengthlabs_beta/features/fatigue/presentation/cubit/fatigue_state.dart';
import 'package:strengthlabs_beta/features/plan/domain/entities/training_plan.dart';
import 'package:strengthlabs_beta/features/plan/presentation/cubit/plan_cubit.dart';
import 'package:strengthlabs_beta/features/plan/presentation/cubit/plan_state.dart';
import 'package:strengthlabs_beta/shared/widgets/loading_widget.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  int? _daysToEvent;
  ComputeMetrics? _lastMetrics;

  @override
  void initState() {
    super.initState();
    _tryGenerate();
  }

  void _tryGenerate() {
    final fatigueState = context.read<FatigueCubit>().state;
    if (fatigueState is FatigueLoaded && fatigueState.summary.hasComputeData) {
      _generateFromSummary(fatigueState.summary);
    }
  }

  void _generateFromSummary(FatigueSummary summary) {
    final metrics = ComputeMetrics(
      atl: summary.atl,
      ctl: summary.ctl,
      tsb: summary.tsb,
      acwr: summary.acwr,
      monotony: summary.monotony,
      strain: summary.strain,
      rampRate: summary.rampRate,
      readinessScore: summary.readinessScore,
      riskFlags: summary.riskFlags,
      injuryRiskScore: summary.injuryRiskScore,
      overtrainingRiskScore: summary.overtrainingRiskScore,
      compositeRiskScore: summary.compositeRiskScore,
      riskLevel: summary.riskLevel,
      dominantFactor: summary.dominantFactor,
      recommendations: summary.recommendations,
    );
    _lastMetrics = metrics;
    context.read<PlanCubit>().generatePlan(
          metrics: metrics,
          daysToEvent: _daysToEvent,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text(
              'Training Plan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.event_outlined),
                tooltip: 'Set event date',
                onPressed: _pickEventDate,
              ),
            ],
          ),
          BlocBuilder<FatigueCubit, FatigueState>(
            builder: (context, fatigueState) {
              if (fatigueState is FatigueLoaded &&
                  !fatigueState.summary.hasComputeData &&
                  context.read<PlanCubit>().state is PlanInitial) {
                return SliverFillRemaining(
                  child: _NoMetricsMessage(
                    onRetry: () => context.read<FatigueCubit>().loadSummary(),
                  ),
                );
              }

              // Trigger plan generation when fatigue loads with data
              if (fatigueState is FatigueLoaded &&
                  fatigueState.summary.hasComputeData &&
                  context.read<PlanCubit>().state is PlanInitial) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _generateFromSummary(fatigueState.summary);
                });
              }

              return BlocBuilder<PlanCubit, PlanState>(
                builder: (context, state) {
                  if (state is PlanLoading) {
                    return const SliverFillRemaining(
                      child: LoadingWidget(message: 'Generating plan...'),
                    );
                  }
                  if (state is PlanError) {
                    return SliverFillRemaining(
                      child: _ErrorMessage(
                        message: state.message,
                        onRetry: _tryGenerate,
                      ),
                    );
                  }
                  if (state is PlanLoaded) {
                    return _PlanContent(
                      plan: state.plan,
                      daysToEvent: _daysToEvent,
                    );
                  }
                  return const SliverFillRemaining(
                    child: LoadingWidget(message: 'Loading fatigue data...'),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickEventDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) {
      setState(() {
        _daysToEvent = date.difference(DateTime.now()).inDays;
      });
      if (_lastMetrics != null) {
        context.read<PlanCubit>().generatePlan(
              metrics: _lastMetrics!,
              daysToEvent: _daysToEvent,
            );
      }
    }
  }
}

class _PlanContent extends StatelessWidget {
  const _PlanContent({required this.plan, this.daysToEvent});
  final TrainingPlan plan;
  final int? daysToEvent;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _PhaseBanner(plan: plan, daysToEvent: daysToEvent),
          const SizedBox(height: 16),
          _ObjectiveCard(plan: plan),
          const SizedBox(height: 16),
          _WeeklyScheduleCard(plan: plan),
          const SizedBox(height: 16),
          _CoachNotesCard(plan: plan),
          const SizedBox(height: 16),
          _RationaleCard(plan: plan),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }
}

class _PhaseBanner extends StatelessWidget {
  const _PhaseBanner({required this.plan, this.daysToEvent});
  final TrainingPlan plan;
  final int? daysToEvent;

  Color _phaseColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (plan.phase) {
      'accumulation' => const Color(0xFF4CAF50),
      'transmutation' => const Color(0xFF2196F3),
      'realization' => const Color(0xFFFF9800),
      'recovery' => const Color(0xFF9C27B0),
      'transition' => const Color(0xFF607D8B),
      _ => cs.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _phaseColor(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.phase.toUpperCase(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.microcycleType.replaceAll('_', ' ').toUpperCase(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (daysToEvent != null)
                    Text(
                      'Event in $daysToEvent days',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${plan.targetWeeklyLoad.toInt()} ATU',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  'target load',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${plan.loadAdjustmentPct > 0 ? '+' : ''}${plan.loadAdjustmentPct.toStringAsFixed(1)}%',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: plan.loadAdjustmentPct >= 0
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFEF5350),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ObjectiveCard extends StatelessWidget {
  const _ObjectiveCard({required this.plan});
  final TrainingPlan plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag_outlined,
                    size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Week Objective',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              plan.weekObjective,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatChip(
                  label: 'ACWR',
                  value: plan.targetAcwr.toStringAsFixed(2),
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: 'ΔTSB',
                  value: '${plan.projectedTsbDelta > 0 ? '+' : ''}'
                      '${plan.projectedTsbDelta.toStringAsFixed(1)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyScheduleCard extends StatelessWidget {
  const _WeeklyScheduleCard({required this.plan});
  final TrainingPlan plan;

  Color _zoneColor(String zone) => switch (zone) {
        'z1_recovery' => const Color(0xFF4CAF50),
        'z2_aerobic' => const Color(0xFF2196F3),
        'z3_tempo' => const Color(0xFFFF9800),
        'z4_threshold' => const Color(0xFFEF5350),
        'z5_neuromuscular' => const Color(0xFF9C27B0),
        _ => const Color(0xFF607D8B),
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Weekly Schedule',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...plan.sessions.map((s) => _SessionTile(
                  session: s,
                  zoneColor: s.isRest ? const Color(0xFF607D8B) : _zoneColor(s.intensityZone),
                )),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session, required this.zoneColor});
  final PlanSession session;
  final Color zoneColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Text(
              session.dayName,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Container(
            width: 3,
            height: session.isRest ? 24 : 52,
            decoration: BoxDecoration(
              color: zoneColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: session.isRest
                ? Text(
                    'Rest',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              session.sessionType,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (session.keySession)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9800).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '★ KEY',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF9800),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${session.durationMinutes} min · RPE ${session.rpeTarget.toStringAsFixed(0)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _CoachNotesCard extends StatelessWidget {
  const _CoachNotesCard({required this.plan});
  final TrainingPlan plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ExpansionTile(
        leading: Icon(Icons.sports_outlined, color: theme.colorScheme.primary),
        title: Text(
          'Coach Notes',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        initiallyExpanded: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: plan.coachNotes.map((note) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '•',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          note,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RationaleCard extends StatelessWidget {
  const _RationaleCard({required this.plan});
  final TrainingPlan plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ExpansionTile(
        leading:
            Icon(Icons.science_outlined, color: theme.colorScheme.primary),
        title: Text(
          'Periodization Rationale',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              plan.periodizationRationale,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoMetricsMessage extends StatelessWidget {
  const _NoMetricsMessage({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sensors_off_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Compute server unavailable',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'The training plan requires the compute engine to be running. '
              'Start the backend server and go to the Fatigue tab first.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF5350)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
