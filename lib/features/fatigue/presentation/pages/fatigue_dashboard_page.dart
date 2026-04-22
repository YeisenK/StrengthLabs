import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strengthlabs_beta/core/constants/app_colors.dart';
import 'package:strengthlabs_beta/core/constants/app_strings.dart';
import 'package:strengthlabs_beta/features/fatigue/domain/entities/fatigue_summary.dart';
import 'package:strengthlabs_beta/features/fatigue/presentation/cubit/fatigue_cubit.dart';
import 'package:strengthlabs_beta/features/fatigue/presentation/cubit/fatigue_state.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/exercise.dart';
import 'package:strengthlabs_beta/shared/widgets/app_button.dart';
import 'package:strengthlabs_beta/shared/widgets/loading_widget.dart';

class FatigueDashboardPage extends StatefulWidget {
  const FatigueDashboardPage({super.key});

  @override
  State<FatigueDashboardPage> createState() => _FatigueDashboardPageState();
}

class _FatigueDashboardPageState extends State<FatigueDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<FatigueCubit>().loadSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text(
              AppStrings.fatigue,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_outlined),
                onPressed: () => context.read<FatigueCubit>().loadSummary(),
              ),
            ],
          ),
          BlocBuilder<FatigueCubit, FatigueState>(
            builder: (context, state) {
              if (state is FatigueLoading) {
                return const SliverFillRemaining(
                  child: LoadingWidget(message: 'Calculating fatigue...'),
                );
              }
              if (state is FatigueError) {
                return SliverFillRemaining(
                  child: EmptyStateWidget(
                    icon: Icons.error_outline,
                    title: 'Could not load fatigue',
                    subtitle: state.message,
                    action: AppButton(
                      label: 'Retry',
                      icon: Icons.refresh,
                      expand: false,
                      onPressed: () =>
                          context.read<FatigueCubit>().loadSummary(),
                    ),
                  ),
                );
              }
              if (state is FatigueLoaded) {
                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _ReadinessCard(summary: state.summary),
                      const SizedBox(height: 16),
                      if (state.summary.hasComputeData) ...[
                        _MetricsRow(summary: state.summary),
                        const SizedBox(height: 16),
                        _RiskCard(summary: state.summary),
                        const SizedBox(height: 16),
                        if (state.summary.recommendations.isNotEmpty)
                          _RecommendationsCard(
                              summary: state.summary),
                        if (state.summary.recommendations.isNotEmpty)
                          const SizedBox(height: 16),
                      ],
                      _WeeklyTrendCard(summary: state.summary),
                      const SizedBox(height: 16),
                      _MuscleVolumeCard(summary: state.summary),
                      const SizedBox(height: 32),
                    ]),
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

// ─── Readiness Gauge ─────────────────────────────────────────────────────────

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({required this.summary});
  final FatigueSummary summary;

  String get _label {
    final s = summary.hasComputeData
        ? summary.readinessScore
        : summary.overallIndex;
    if (s >= 80) return 'Fresh';
    if (s >= 60) return 'Ready';
    if (s >= 40) return 'Moderate';
    if (s >= 20) return 'Fatigued';
    return 'Depleted';
  }

  String get _subtitle {
    if (!summary.hasComputeData) return AppStrings.fatigueLow;
    final s = summary.readinessScore;
    if (s >= 80) return AppStrings.fatigueLow;
    if (s >= 60) return AppStrings.fatigueMod;
    if (s >= 40) return AppStrings.fatigueHigh;
    return AppStrings.fatigueOver;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = summary.hasComputeData
        ? summary.readinessScore
        : summary.overallIndex;
    final color = AppColors.fatigueColor(score);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              summary.hasComputeData ? 'Readiness Score' : AppStrings.overallFatigue,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 180,
              height: 180,
              child: CustomPaint(
                painter: _GaugePainter(
                  index: score,
                  color: color,
                  trackColor: theme.colorScheme.surfaceVariant,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${score.toInt()}',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        '/ 100',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (!summary.hasComputeData) ...[
              const SizedBox(height: 12),
              Text(
                'Connect compute server for detailed metrics',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Gauge Painter ────────────────────────────────────────────────────────────

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.index,
    required this.color,
    required this.trackColor,
  });

  final double index;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const startAngle = math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final valuePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * (index / 100).clamp(0, 1),
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.index != index || old.color != color;
}

// ─── Metrics Row (ATL / CTL / TSB / ACWR) ────────────────────────────────────

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({required this.summary});
  final FatigueSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            label: 'ATL',
            value: summary.atl.toStringAsFixed(1),
            subtitle: 'Acute load',
            hint: '7-day avg',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricTile(
            label: 'CTL',
            value: summary.ctl.toStringAsFixed(1),
            subtitle: 'Chronic load',
            hint: '42-day avg',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricTile(
            label: 'TSB',
            value: '${summary.tsb >= 0 ? '+' : ''}${summary.tsb.toStringAsFixed(1)}',
            subtitle: 'Balance',
            valueColor: summary.tsb >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricTile(
            label: 'ACWR',
            value: summary.acwr.toStringAsFixed(2),
            subtitle: 'Workload ratio',
            valueColor: _acwrColor(summary.acwr),
          ),
        ),
      ],
    );
  }

  Color _acwrColor(double acwr) {
    if (acwr < 0.8 || acwr > 1.5) return const Color(0xFFEF5350);
    if (acwr > 1.3) return const Color(0xFFFF9800);
    return const Color(0xFF4CAF50);
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.subtitle,
    this.hint,
    this.valueColor,
  });

  final String label;
  final String value;
  final String subtitle;
  final String? hint;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Risk Card ────────────────────────────────────────────────────────────────

class _RiskCard extends StatelessWidget {
  const _RiskCard({required this.summary});
  final FatigueSummary summary;

  Color _levelColor(String level) => switch (level) {
        'low' => const Color(0xFF4CAF50),
        'moderate' => const Color(0xFFFF9800),
        'high' => const Color(0xFFEF5350),
        'critical' => const Color(0xFFB71C1C),
        _ => const Color(0xFF607D8B),
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _levelColor(summary.riskLevel);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Risk Assessment',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.4)),
                  ),
                  child: Text(
                    summary.riskLevel.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _RiskBar(
              label: 'Injury Risk',
              value: summary.injuryRiskScore,
            ),
            const SizedBox(height: 10),
            _RiskBar(
              label: 'Overtraining Risk',
              value: summary.overtrainingRiskScore,
            ),
            const SizedBox(height: 10),
            _RiskBar(
              label: 'Composite Risk',
              value: summary.compositeRiskScore,
              isBold: true,
            ),
            if (summary.riskFlags.isNotEmpty) ...[
              const Divider(height: 24),
              ...summary.riskFlags.map(
                (flag) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_outlined,
                          size: 14, color: Color(0xFFFF9800)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          flag,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RiskBar extends StatelessWidget {
  const _RiskBar({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final double value;
  final bool isBold;

  Color _barColor(double v) {
    if (v < 0.2) return const Color(0xFF4CAF50);
    if (v < 0.45) return const Color(0xFFFF9800);
    if (v < 0.70) return const Color(0xFFEF5350);
    return const Color(0xFFB71C1C);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _barColor(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: isBold ? 8 : 6,
            backgroundColor: theme.colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

// ─── Recommendations ──────────────────────────────────────────────────────────

class _RecommendationsCard extends StatelessWidget {
  const _RecommendationsCard({required this.summary});
  final FatigueSummary summary;

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
                Icon(Icons.lightbulb_outline,
                    size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Recommendations',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...summary.recommendations.map(
              (rec) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '→',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rec,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Weekly Trend ─────────────────────────────────────────────────────────────

class _WeeklyTrendCard extends StatelessWidget {
  const _WeeklyTrendCard({required this.summary});
  final FatigueSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = summary.trend;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '7-Day Trend',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: points.map((p) {
                  final pct = (p.index / 100).clamp(0.0, 1.0);
                  final color = AppColors.fatigueColor(p.index);
                  final isLast = p == points.last;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isLast)
                            Text(
                              '${p.index.toInt()}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          const SizedBox(height: 2),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            height: 50 * pct,
                            decoration: BoxDecoration(
                              color: isLast
                                  ? color
                                  : color.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: points
                  .map((p) => Text(
                        _dayLabel(p.date),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _dayLabel(DateTime d) {
    const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return days[d.weekday - 1];
  }
}

// ─── Muscle Volume ────────────────────────────────────────────────────────────

class _MuscleVolumeCard extends StatelessWidget {
  const _MuscleVolumeCard({required this.summary});
  final FatigueSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.weeklyVolume,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...summary.weeklyVolume.entries.map(
              (entry) => _MuscleBar(
                muscleGroup: entry.key,
                percentage: entry.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MuscleBar extends StatelessWidget {
  const _MuscleBar({
    required this.muscleGroup,
    required this.percentage,
  });

  final MuscleGroup muscleGroup;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppColors.fatigueColor(percentage);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  muscleGroup.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${percentage.toInt()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
