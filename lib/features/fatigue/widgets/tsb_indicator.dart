import 'package:flutter/material.dart';

class TsbIndicator extends StatelessWidget {
  final double tsb;

  const TsbIndicator({super.key, required this.tsb});

  @override
  Widget build(BuildContext context) {
    String interpretation;
    Color color;

    if (tsb > 10) {
      interpretation = 'Fresh - Well recovered';
      color = Colors.green;
    } else if (tsb > 0) {
      interpretation = 'Nominal - Balanced';
      color = Colors.blue;
    } else if (tsb > -10) {
      interpretation = 'Fatigued - Accumulated fatigue';
      color = Colors.orange;
    } else {
      interpretation = 'Overtrained - High fatigue';
      color = Colors.red;
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Training Stress Balance (TSB):'),
            Text(
              tsb.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            interpretation,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'TSB = CTL - ATL. Positive values indicate freshness, negative values indicate fatigue.',
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}