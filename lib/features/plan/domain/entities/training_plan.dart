import 'package:equatable/equatable.dart';

class PlanSession extends Equatable {
  const PlanSession({
    required this.day,
    required this.dayName,
    required this.sessionType,
    required this.intensityZone,
    required this.durationMinutes,
    required this.rpeTarget,
    required this.description,
    required this.isRest,
    required this.keySession,
  });

  final int day;
  final String dayName;
  final String sessionType;
  final String intensityZone;
  final int durationMinutes;
  final double rpeTarget;
  final String description;
  final bool isRest;
  final bool keySession;

  factory PlanSession.fromJson(Map<String, dynamic> j) => PlanSession(
        day: j['day'] as int,
        dayName: j['day_name'] as String,
        sessionType: j['session_type'] as String,
        intensityZone: j['intensity_zone'] as String,
        durationMinutes: j['duration_minutes'] as int,
        rpeTarget: (j['rpe_target'] as num).toDouble(),
        description: j['description'] as String,
        isRest: j['is_rest'] as bool,
        keySession: j['key_session'] as bool,
      );

  @override
  List<Object?> get props => [
        day, dayName, sessionType, intensityZone,
        durationMinutes, rpeTarget, isRest, keySession,
      ];
}

class TrainingPlan extends Equatable {
  const TrainingPlan({
    required this.phase,
    required this.microcycleType,
    required this.weekObjective,
    required this.targetWeeklyLoad,
    required this.targetAcwr,
    required this.projectedTsbDelta,
    required this.loadAdjustmentPct,
    required this.sessions,
    required this.coachNotes,
    required this.periodizationRationale,
  });

  final String phase;
  final String microcycleType;
  final String weekObjective;
  final double targetWeeklyLoad;
  final double targetAcwr;
  final double projectedTsbDelta;
  final double loadAdjustmentPct;
  final List<PlanSession> sessions;
  final List<String> coachNotes;
  final String periodizationRationale;

  factory TrainingPlan.fromJson(Map<String, dynamic> j) => TrainingPlan(
        phase: j['phase'] as String,
        microcycleType: j['microcycle_type'] as String,
        weekObjective: j['week_objective'] as String,
        targetWeeklyLoad: (j['target_weekly_load'] as num).toDouble(),
        targetAcwr: (j['target_acwr'] as num).toDouble(),
        projectedTsbDelta: (j['projected_tsb_delta'] as num).toDouble(),
        loadAdjustmentPct: (j['load_adjustment_pct'] as num).toDouble(),
        sessions: (j['sessions'] as List)
            .map((s) => PlanSession.fromJson(s as Map<String, dynamic>))
            .toList(),
        coachNotes: (j['coach_notes'] as List).cast<String>(),
        periodizationRationale: j['periodization_rationale'] as String,
      );

  @override
  List<Object?> get props => [phase, microcycleType, weekObjective, sessions];
}
