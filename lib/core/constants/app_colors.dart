import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors - Teal/Cyan theme (modern, calming)
  static const Color primary = Color(0xFF0D9488);      // Teal 600
  static const Color primaryLight = Color(0xFF14B8A6); // Teal 500
  static const Color primaryDark = Color(0xFF0F766E);  // Teal 700

  // Secondary Colors - Slate for contrast
  static const Color secondary = Color(0xFF475569);    // Slate 600
  static const Color secondaryLight = Color(0xFF64748B); // Slate 500
  static const Color secondaryDark = Color(0xFF334155);  // Slate 700

  // Accent Colors - Amber for highlights
  static const Color accent = Color(0xFFF59E0B);       // Amber 500
  static const Color accentLight = Color(0xFFFBBF24);  // Amber 400
  static const Color accentDark = Color(0xFFD97706);   // Amber 600

  // Success / Error / Warning / Info
  static const Color success = Color(0xFF10B981);      // Emerald 500
  static const Color error = Color(0xFFEF4444);        // Red 500
  static const Color warning = Color(0xFFF59E0B);      // Amber 500
  static const Color info = Color(0xFF3B82F6);         // Blue 500

  // Background Colors
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color backgroundDark = Color(0xFF1E293B);  // Slate 800
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF334155);     // Slate 700

  // Card Colors
  static const Color cardBack = Color(0xFF0D9488);        // Teal 600
  static const Color cardBackGradientStart = Color(0xFF0D9488);
  static const Color cardBackGradientEnd = Color(0xFF14B8A6);
  static const Color cardMatched = Color(0xFF10B981);     // Emerald 500
  static const Color cardMatchedGlow = Color(0x4010B981);

  // Text Colors (constants for light mode)
  static const Color textPrimaryLight = Color(0xFF1E293B);     // Slate 800
  static const Color textSecondaryLight = Color(0xFF64748B);   // Slate 500
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF94A3B8);       // Slate 400

  // Game UI Colors
  static const Color scorePositive = Color(0xFF10B981);   // Emerald 500
  static const Color scoreNegative = Color(0xFFEF4444);   // Red 500
  static const Color comboColor = Color(0xFFF59E0B);      // Amber 500
  static const Color timerNormal = Color(0xFF0D9488);     // Teal 600
  static const Color timerWarning = Color(0xFFF59E0B);    // Amber 500
  static const Color timerDanger = Color(0xFFEF4444);     // Red 500

  // Gradient Presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardBackGradient = LinearGradient(
    colors: [cardBackGradientStart, cardBackGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF34D399)], // Emerald 400
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Theme-aware colors
  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? backgroundDark
          : backgroundLight;

  static Color surfaceColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? surfaceDark : surface;

  // Theme-aware text colors
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textLight : textPrimaryLight;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? textMuted
          : textSecondaryLight;
}
