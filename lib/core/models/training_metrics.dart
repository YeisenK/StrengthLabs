// lib/core/models/training_metrics.dart

class TrainingMetrics {
  final double atl;  // Acute Training Load (7-day)
  final double ctl;  // Chronic Training Load (28-day)
  final double tsb;  // Training Stress Balance
  final double acwr; // Acute:Chronic Workload Ratio
  final RiskLevel riskLevel;
  final DateTime updatedAt;

  const TrainingMetrics({
    required this.atl,
    required this.ctl,
    required this.tsb,
    required this.acwr,
    required this.riskLevel,
    required this.updatedAt,
  });

  // Mock data para desarrollo
  factory TrainingMetrics.mock() => TrainingMetrics(
        atl: 64,
        ctl: 52,
        tsb: 12,
        acwr: 1.23,
        riskLevel: RiskLevel.green,
        updatedAt: DateTime.now(),
      );

  String get tsbLabel {
    if (tsb >= 10) return 'Estado Óptimo · Listo para entrenar';
    if (tsb >= 0) return 'Equilibrado · Carga moderada';
    if (tsb >= -10) return 'Fatigado · Considera reducir carga';
    return 'Muy fatigado · Descansa';
  }

  String get acwrLabel {
    if (acwr < 0.8) return 'BAJO';
    if (acwr <= 1.3) return 'ÓPTIMO';
    if (acwr <= 1.5) return 'ELEVADO';
    return 'ALTO RIESGO';
  }
}

enum RiskLevel {
  green('VERDE · BAJO RIESGO'),
  yellow('AMARILLO · RIESGO MODERADO'),
  red('ROJO · RIESGO ALTO');

  final String label;
  const RiskLevel(this.label);
}

class ChartPoint {
  final DateTime date;
  final double atl;
  final double ctl;

  const ChartPoint({
    required this.date,
    required this.atl,
    required this.ctl,
  });

  // 4 weeks of mock history
  static List<ChartPoint> mockHistory() {
    final now = DateTime.now();
    return List.generate(28, (i) {
      final day = now.subtract(Duration(days: 27 - i));
      final t = i / 27.0;
      return ChartPoint(
        date: day,
        atl: 40 + 30 * (0.5 + 0.5 * _wave(t, 7)),
        ctl: 38 + 20 * t,
      );
    });
  }

  static double _wave(double t, double freq) =>
      0.5 * (1 + (t * freq * 3.14159).remainder(3.14159).abs() / 3.14159);
}
