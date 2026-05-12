import 'package:strengthlabs/core/demo/demo_mode.dart';
import 'package:strengthlabs/core/network/dio_client.dart';
import 'package:strengthlabs/features/fatigue/data/fatigue_response_parser.dart';
import 'package:strengthlabs/features/fatigue/domain/entities/fatigue_summary.dart';

class FatigueRepository {
  FatigueRepository(this._dioClient);

  final DioClient _dioClient;

  Future<FatigueSummary> getSummary() async {
    if (DemoMode.isActive) return DemoMode.fatigueSummary();
    final response = await _dioClient.dio.get('/fatigue/summary');
    final data = response.data as Map<String, dynamic>;
    return parseFatigueSummary(data);
  }
}
