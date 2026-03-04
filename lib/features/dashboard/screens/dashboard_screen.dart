// lib/features/dashboard/presentation/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../../core/models/training_metrics.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/dashboard_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // En producción esto vendría del BLoC / Riverpod provider
    final metrics = TrainingMetrics.mock();
    final chartData = ChartPoint.mockHistory();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: _DashboardHeader(metrics: metrics),
              ),
            ),

            // ── Body ─────────────────────────────────────
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
                    onLogSession: () => Navigator.pushNamed(context, '/session/log'),
                    onViewPlan: () => Navigator.pushNamed(context, '/plan'),
                  ),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final TrainingMetrics metrics;

  const _DashboardHeader({required this.metrics});

  @override
  Widget build(BuildContext context) {
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
            const Text(
              'Cristina',
              style: TextStyle(
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
          child: const Center(
            child: Text(
              'C',
              style: TextStyle(
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
