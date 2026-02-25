import 'package:asip_fitness_analytics/features/fatigue/provider/fatigue_provider.dart';
import 'package:asip_fitness_analytics/features/fatigue/widgets/acwr_zone_indicator.dart';
import 'package:asip_fitness_analytics/features/fatigue/widgets/fatigue_chart.dart';
import 'package:asip_fitness_analytics/features/fatigue/widgets/tsb_indicator.dart';
import 'package:asip_fitness_analytics/shared/widgets/loading_indicator.dart';
import 'package:asip_fitness_analytics/shared/widgets/error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FatigueAnalysisScreen extends ConsumerStatefulWidget {
  const FatigueAnalysisScreen({super.key});

  @override
  ConsumerState<FatigueAnalysisScreen> createState() => _FatigueAnalysisScreenState();
}

class _FatigueAnalysisScreenState extends ConsumerState<FatigueAnalysisScreen> {
  Future<void> _refreshData() async {
    ref.invalidate(fatigueMetricsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final metricsAsync = ref.watch(fatigueMetricsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fatigue Analysis'),
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: metricsAsync.when(
          data: (metrics) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ACWR Analysis',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AcwrZoneIndicator(acwr: metrics.acwr),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      TsbIndicator(tsb: metrics.tsb),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FatigueChart(metrics: metrics),
            ],
          ),
          loading: () => const LoadingIndicator(message: 'Loading fatigue analysis...'),
          error: (error, stack) => ErrorView(
            error: error.toString(),
            onRetry: _refreshData,
          ),
        ),
      ),
    );
  }
}