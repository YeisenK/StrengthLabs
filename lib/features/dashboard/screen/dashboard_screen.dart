import 'package:asip_fitness_analytics/features/dashboard/widgets/metric_card.dart';
import 'package:asip_fitness_analytics/features/dashboard/widgets/chart_card.dart';
import 'package:asip_fitness_analytics/features/dashboard/widgets/recent_sessions_list.dart';
import 'package:asip_fitness_analytics/features/dashboard/widgets/alerts_banner.dart';
import 'package:asip_fitness_analytics/features/dashboard/provider/dashboard_provider.dart';
import 'package:asip_fitness_analytics/shared/widgets/loading_indicator.dart';
import 'package:asip_fitness_analytics/shared/widgets/error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/semantics.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Future<void> _refreshData() async {
    ref.invalidate(fatigueMetricsProvider);
    ref.invalidate(recentSessionsProvider);
    ref.invalidate(activeAlertsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final metricsAsync = ref.watch(fatigueMetricsProvider);
    final sessionsAsync = ref.watch(recentSessionsProvider);
    final alertsAsync = ref.watch(activeAlertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh dashboard data',
            semanticsLabel: 'Refresh dashboard data',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Semantics(
              label: 'Active alerts section',
              child: alertsAsync.when(
                data: (alerts) => AlertsBanner(alerts: alerts),
                loading: () => const SizedBox(height: 60),
                error: (_, __) => const SizedBox(),
              ),
            ),
            const SizedBox(height: 16),
            metricsAsync.when(
              data: (metrics) => LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              MetricCard(metrics: metrics),
                              const SizedBox(height: 16),
                              ChartCard(metrics: metrics),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: RecentSessionsList(sessionsAsync: sessionsAsync),
                        ),
                      ],
                    );
                  }
                  
                  return Column(
                    children: [
                      MetricCard(metrics: metrics),
                      const SizedBox(height: 16),
                      ChartCard(metrics: metrics),
                      const SizedBox(height: 16),
                      RecentSessionsList(sessionsAsync: sessionsAsync),
                    ],
                  );
                },
              ),
              loading: () => const LoadingIndicator(message: 'Loading metrics...'),
              error: (error, stack) => ErrorView(
                error: error.toString(),
                onRetry: _refreshData,
              ),
            ),
          ],
        ),
      ),
    );
  }
}