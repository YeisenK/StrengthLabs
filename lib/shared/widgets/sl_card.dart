// lib/shared/widgets/sl_card.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Base card with SL dark style
class SLCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const SLCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surface2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor ?? AppColors.border,
            width: 1,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Mono-style tag label (GREEN / YELLOW / RED)
class SLTag extends StatelessWidget {
  final String label;
  final TagVariant variant;

  const SLTag(this.label, {super.key, this.variant = TagVariant.green});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (variant) {
      TagVariant.green => (
          AppColors.riskGreen.withOpacity(0.1),
          AppColors.riskGreen
        ),
      TagVariant.yellow => (
          AppColors.accent4.withOpacity(0.1),
          AppColors.accent4
        ),
      TagVariant.red => (
          AppColors.riskRed.withOpacity(0.1),
          AppColors.riskRed
        ),
      TagVariant.cyan => (
          AppColors.accent2.withOpacity(0.1),
          AppColors.accent2
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: fg.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'ShareTechMono',
          fontSize: 9,
          letterSpacing: 2,
          color: fg,
        ),
      ),
    );
  }
}

enum TagVariant { green, yellow, red, cyan }

/// Section header with mono label
class SLSectionLabel extends StatelessWidget {
  final String label;

  const SLSectionLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: const TextStyle(
          fontFamily: 'ShareTechMono',
          fontSize: 9,
          letterSpacing: 3,
          color: AppColors.textMuted,
        ),
      );
}

/// Primary CTA button
class SLPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  const SLPrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.bg, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'BarlowCondensed',
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 3,
                color: AppColors.bg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
