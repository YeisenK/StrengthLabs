import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFF080C0A);
  static const surface = Color(0xFF0D1410);
  static const surface2 = Color(0xFF121A15);
  static const surface3 = Color(0xFF1A2420);

  static const border = Color(0xFF1F2E27);
  static const border2 = Color(0xFF2A3D33);

  static const accent = Color(0xFFA8FF3E);
  static const accent2 = Color(0xFF00FFB3);
  static const accent3 = Color(0xFFFF6B35);
  static const accent4 = Color(0xFFFFCC00);

  static const riskGreen = Color(0xFFA8FF3E);
  static const riskYellow = Color(0xFFFFCC00);
  static const riskRed = Color(0xFFFF3D3D);

  static const textPrimary = Color(0xFFE8F5ED);
  static const textSecondary = Color(0xFF8AA898);
  static const textMuted = Color(0xFF4D6B5A);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          background: AppColors.bg,
          surface: AppColors.surface,
          primary: AppColors.accent,
          secondary: AppColors.accent2,
          error: AppColors.riskRed,
          onPrimary: AppColors.bg,
          onBackground: AppColors.textPrimary,
          onSurface: AppColors.textPrimary,
        ),
        textTheme: GoogleFonts.barlowTextTheme().copyWith(
          displayLarge: GoogleFonts.barlowCondensed(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -1,
          ),
          titleLarge: GoogleFonts.barlowCondensed(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: AppColors.textPrimary,
          ),
          titleMedium: GoogleFonts.barlowCondensed(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          bodyMedium: GoogleFonts.barlow(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          labelSmall: GoogleFonts.shareTechMono(
            fontSize: 9,
            letterSpacing: 2,
            color: AppColors.textMuted,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface2,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.bg,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.barlowCondensed(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: AppColors.textPrimary,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: GoogleFonts.shareTechMono(
            fontSize: 9,
            letterSpacing: 1,
          ),
          unselectedLabelStyle: GoogleFonts.shareTechMono(
            fontSize: 9,
            letterSpacing: 1,
          ),
        ),
      );
}