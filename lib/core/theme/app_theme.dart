import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg       = Color(0xFF0B0C15);
  static const surface  = Color(0xFF11121E);
  static const surface2 = Color(0xFF181929);
  static const surface3 = Color(0xFF1F2038);
  static const border  = Color(0xFF23253E);
  static const border2 = Color(0xFF2C2F52);
  static const accent  = Color(0xFF3A76F0);  
  static const accent2 = Color(0xFF00C9B1);  
  static const accent3 = Color(0xFFFF6B35);  
  static const accent4 = Color(0xFFF0BE3D);  
  static const riskGreen  = Color(0xFF30C97A);
  static const riskYellow = Color(0xFFF0BE3D);
  static const riskRed    = Color(0xFFFF4545);
  static const textPrimary   = Color(0xFFE8EAF6);
  static const textSecondary = Color(0xFF72779E);
  static const textMuted     = Color(0xFF3A3D5C);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          surface: AppColors.surface,
          primary: AppColors.accent,
          secondary: AppColors.accent2,
          error: AppColors.riskRed,
          onPrimary: AppColors.textPrimary,
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
