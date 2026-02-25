import 'package:asip_fitness_analytics/shared/models/fatigue_metrics.dart';
import 'package:asip_fitness_analytics/shared/utils/risk_zone_util.dart';
import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final FatigueMetrics metrics;

  const MetricCard({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final zone = RiskZoneUtil.getRiskZone(metrics.acwr);
    final zoneColor = RiskZoneUtil.getZoneColor(zone);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Key Metrics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'ACWR value: ${metrics.acwr.toStringAsFixed(2)}',
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      context,
                      label: 'ACWR',
                      value: metrics.acwr.toStringAsFixed(2),
                      color: zoneColor,
                    ),
                  ),
                  Expanded(
                    child: _buildMetricItem(
                      context,
                      label: 'TSB',
                      value: metrics.tsb.toStringAsFixed(1),
                      color: metrics.tsb > 0 ? Colors.green : Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: _buildMetricItem(
                      context,
                      label: 'Risk Zone',
                      value: zone.name.toUpperCase(),
                      color: zoneColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}