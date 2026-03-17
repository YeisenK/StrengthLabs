import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/training_metrics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../providers/metrics_provider.dart';
import '../widgets/dashboard_widgets.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(metricsProvider);
    final chartAsync = ref.watch(chartHistoryProvider);
    final authState = ref.watch(authProvider);
    final userName = authState is AuthAuthenticated
        ? authState.user.firstName
        : '';

    return metricsAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.accent,
            strokeWidth: 2,
          ),
        ),
      ),
      error: (e, _) => const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: Text(
            'Error al cargar métricas',
            style: TextStyle(
              fontFamily: 'ShareTechMono',
              fontSize: 11,
              color: AppColors.riskRed,
            ),
          ),
        ),
      ),
      data: (metrics) {
        final chartData = chartAsync.valueOrNull ?? [];

        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: _DashboardHeader(
                      metrics: metrics,
                      userName: userName,
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 20),

                      // 1. TSB Hero
                      TSBHeroCard(metrics: metrics),
                      const SizedBox(height: 12),

                      // 2. ATL / CTL
                      MetricsRow(metrics: metrics),
                      const SizedBox(height: 12),

                      // 3. ACWR
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface2,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ACWRBar(acwr: metrics.acwr),
                      ),
                      const SizedBox(height: 12),

                      // 4. ATL/CTL chart
                      ATLCTLMiniChart(data: chartData),
                      const SizedBox(height: 12),

                      // 5. Quick Actions
                      QuickActionsRow(
                        onLogSession: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Scaffold(
                              appBar: AppBar(title: const Text('REGISTRAR SESIÓN')),
                              body: const Center(child: Text('PRÓXIMAMENTE')),
                            ),
                          ),
                        ),
                        onViewPlan: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Scaffold(
                              appBar: AppBar(title: const Text('PLAN')),
                              body: const Center(child: Text('PRÓXIMAMENTE')),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final TrainingMetrics metrics;
  final String userName;

  const _DashboardHeader({required this.metrics, required this.userName});

  @override
  Widget build(BuildContext context) {
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BUENOS DÍAS',
              style: TextStyle(
                fontFamily: 'ShareTechMono',
                fontSize: 9,
                letterSpacing: 3,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              userName.isNotEmpty ? userName : 'Atleta',
              style: const TextStyle(
                fontFamily: 'BarlowCondensed',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1,
              ),
            ),
          ],
        ),
        const Spacer(),
        // Notification bell
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        // Avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.accent, AppColors.accent2],
            ),
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                fontFamily: 'BarlowCondensed',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.bg,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
