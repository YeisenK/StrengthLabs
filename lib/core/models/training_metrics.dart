enum RiskLevel {
  green,
  yellow,
  red;

  String get label {
    switch (this) {
      case RiskLevel.green:
        return 'OPTIMAL';
      case RiskLevel.yellow:
        return 'CAUTION';
      case RiskLevel.red:
        return 'HIGH';
    }
  }
}

class TrainingMetrics {
  final double atl;
  final double ctl;
  final double acwr;
  final double tsb;
  final String riskZone;
  final List<RecentSession> recentSessions;
  final List<ChartPoint> history;

  const TrainingMetrics({
    required this.atl,
    required this.ctl,
    required this.acwr,
    required this.tsb,
    required this.riskZone,
    required this.recentSessions,
    required this.history,
  });

  factory TrainingMetrics.fromJson(Map<String, dynamic> json) {
    return TrainingMetrics(
      atl: (json['atl'] ?? 0).toDouble(),
      ctl: (json['ctl'] ?? 0).toDouble(),
      acwr: (json['acwr'] ?? 0).toDouble(),
      tsb: (json['tsb'] ?? 0).toDouble(),
      riskZone: (json['riskZone'] ?? 'LOW').toString(),
      recentSessions: (json['recentSessions'] as List<dynamic>? ?? [])
          .map((e) => RecentSession.fromJson(e as Map<String, dynamic>))
          .toList(),
      history: (json['history'] as List<dynamic>? ?? [])
          .map((e) => ChartPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  RiskLevel get riskLevel {
    final zone = riskZone.toUpperCase();

    switch (zone) {
      case 'LOW':
        return RiskLevel.yellow;
      case 'OPTIMAL':
        return RiskLevel.green;
      case 'CAUTION':
        return RiskLevel.yellow;
      case 'HIGH':
        return RiskLevel.red;
      default:
        if (acwr > 1.5) return RiskLevel.red;
        if (acwr >= 0.8 && acwr <= 1.3) return RiskLevel.green;
        return RiskLevel.yellow;
    }
  }

  String get tsbLabel {
    if (tsb >= 10) return 'FRESH';
    if (tsb >= 0) return 'READY';
    if (tsb >= -10) return 'NORMAL FATIGUE';
    return 'HIGH FATIGUE';
  }
}

class RecentSession {
  final String id;
  final String title;
  final DateTime date;
  final int durationMinutes;
  final double rpe;
  final double load;

  const RecentSession({
    required this.id,
    required this.title,
    required this.date,
    required this.durationMinutes,
    required this.rpe,
    required this.load,
  });

  factory RecentSession.fromJson(Map<String, dynamic> json) {
    return RecentSession(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? 'Sesión').toString(),
      date: DateTime.tryParse(
            (json['date'] ?? json['performedAt'] ?? '').toString(),
          ) ??
          DateTime.now(),
      durationMinutes:
          ((json['durationMinutes'] ?? json['duration'] ?? 0) as num).toInt(),
      rpe: (json['rpe'] ?? json['sessionRpe'] ?? 0).toDouble(),
      load: (json['load'] ?? json['trainingLoad'] ?? 0).toDouble(),
    );
  }
}

class ChartPoint {
  final DateTime date;
  final double atl;
  final double ctl;
  final double acwr;
  final double tsb;

  const ChartPoint({
    required this.date,
    required this.atl,
    required this.ctl,
    required this.acwr,
    required this.tsb,
  });

  factory ChartPoint.fromJson(Map<String, dynamic> json) {
    return ChartPoint(
      date: DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
      atl: (json['atl'] ?? 0).toDouble(),
      ctl: (json['ctl'] ?? 0).toDouble(),
      acwr: (json['acwr'] ?? 0).toDouble(),
      tsb: (json['tsb'] ?? 0).toDouble(),
    );
  }
}