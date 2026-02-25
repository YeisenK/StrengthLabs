import 'package:asip_fitness_analytics/shared/models/alert.dart';

enum RiskZone { green, yellow, red }

class RiskZoneUtil {
  static const double minOptimalAcwr = 0.8;
  static const double maxOptimalAcwr = 1.3;
  static const double maxModerateAcwr = 1.5;

  static RiskZone getRiskZone(double acwr) {
    if (acwr >= minOptimalAcwr && acwr <= maxOptimalAcwr) {
      return RiskZone.green;
    } else if (acwr > maxOptimalAcwr && acwr <= maxModerateAcwr) {
      return RiskZone.yellow;
    } else {
      return RiskZone.red;
    }
  }

  static Color getZoneColor(RiskZone zone) {
    switch (zone) {
      case RiskZone.green:
        return const Color(0xFF4CAF50);
      case RiskZone.yellow:
        return const Color(0xFFFFC107);
      case RiskZone.red:
        return const Color(0xFFF44336);
    }
  }

  static String getZoneDescription(RiskZone zone) {
    switch (zone) {
      case RiskZone.green:
        return 'Optimal load - low injury risk';
      case RiskZone.yellow:
        return 'Moderate load - increased injury risk';
      case RiskZone.red:
        return 'High load - critical injury risk';
    }
  }

  static Alert? generateAlert(double acwr) {
    final zone = getRiskZone(acwr);
    if (zone == RiskZone.red) {
      return Alert(
        id: DateTime.now().toString(),
        message: 'Critical injury risk detected. Consider reducing training load.',
        severity: AlertSeverity.critical,
        timestamp: DateTime.now(),
      );
    } else if (zone == RiskZone.yellow) {
      return Alert(
        id: DateTime.now().toString(),
        message: 'Moderate injury risk. Monitor fatigue levels.',
        severity: AlertSeverity.warning,
        timestamp: DateTime.now(),
      );
    }
    return null;
  }
}