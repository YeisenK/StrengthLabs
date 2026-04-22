import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strengthlabs_beta/core/constants/app_colors.dart';
import 'package:strengthlabs_beta/core/constants/app_strings.dart';
import 'package:strengthlabs_beta/features/export/data/export_service.dart';
import 'package:strengthlabs_beta/features/workouts/presentation/cubit/workouts_cubit.dart';
import 'package:strengthlabs_beta/features/workouts/presentation/cubit/workouts_state.dart';
import 'package:strengthlabs_beta/shared/utils/formatters.dart';

enum _ExportStatus { idle, loading, success }

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  DateTimeRange _range = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  _ExportStatus _xlsxStatus = _ExportStatus.idle;
  _ExportStatus _csvStatus = _ExportStatus.idle;
  String? _lastError;

  final _service = ExportService();

  Future<void> _export({required bool isXlsx}) async {
    final cubitState = context.read<WorkoutsCubit>().state;
    if (cubitState is! WorkoutsLoaded) return;

    final workouts = context.read<WorkoutsCubit>().inRange(_range);

    if (workouts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No workouts found in the selected date range.')),
      );
      return;
    }

    setState(() {
      _lastError = null;
      if (isXlsx) {
        _xlsxStatus = _ExportStatus.loading;
      } else {
        _csvStatus = _ExportStatus.loading;
      }
    });

    try {
      final result = isXlsx
          ? await _service.exportToExcel(workouts)
          : await _service.exportToCsv(workouts);

      if (!mounted) return;
      setState(() {
        if (isXlsx) {
          _xlsxStatus = _ExportStatus.success;
        } else {
          _csvStatus = _ExportStatus.success;
        }
      });

      final base =
          'Exported ${result.rowCount} sets from ${workouts.length} workouts.';
      final message = result.shared ? base : '$base\nSaved to ${result.path}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.green,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _lastError = e.toString();
        if (isXlsx) {
          _xlsxStatus = _ExportStatus.idle;
        } else {
          _csvStatus = _ExportStatus.idle;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $_lastError'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }

    // Reset success indicator after 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() {
      _xlsxStatus = _ExportStatus.idle;
      _csvStatus = _ExportStatus.idle;
    });
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text(
              AppStrings.export_,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Date range
                Text(
                  AppStrings.dateRange,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _DateRangeCard(range: _range, onTap: _pickDateRange),
                const SizedBox(height: 8),
                _WorkoutCountBadge(range: _range),
                const SizedBox(height: 28),

                // Export buttons
                Text(
                  'Export Format',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _ExportCard(
                  icon: Icons.table_chart_outlined,
                  title: AppStrings.exportExcel,
                  subtitle: 'Spreadsheet with styled header and column widths (.xlsx)',
                  status: _xlsxStatus,
                  color: AppColors.green,
                  onTap: () => _export(isXlsx: true),
                ),
                const SizedBox(height: 12),
                _ExportCard(
                  icon: Icons.data_array_outlined,
                  title: AppStrings.exportCsv,
                  subtitle: 'Flat file for custom analysis (.csv)',
                  status: _csvStatus,
                  color: theme.colorScheme.primary,
                  onTap: () => _export(isXlsx: false),
                ),
                const SizedBox(height: 28),

                // Info card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Each row represents one set. Includes date, workout name, exercise, muscle group, weight, reps, RPE, and total volume. Files are saved and shared via your device\'s share sheet.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows how many workouts are in the selected range.
class _WorkoutCountBadge extends StatelessWidget {
  const _WorkoutCountBadge({required this.range});
  final DateTimeRange range;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutsCubit, WorkoutsState>(
      builder: (context, state) {
        if (state is! WorkoutsLoaded) return const SizedBox.shrink();
        final count =
            context.read<WorkoutsCubit>().inRange(range).length;
        final color = count == 0
            ? Theme.of(context).colorScheme.error
            : AppColors.green;
        return Text(
          count == 0
              ? 'No workouts in this range'
              : '$count workout${count == 1 ? '' : 's'} will be exported',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        );
      },
    );
  }
}

class _DateRangeCard extends StatelessWidget {
  const _DateRangeCard({required this.range, required this.onTap});
  final DateTimeRange range;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.date_range_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${Formatters.dateWithYear(range.start)} → ${Formatters.dateWithYear(range.end)}',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${range.duration.inDays + 1} days selected',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.edit_outlined,
                  size: 18, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExportCard extends StatelessWidget {
  const _ExportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final _ExportStatus status;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = status == _ExportStatus.loading;
    final isSuccess = status == _ExportStatus.success;

    return Card(
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    Text(subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: isLoading
                    ? SizedBox(
                        key: const ValueKey('loading'),
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: color),
                      )
                    : isSuccess
                        ? const Icon(
                            key: ValueKey('success'),
                            Icons.check_circle,
                            color: AppColors.green,
                          )
                        : Icon(
                            key: const ValueKey('download'),
                            Icons.download_outlined,
                            color: color,
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
