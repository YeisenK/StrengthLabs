enum RiskLevel {
  green,
  yellow,
  red;

  String get label {
    switch (this) {
      case RiskLevel.green:
        return 'ÓPTIMO';
      case RiskLevel.yellow:
        return 'PRECAUCIÓN';
      case RiskLevel.red:
        return 'ALTO';
    }
  }
}

class TrainingMetrics {
  final double atl;
  final double ctl;
  final double acwr;
  final double tsb;
  final String riskZone;
  final String? tsbStatus;
  final List<RecentSession> recentSessions;
  final List<ChartPoint> history;

  const TrainingMetrics({
    required this.atl,
    required this.ctl,
    required this.acwr,
    required this.tsb,
    required this.riskZone,
    required this.tsbStatus,
    required this.recentSessions,
    required this.history,
  });

  factory TrainingMetrics.fromJson(Map json) {
    return TrainingMetrics(
      atl: (json['atl'] ?? 0).toDouble(),
      ctl: (json['ctl'] ?? 0).toDouble(),
      acwr: (json['acwr'] ?? 0).toDouble(),
      tsb: (json['tsb'] ?? 0).toDouble(),
      riskZone: (json['riskZone'] ?? '').toString(),
      tsbStatus: json['tsbStatus']?.toString(),
      recentSessions: (json['recentSessions'] as List? ?? [])
          .map((e) => RecentSession.fromJson(e as Map))
          .toList(),
      history: (json['history'] as List? ?? [])
          .map((e) => ChartPoint.fromJson(e as Map))
          .toList(),
    );
  }

  RiskLevel get riskLevel {
    switch (riskZone.trim().toUpperCase()) {
      case 'OPTIMAL':
      case 'ÓPTIMO':
        return RiskLevel.green;
      case 'CAUTION':
      case 'LOW':
      case 'PRECAUCIÓN':
      case 'BAJO':
        return RiskLevel.yellow;
      case 'HIGH':
      case 'ALTO':
        return RiskLevel.red;
      default:
        return RiskLevel.yellow;
    }
  }

  String get tsbLabel {
    final backendLabel = tsbStatus?.trim();
    if (backendLabel != null && backendLabel.isNotEmpty) {
      return backendLabel.toUpperCase();
    }
    return 'ESTADO NO DISPONIBLE';
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

  factory RecentSession.fromJson(Map json) {
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

  factory ChartPoint.fromJson(Map json) {
    return ChartPoint(
      date: DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
      atl: (json['atl'] ?? 0).toDouble(),
      ctl: (json['ctl'] ?? 0).toDouble(),
      acwr: (json['acwr'] ?? 0).toDouble(),
      tsb: (json['tsb'] ?? 0).toDouble(),
    );
  }
}