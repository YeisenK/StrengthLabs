import 'package:strengthlabs_beta/features/fatigue/domain/entities/fatigue_metrics.dart';
import 'package:strengthlabs_beta/features/plan/domain/entities/training_plan.dart';

class PlanBuilder {
  const PlanBuilder();

  Future<TrainingPlan> getPlan({
    required ComputeMetrics metrics,
    int? daysToEvent,
    int weeksInPhase = 0,
  }) async {
    return TrainingPlan.fromJson(_buildPlan(metrics, daysToEvent));
  }

  Map<String, dynamic> _buildPlan(ComputeMetrics metrics, int? daysToEvent) {
    final String phase;
    final String microcycleType;
    final String weekObjective;
    final String rationale;
    double loadAdjPct;

    if (metrics.tsb < -15 || metrics.acwr > 1.4) {
      phase = 'recovery';
      microcycleType = 'deload';
      weekObjective =
          'Reduce accumulated fatigue and restore readiness through controlled low-intensity work.';
      rationale =
          'High acute:chronic workload ratio or large TSB deficit signals accumulated fatigue. '
          'A deload week at 60–70% of normal volume promotes supercompensation.';
      loadAdjPct = -30.0;
    } else if (daysToEvent != null && daysToEvent <= 10) {
      phase = 'realization';
      microcycleType = 'peak';
      weekObjective =
          'Sharpen fitness for your upcoming event. Reduce volume while maintaining key intensities.';
      rationale =
          'Tapering before the event. Volume is cut by 40–50% while high-intensity efforts '
          'are preserved to maintain fitness gains.';
      loadAdjPct = -40.0;
    } else if (metrics.ctl < 30) {
      phase = 'accumulation';
      microcycleType = 'base_building';
      weekObjective =
          'Build aerobic base and muscular endurance with progressive moderate-intensity training.';
      rationale =
          'Low chronic training load indicates an early training phase. Base building with '
          'progressive overload will safely raise fitness.';
      loadAdjPct = 10.0;
    } else if (metrics.acwr < 0.8) {
      phase = 'accumulation';
      microcycleType = 'progression';
      weekObjective =
          'Increase training load progressively to close the gap between acute and chronic fitness.';
      rationale =
          'Low ACWR suggests undertraining relative to chronic capacity. A safe 10–15% '
          'load increase will restore an optimal workload ratio.';
      loadAdjPct = 12.0;
    } else {
      phase = 'transmutation';
      microcycleType = 'intensification';
      weekObjective =
          'Convert accumulated base fitness into sport-specific strength and power.';
      rationale =
          'Good training load balance with adequate CTL. Shifting to higher-intensity, '
          'lower-volume work to maximise performance gains.';
      loadAdjPct = 5.0;
    }

    final baseLoad = metrics.ctl > 0 ? metrics.ctl * 7 : 300.0;
    final targetWeeklyLoad = baseLoad * (1 + loadAdjPct / 100);
    final targetAcwr = phase == 'recovery'
        ? 0.80
        : phase == 'realization'
            ? 0.85
            : 1.0;
    final projectedTsbDelta =
        phase == 'recovery' ? 8.0 : phase == 'realization' ? 6.0 : -3.0;

    return {
      'phase': phase,
      'microcycle_type': microcycleType,
      'week_objective': weekObjective,
      'target_weekly_load': targetWeeklyLoad,
      'target_acwr': targetAcwr,
      'projected_tsb_delta': projectedTsbDelta,
      'load_adjustment_pct': loadAdjPct,
      'sessions': _buildSessions(phase),
      'coach_notes': _buildCoachNotes(phase, metrics),
      'periodization_rationale': rationale,
    };
  }

  List<Map<String, dynamic>> _buildSessions(String phase) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    switch (phase) {
      case 'recovery':
        return [
          _s(1, days[0], 'Active Recovery', 'z1_recovery', 30, 5.0,
              'Easy movement to promote recovery', false, false),
          _s(2, days[1], 'Rest', 'z1_recovery', 0, 0.0, 'Full rest day', true, false),
          _s(3, days[2], 'Mobility & Light Strength', 'z2_aerobic', 40, 5.0,
              'Light resistance work with focus on form', false, false),
          _s(4, days[3], 'Rest', 'z1_recovery', 0, 0.0, 'Full rest day', true, false),
          _s(5, days[4], 'Easy Cardio', 'z2_aerobic', 35, 5.5,
              'Steady-state aerobic work', false, false),
          _s(6, days[5], 'Rest', 'z1_recovery', 0, 0.0, 'Full rest day', true, false),
          _s(7, days[6], 'Rest', 'z1_recovery', 0, 0.0, 'Full rest day', true, false),
        ];
      case 'realization':
        return [
          _s(1, days[0], 'Activation', 'z2_aerobic', 40, 6.0,
              'Easy session to stay sharp', false, false),
          _s(2, days[1], 'Short Intensity', 'z4_threshold', 30, 8.0,
              'Brief high-intensity to maintain peak', false, true),
          _s(3, days[2], 'Rest', 'z1_recovery', 0, 0.0, 'Full rest day', true, false),
          _s(4, days[3], 'Easy Movement', 'z1_recovery', 25, 5.0,
              'Keep moving, stay loose', false, false),
          _s(5, days[4], 'Rest', 'z1_recovery', 0, 0.0, 'Full rest day', true, false),
          _s(6, days[5], 'Pre-event Prep', 'z2_aerobic', 20, 5.0,
              'Very easy session the day before', false, false),
          _s(7, days[6], 'Event Day', 'z5_neuromuscular', 0, 10.0,
              'Competition / target event', false, true),
        ];
      case 'transmutation':
        return [
          _s(1, days[0], 'Heavy Strength', 'z4_threshold', 60, 8.5,
              'Compound lifts at 85–90% 1RM', false, true),
          _s(2, days[1], 'Tempo Work', 'z3_tempo', 50, 7.0,
              'Moderate intensity metabolic conditioning', false, false),
          _s(3, days[2], 'Rest / Mobility', 'z1_recovery', 20, 4.0,
              'Active recovery and mobility', false, false),
          _s(4, days[3], 'Power Development', 'z5_neuromuscular', 55, 8.0,
              'Explosive movements and velocity work', false, true),
          _s(5, days[4], 'Accessory Work', 'z3_tempo', 45, 7.0,
              'Targeted accessory exercises', false, false),
          _s(6, days[5], 'Long Aerobic', 'z2_aerobic', 60, 6.0,
              'Steady-state aerobic development', false, false),
          _s(7, days[6], 'Rest', 'z1_recovery', 0, 0.0, 'Full rest day', true, false),
        ];
      default: // accumulation
        return [
          _s(1, days[0], 'Strength Training A', 'z3_tempo', 60, 7.0,
              'Full-body compound movements, 3×8–12', false, true),
          _s(2, days[1], 'Aerobic Base', 'z2_aerobic', 40, 6.0,
              'Steady-state cardio at conversational pace', false, false),
          _s(3, days[2], 'Strength Training B', 'z3_tempo', 60, 7.5,
              'Lower-body focus with accessory work', false, true),
          _s(4, days[3], 'Rest / Active Recovery', 'z1_recovery', 20, 4.0,
              'Light movement and stretching', false, false),
          _s(5, days[4], 'Strength Training C', 'z3_tempo', 55, 7.0,
              'Upper-body focus and core', false, false),
          _s(6, days[5], 'Long Steady State', 'z2_aerobic', 60, 5.5,
              'Longer aerobic session for base building', false, false),
          _s(7, days[6], 'Rest', 'z1_recovery', 0, 0.0, 'Full rest day', true, false),
        ];
    }
  }

  Map<String, dynamic> _s(
    int day,
    String dayName,
    String sessionType,
    String intensityZone,
    int durationMinutes,
    double rpeTarget,
    String description,
    bool isRest,
    bool keySession,
  ) =>
      {
        'day': day,
        'day_name': dayName,
        'session_type': sessionType,
        'intensity_zone': intensityZone,
        'duration_minutes': durationMinutes,
        'rpe_target': rpeTarget,
        'description': description,
        'is_rest': isRest,
        'key_session': keySession,
      };

  List<String> _buildCoachNotes(String phase, ComputeMetrics metrics) {
    final notes = <String>[];
    switch (phase) {
      case 'recovery':
        notes.addAll([
          'Keep all sessions below RPE 6. If you feel good, resist the urge to push harder.',
          'Prioritise sleep (8+ hours) and nutrition — this week is where adaptation happens.',
          'Treat the deload as important as any hard training week.',
        ]);
      case 'realization':
        notes.addAll([
          'Do not introduce new exercises — stick to familiar movements only.',
          'Sleep and nutrition are critical: aim for 8–9 hours and high protein intake.',
          'Trust your training — the fitness is there, now let it express itself.',
        ]);
      case 'transmutation':
        notes.addAll([
          'Quality over quantity — each rep should be intentional and technically sound.',
          'Rest 3–5 minutes between heavy sets for full neural recovery.',
          'Track your key lifts and aim for small PRs or near-maximal efforts.',
        ]);
      default:
        notes.addAll([
          'Log every session and aim for 2–3% weight progression each week on main lifts.',
          'Hit 1.6–2.2 g of protein per kg of body weight daily to support adaptation.',
          'Consistency is key at this phase — showing up beats any single perfect session.',
        ]);
    }
    if (metrics.acwr > 1.2) {
      notes.add('Recent load has been elevated — watch for signs of overreaching.');
    }
    if (metrics.readinessScore > 75) {
      notes.add('Readiness is high — good week to chase performance breakthroughs.');
    }
    return notes;
  }
}
