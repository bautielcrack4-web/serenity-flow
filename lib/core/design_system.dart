import 'package:flutter/material.dart';

class AppColors {
  // Vibrant Palette
  static const Color coral = Color(0xFFFF7A65); 
  static const Color lavender = Color(0xFFA88DD0);
  static const Color turquoise = Color(0xFF5DBBB3);
  static const Color gold = Color(0xFFFFD700);
  
  // Backgrounds
  static const Color cream = Color(0xFFFFF8F5);
  static const Color white = Colors.white;
  
  // Text
  static const Color dark = Color(0xFF2D3142); 
  static const Color gray = Color(0xFF9E9E9E);
  static const Color lightGray = Color(0xFFF5F5F5); // Softer light gray
  
  // Routine Gradients
  static const LinearGradient peachGradient = LinearGradient(
    colors: [Color(0xFFFFE8D6), Color(0xFFFFD4B8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient lavenderSoftGradient = LinearGradient(
    colors: [Color(0xFFE8DFF5), Color(0xFFD4C5F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient turquoiseSoftGradient = LinearGradient(
    colors: [Color(0xFFD0EAE8), Color(0xFFB8DCD9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Status Gradients
  static const LinearGradient coralStatusGradient = LinearGradient(
    colors: [Color(0xFFFF9B85), Color(0xFFFF7A65)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient turquoiseStatusGradient = LinearGradient(
    colors: [Color(0xFF7BC9C3), Color(0xFF5DBBB3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient fireGradient = LinearGradient(
    colors: [Color(0xFFFF9D00), Color(0xFFFFCC00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = coralStatusGradient;
  static const LinearGradient organicGradient = coralStatusGradient; // Added for compatibility
}

class AppShadows {
  // Unified Shadows
  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get button => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevated => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  // Legacy/Compatibility
  static List<BoxShadow> get floating => elevated;
  static List<BoxShadow> get soft => card;
  static List<BoxShadow> get glow => [
    BoxShadow(
      color: AppColors.coral.withOpacity(0.4),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
}

class AppTypography {
  static const String titleFont = 'Outfit'; // User requested Outfit
  static const String bodyFont = 'Outfit';
  
  static ThemeData get theme => ThemeData(
    fontFamily: bodyFont,
    primaryColor: AppColors.coral,
    scaffoldBackgroundColor: AppColors.cream,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: AppColors.lavender,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: titleFont, fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.dark),
      headlineMedium: TextStyle(fontFamily: titleFont, fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.dark),
      headlineSmall: TextStyle(fontFamily: titleFont, fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.dark),
      bodyLarge: TextStyle(fontFamily: bodyFont, fontSize: 18, color: AppColors.dark, fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(fontFamily: bodyFont, fontSize: 16, color: AppColors.dark, fontWeight: FontWeight.w500),
      bodySmall: TextStyle(fontFamily: bodyFont, fontSize: 15, color: AppColors.dark),
      labelMedium: TextStyle(fontFamily: bodyFont, fontSize: 13, color: AppColors.gray, fontWeight: FontWeight.w500),
    ),
  );

  // Direct getters for consistency with old code
  static TextStyle get displayLarge => const TextStyle(fontFamily: titleFont, fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.dark);
  static TextStyle get headlineMedium => const TextStyle(fontFamily: titleFont, fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.dark);
}

/// Premium typography system with weight hierarchy
class AppTextStyles {
  // Display (900) - Hero titles
  static const TextStyle display = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    height: 1.1,
    letterSpacing: -1.5,
  );

  // Headline (700) - Section headers
  static const TextStyle headline = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  // Title (600) - Card titles
  static const TextStyle title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // Body (600) - Regular text
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  // Caption (300) - Subtle text
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w300,
    height: 1.4,
    letterSpacing: 0.2,
  );

  // Numbers (tabular figures for alignment)
  static const TextStyle number = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle numberLarge = TextStyle(
    fontSize: 72,
    fontWeight: FontWeight.w900,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}


class AppSpacings {
  static const double padding = 24.0;
  static const double betweenSections = 32.0;
  static const double betweenElements = 16.0;
  static const double betweenCards = 20.0;
}
