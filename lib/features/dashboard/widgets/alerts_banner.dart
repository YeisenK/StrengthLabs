import 'package:asip_fitness_analytics/shared/models/alert.dart';
import 'package:flutter/material.dart';

class AlertsBanner extends StatelessWidget {
  final List<Alert> alerts;

  const AlertsBanner({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        color: _getSeverityColor(alerts.first.severity),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getSeverityColor(alerts.first.severity),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              _getSeverityIcon(alerts.first.severity),
              color: _getSeverityColor(alerts.first.severity),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                alerts.first.message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.info:
        return Colors.blue;
      case AlertSeverity.warning:
        return Colors.orange;
      case AlertSeverity.critical:
        return Colors.red;
    }
  }

  IconData _getSeverityIcon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.info:
        return Icons.info_outline;
      case AlertSeverity.warning:
        return Icons.warning_amber_outlined;
      case AlertSeverity.critical:
        return Icons.error_outline;
    }
  }
}