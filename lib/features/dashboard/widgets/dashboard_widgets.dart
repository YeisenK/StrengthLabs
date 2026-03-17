// lib/features/dashboard/presentation/widgets/dashboard_widgets.dart
import 'package:flutter/material.dart';
import '../../../core/models/training_metrics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/sl_card.dart';

class TSBHeroCard extends StatelessWidget {
  final TrainingMetrics metrics;

  const TSBHeroCard({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final (borderColor, accentColor, tagVariant) = switch (metrics.riskLevel) {
      RiskLevel.green => (
          AppColors.riskGreen.withOpacity(0.25),
          AppColors.riskGreen,
          TagVariant.green
        ),
      RiskLevel.yellow => (
          AppColors.accent4.withOpacity(0.25),
          AppColors.accent4,
          TagVariant.yellow
        ),
      RiskLevel.red => (
          AppColors.riskRed.withOpacity(0.25),
          AppColors.riskRed,
          TagVariant.red
        ),
    };

    return SLCard(
      borderColor: borderColor,
      backgroundColor: accentColor.withOpacity(0.06),
      child: Stack(
        children: [
          // Watermark
          Positioned(
            right: -8,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(
                'TSB',
                style: TextStyle(
                  fontFamily: 'BarlowCondensed',
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  color: accentColor.withOpacity(0.04),
                  letterSpacing: -4,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SLSectionLabel('TRAINING STRESS BALANCE'),
              const SizedBox(height: 6),
              Text(
                metrics.tsb >= 0
                    ? '+${metrics.tsb.toStringAsFixed(0)}'
                    : metrics.tsb.toStringAsFixed(0),
                style: TextStyle(
                  fontFamily: 'BarlowCondensed',
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: accentColor,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                metrics.tsbLabel,
                style: const TextStyle(
                  fontFamily: 'ShareTechMono',
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              SLTag(metrics.riskLevel.label, variant: tagVariant),
            ],
          ),
        ],
      ),
    );
  }
}

class MetricsRow extends StatelessWidget {
  final TrainingMetrics metrics;

  const MetricsRow({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'CARGA AGUDA · ATL',
            value: metrics.atl.toStringAsFixed(0),
            sub: '7-day rolling avg',
            color: AppColors.accent2,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            label: 'CARGA CRÓNICA · CTL',
            value: metrics.ctl.toStringAsFixed(0),
            sub: '28-day rolling avg',
            color: AppColors.accent4,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SLCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SLSectionLabel(label),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'BarlowCondensed',
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(
              fontFamily: 'ShareTechMono',
              fontSize: 8,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class ACWRBar extends StatelessWidget {
  final double acwr;

  const ACWRBar({super.key, required this.acwr});

  Color get _indicatorColor {
    if (acwr < 0.8) return AppColors.riskGreen;
    if (acwr <= 1.3) return AppColors.accent4;
    if (acwr <= 1.5) return AppColors.accent3;
    return AppColors.riskRed;
  }

  double get _fill => ((acwr - 0.5) / 1.2).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SLSectionLabel('ACWR — RATIO'),
            Text(
              acwr.toStringAsFixed(2),
              style: TextStyle(
                fontFamily: 'BarlowCondensed',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _indicatorColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.surface3,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: _fill,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.accent,
                        AppColors.accent4,
                        AppColors.riskRed,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0.8 BAJO',
              style: TextStyle(
                fontFamily: 'ShareTechMono',
                fontSize: 8,
                color: AppColors.riskGreen,
              ),
            ),
            Text(
              '1.0 – 1.3 ÓPTIMO',
              style: TextStyle(
                fontFamily: 'ShareTechMono',
                fontSize: 8,
                color: AppColors.accent4,
              ),
            ),
            Text(
              '1.5+ ALTO',
              style: TextStyle(
                fontFamily: 'ShareTechMono',
                fontSize: 8,
                color: AppColors.riskRed,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ATLCTLMiniChart extends StatelessWidget {
  final List<ChartPoint> data;

  const ATLCTLMiniChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SLCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SLSectionLabel('ATL / CTL — ÚLTIMAS 4 SEMANAS'),
              SLTag('LIVE', variant: TagVariant.cyan),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 70,
            child: CustomPaint(
              painter: _ChartPainter(data),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _legend(AppColors.accent2, 'ATL'),
              const SizedBox(width: 16),
              _legend(AppColors.accent4, 'CTL'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label) => Row(
        children: [
          Container(
            width: 12,
            height: 2,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'ShareTechMono',
              fontSize: 8,
              color: AppColors.textMuted,
            ),
          ),
        ],
      );
}

class _ChartPainter extends CustomPainter {
  final List<ChartPoint> data;

  _ChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final allVals = [...data.map((d) => d.atl), ...data.map((d) => d.ctl)];
    final minV = allVals.reduce((a, b) => a < b ? a : b) - 5;
    final maxV = allVals.reduce((a, b) => a > b ? a : b) + 5;

    double xOf(int i) => i / (data.length - 1) * size.width;
    double yOf(double v) => size.height - ((v - minV) / (maxV - minV)) * size.height;

    // ATL area fill
    final atlPath = Path();
    atlPath.moveTo(xOf(0), yOf(data.first.atl));
    for (int i = 1; i < data.length; i++) {
      atlPath.lineTo(xOf(i), yOf(data[i].atl));
    }
    atlPath.lineTo(xOf(data.length - 1), size.height);
    atlPath.lineTo(0, size.height);
    atlPath.close();

    canvas.drawPath(
      atlPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            // ignore: deprecated_member_use
            AppColors.accent2.withOpacity(0.2),
            // ignore: deprecated_member_use
            AppColors.accent2.withOpacity(0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // CTL line
    _drawLine(canvas, size, data.map((d) => d.ctl).toList(), AppColors.accent4, 1.5, xOf, yOf);

    // ATL line
    _drawLine(canvas, size, data.map((d) => d.atl).toList(), AppColors.accent2, 2, xOf, yOf);

    // Current point dots
    canvas.drawCircle(
      Offset(xOf(data.length - 1), yOf(data.last.atl)),
      3,
      Paint()..color = AppColors.accent2,
    );
    canvas.drawCircle(
      Offset(xOf(data.length - 1), yOf(data.last.ctl)),
      3,
      Paint()..color = AppColors.accent4,
    );
  }

  void _drawLine(
    Canvas canvas,
    Size size,
    List<double> values,
    Color color,
    double strokeWidth,
    double Function(int) xOf,
    double Function(double) yOf,
  ) {
    final path = Path();
    path.moveTo(xOf(0), yOf(values[0]));
    for (int i = 1; i < values.length; i++) {
      path.lineTo(xOf(i), yOf(values[i]));
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ChartPainter old) => old.data != data;
}

class QuickActionsRow extends StatelessWidget {
  final VoidCallback onLogSession;
  final VoidCallback onViewPlan;

  const QuickActionsRow({
    super.key,
    required this.onLogSession,
    required this.onViewPlan,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onLogSession,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('💪', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 6),
                  Text(
                    'LOG SESIÓN',
                    style: TextStyle(
                      fontFamily: 'BarlowCondensed',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 2,
                      color: AppColors.bg,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: onViewPlan,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📅', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 6),
                  Text(
                    'VER PLAN',
                    style: TextStyle(
                      fontFamily: 'BarlowCondensed',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      letterSpacing: 2,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
