import 'package:asip_fitness_analytics/features/plan/provider/plan_provider.dart';
import 'package:asip_fitness_analytics/features/plan/widgets/recommendation_card.dart';
import 'package:asip_fitness_analytics/features/plan/widgets/weekly_plan_list.dart';
import 'package:asip_fitness_analytics/shared/widgets/loading_indicator.dart';
import 'package:asip_fitness_analytics/shared/widgets/error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdaptivePlanScreen extends ConsumerStatefulWidget {
  const AdaptivePlanScreen({super.key});

  @override
  ConsumerState<AdaptivePlanScreen> createState() => _AdaptivePlanScreenState();
}

class _AdaptivePlanScreenState extends ConsumerState<AdaptivePlanScreen> {
  Future<void> _refreshData() async {
    ref.invalidate(weeklyPlanProvider);
    ref.invalidate(planRecommendationProvider);
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(weeklyPlanProvider);
    final recommendationAsync = ref.watch(planRecommendationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adaptive Plan'),
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            recommendationAsync.when(
              data: (recommendation) => RecommendationCard(recommendation: recommendation),
              loading: () => const SizedBox(height: 100),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(height: 16),
            planAsync.when(
              data: (workouts) => WeeklyPlanList(workouts: workouts),
              loading: () => const LoadingIndicator(message: 'Loading weekly plan...'),
              error: (error, stack) => ErrorView(
                error: error.toString(),
                onRetry: _refreshData,
              ),
            ),
          ],
        ),
      ),
    );
  }
}