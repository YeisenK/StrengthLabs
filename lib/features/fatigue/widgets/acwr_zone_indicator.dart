import 'package:asip_fitness_analytics/shared/utils/risk_zone_util.dart';
import 'package:flutter/material.dart';

class AcwrZoneIndicator extends StatelessWidget {
  final double acwr;

  const AcwrZoneIndicator({super.key, required this.acwr});

  @override
  Widget build(BuildContext context) {
    final zone = RiskZoneUtil.getRiskZone(acwr);
    final zoneColor = RiskZoneUtil.getZoneColor(zone);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Current ACWR:'),
            Text(
              acwr.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4CAF50),
                    Color(0xFF4CAF50),
                    Color(0xFFFFC107),
                    Color(0xFFF44336),
                  ],
                  stops: [0.0, 0.53, 0.63, 1.0],
                ),
              ),
            ),
            Positioned(
              left: (acwr / 2.0) * MediaQuery.of(context).size.width * 0.7,
              child: Container(
                width: 4,
                height: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildZoneLabel('Optimal', Colors.green),
            _buildZoneLabel('Moderate', Colors.orange),
            _buildZoneLabel('High', Colors.red),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: zoneColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: zoneColor),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: zoneColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  RiskZoneUtil.getZoneDescription(zone),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildZoneLabel(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}