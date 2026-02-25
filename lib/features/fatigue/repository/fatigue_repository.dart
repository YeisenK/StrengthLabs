import 'package:asip_fitness_analytics/shared/models/fatigue_metrics.dart';

class FatigueRepository {
  Future<FatigueMetrics> getFatigueMetrics() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    
    return FatigueMetrics(
      atl: 85.5,
      ctl: 72.3,
      tsb: 13.2,
      acwr: 1.18,
      atlHistory: [65.2, 70.1, 75.3, 78.4, 82.1, 84.6, 85.5, 86.2, 87.1, 88.0],
      ctlHistory: [68.1, 68.9, 69.8, 70.5, 71.2, 71.8, 72.3, 72.9, 73.4, 74.0],
      dates: List.generate(10, (i) => DateTime.now().subtract(Duration(days: 9 - i))),
    );
  }
}