import 'package:flutter/material.dart';
import '../../../core/models/training_metrics.dart';
import '../../../core/theme/app_theme.dart';

class SessionDetailScreen extends StatelessWidget {
  final RecentSession session;

  const SessionDetailScreen({
    super.key,
    required this.session,
  });

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text(
          'DETALLE DE SESIÓN',
          style: TextStyle(
            fontFamily: 'BarlowCondensed',
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.textPrimary,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SESIÓN',
                    style: TextStyle(
                      fontFamily: 'ShareTechMono',
                      fontSize: 9,
                      letterSpacing: 2,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    session.title,
                    style: const TextStyle(
                      fontFamily: 'BarlowCondensed',
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _formatDate(session.date),
                    style: const TextStyle(
                      fontFamily: 'ShareTechMono',
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SessionMetricCard(
                    label: 'DURACIÓN',
                    value: '${session.durationMinutes}',
                    suffix: 'min',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SessionMetricCard(
                    label: 'RPE',
                    value: session.rpe.toStringAsFixed(1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SessionMetricCard(
              label: 'CARGA',
              value: session.load.toStringAsFixed(0),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? suffix;

  const _SessionMetricCard({
    required this.label,
    required this.value,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'ShareTechMono',
              fontSize: 9,
              letterSpacing: 2,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontFamily: 'BarlowCondensed',
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1,
                  ),
                ),
                if (suffix != null)
                  TextSpan(
                    text: ' $suffix',
                    style: const TextStyle(
                      fontFamily: 'ShareTechMono',
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}