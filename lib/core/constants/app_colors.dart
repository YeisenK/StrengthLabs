import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const seedColor = Color(0xFF6366F1);

  static const backgroundDark = Color(0xFF0F0F18);
  static const surfaceDark = Color(0xFF17171F);
  static const cardDark = Color(0xFF1E1E2A);
  static const divider = Color(0xFF2A2A38);

  static const green = Color(0xFF10B981);
  static const greenMuted = Color(0xFF064E3B);
  static const amber = Color(0xFFF59E0B);
  static const amberMuted = Color(0xFF78350F);
  static const red = Color(0xFFEF4444);
  static const redMuted = Color(0xFF7F1D1D);

  static const textPrimary = Color(0xFFF1F1F5);
  static const textSecondary = Color(0xFF8B8B9E);
  static const textDisabled = Color(0xFF4A4A5A);

  static Color fatigueColor(double index) {
    if (index < 40) return green;
    if (index < 70) return amber;
    if (index < 85) return const Color(0xFFF97316);
    return red;
  }
}
