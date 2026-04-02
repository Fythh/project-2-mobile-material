import 'package:flutter/material.dart';

// ============ WARNA (mirip Tailwind color palette) ============
class AppColors {
  // Primary colors (orange tema material bangunan)
  static const primary = Color(0xFFF97316);      // orange-500
  static const primaryDark = Color(0xFFEA580C);   // orange-600
  static const primaryLight = Color(0xFFFED7AA);  // orange-200
  
  // Secondary colors
  static const secondary = Color(0xFF3B82F6);     // blue-500
  
  // Status colors
  static const success = Color(0xFF22C55E);       // green-500
  static const warning = Color(0xFFEAB308);       // yellow-500
  static const danger = Color(0xFFEF4444);        // red-500
  
  // Gray scale (abu-abu)
  static const gray50 = Color(0xFFF9FAFB);
  static const gray100 = Color(0xFFF3F4F6);
  static const gray200 = Color(0xFFE5E7EB);
  static const gray300 = Color(0xFFD1D5DB);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray500 = Color(0xFF6B7280);
  static const gray600 = Color(0xFF4B5563);
  static const gray700 = Color(0xFF374151);
  static const gray800 = Color(0xFF1F2937);
  static const gray900 = Color(0xFF111827);
  
  // Background
  static const background = Colors.white;
  static const cardBackground = Colors.white;
}

// ============ SPACING (mirip Tailwind spacing) ============
class AppSpacing {
  static const xs = 4.0;    // gap-1 / p-1
  static const sm = 8.0;    // gap-2 / p-2
  static const md = 16.0;   // gap-4 / p-4
  static const lg = 24.0;   // gap-6 / p-6
  static const xl = 32.0;   // gap-8 / p-8
  static const xxl = 48.0;  // gap-12 / p-12
}

// ============ TYPOGRAPHY (mirip Tailwind text classes) ============
class AppTextStyle {
  static const heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.gray900,
  );
  
  static const heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.gray900,
  );
  
  static const heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.gray800,
  );
  
  static const bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.gray700,
  );
  
  static const bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.gray600,
  );
  
  static const bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.gray500,
  );
  
  static const caption = TextStyle(
    fontSize: 10,
    color: AppColors.gray400,
  );
}

// ============ SHADOW (mirip Tailwind shadow) ============
class AppShadow {
  static List<BoxShadow> sm = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];
  
  static List<BoxShadow> md = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> lg = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}

// ============ BORDER RADIUS ============
class AppBorderRadius {
  static const sm = BorderRadius.all(Radius.circular(8));
  static const md = BorderRadius.all(Radius.circular(12));
  static const lg = BorderRadius.all(Radius.circular(16));
  static const xl = BorderRadius.all(Radius.circular(24));
  static const full = BorderRadius.all(Radius.circular(100));
}

// ============ THEME UTAMA ============
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.background,
        error: AppColors.danger,
      ),
      fontFamily: 'Poppins', // opsional, kalo ga punya font ini, hapus aja
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.md,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.md,
        ),
        color: AppColors.cardBackground,
      ),
    );
  }
}