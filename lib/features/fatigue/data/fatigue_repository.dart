import 'package:strengthlabs_beta/core/constants/api_constants.dart';
import 'package:strengthlabs_beta/core/network/dio_client.dart';
import 'package:strengthlabs_beta/features/fatigue/domain/entities/fatigue_summary.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/exercise.dart';

class FatigueRepository {
  const FatigueRepository(this._client);

  final DioClient _client;

  Future<FatigueSummary> getSummary() async {
    final resp = await _client.dio.get(ApiConstants.fatigueSummary);
    final d = resp.data as Map<String, dynamic>;

    final weeklyVolume = (d['weekly_volume'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        MuscleGroup.values.byName(key),
        (value as num).toDouble(),
      ),
    );

    final trend = (d['trend'] as List).map((point) {
      final p = point as Map<String, dynamic>;
      return FatigueDataPoint(
        date: DateTime.parse(p['date'] as String),
        index: (p['index'] as num).toDouble(),
      );
    }).toList();

    return FatigueSummary(
      overallIndex: (d['overall_index'] as num).toDouble(),
      isOvertraining: d['is_overtraining'] as bool,
      weeklyVolume: weeklyVolume,
      trend: trend,
    );
  }
}
