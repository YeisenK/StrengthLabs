import 'package:flutter_test/flutter_test.dart';
import 'package:strengthlabs/features/fatigue/data/fatigue_response_parser.dart';
import 'package:strengthlabs/features/workouts/domain/entities/exercise.dart';

void main() {
  group('parseFatigueSummary', () {
    Map<String, dynamic> baseShape() => {
          'overall_index': 65.0,
          'is_overtraining': false,
          'weekly_volume': {'chest': 100.0, 'biceps': 50.0, 'glutes': 80.0},
          'trend': [
            {'date': '2026-05-10T00:00:00Z', 'index': 40.0},
            {'date': '2026-05-11T00:00:00Z', 'index': 42.0},
          ],
          'atl': 50.0,
          'ctl': 40.0,
          'tsb': -10.0,
          'acwr': 1.2,
          'monotony': 1.4,
          'strain': 220.0,
          'ramp_rate': 1.5,
          'readiness_score': 65.0,
          'injury_risk_score': 0.3,
          'overtraining_risk_score': 0.2,
          'composite_risk_score': 0.25,
          'risk_level': 'moderate',
          'dominant_factor': 'acwr',
          'recommendations': ['rec.deload', 'Take a deload week'],
        };

    test('parses risk_flags as List<String> (current backend wire format)', () {
      final shape = baseShape()
        ..['risk_flags'] = ['ACWR too high', 'Monotony elevated'];
      final summary = parseFatigueSummary(shape);
      expect(summary.riskFlags, ['ACWR too high', 'Monotony elevated']);
    });

    test('parses risk_flags defensively when backend sends List<Map>', () {
      final shape = baseShape()
        ..['risk_flags'] = [
          {'code': 'HIGH_ACWR', 'text': 'ACWR too high'},
          {'code': 'MONOTONY', 'text': 'Monotony elevated'},
        ];
      final summary = parseFatigueSummary(shape);
      // We must NOT crash and we should extract human-readable text.
      expect(summary.riskFlags.length, 2);
      expect(summary.riskFlags.first.contains('ACWR'), true);
    });

    test('parses risk_flags with mixed shapes without crashing', () {
      final shape = baseShape()
        ..['risk_flags'] = [
          'Plain warning',
          {'code': 'HIGH_ACWR', 'text': 'Structured warning'},
          {'code': 'UNKNOWN'}, // no text → use code
          null, // total junk → skipped
        ];
      final summary = parseFatigueSummary(shape);
      expect(summary.riskFlags.length, 3);
    });

    test('treats missing risk_flags as empty list', () {
      final shape = baseShape();
      final summary = parseFatigueSummary(shape);
      expect(summary.riskFlags, isEmpty);
    });

    test('accumulates weekly_volume across the 12 backend groups', () {
      final shape = baseShape();
      final summary = parseFatigueSummary(shape);
      expect(summary.weeklyVolume[MuscleGroup.chest], 100.0);
      expect(summary.weeklyVolume[MuscleGroup.biceps], 50.0);
      expect(summary.weeklyVolume[MuscleGroup.glutes], 80.0);
      // unspecified groups initialize to 0.
      expect(summary.weeklyVolume[MuscleGroup.calves], 0.0);
    });

    test('does not crash on unknown muscle group in weekly_volume', () {
      final shape = baseShape()
        ..['weekly_volume'] = {'aliens': 999.0, 'chest': 100.0};
      final summary = parseFatigueSummary(shape);
      expect(summary.weeklyVolume[MuscleGroup.chest], 100.0);
      expect(summary.weeklyVolume[MuscleGroup.other], 999.0);
    });

    test('handles missing optional numeric fields as zero', () {
      final shape = <String, dynamic>{};
      final summary = parseFatigueSummary(shape);
      expect(summary.overallIndex, 0.0);
      expect(summary.atl, 0.0);
      expect(summary.riskFlags, isEmpty);
      expect(summary.recommendations, isEmpty);
      expect(summary.riskLevel, 'low');
    });
  });
}
