import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors - Teal/Cyan theme (modern, calming)
  // White text on primary must reach 4.5:1 (HIG Accessibility, WCAG AA):
  // Teal 700 gives 5.47:1, Teal 600 only 3.74:1.
  static const Color primary = Color(0xFF0F766E);      // Teal 700
  static const Color primaryLight = Color(0xFF0D9488); // Teal 600
  static const Color primaryDark = Color(0xFF115E59);  // Teal 800

  /// Primary used as a text and icon color on dark backgrounds, where Teal 700
  /// is too dark (2.7:1 on Slate 800). Teal 400 gives 7.9:1.
  static const Color primaryOnDark = Color(0xFF2DD4BF); // Teal 400

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

  // Backgrounds behind white text (snackbars, buttons) need 4.5:1; Emerald
  // 500 and Amber 500 give 2.5:1 and 2.2:1.
  static const Color successStrong = Color(0xFF047857); // Emerald 700, 5.48:1
  static const Color accentStrong = Color(0xFFB45309);  // Amber 700, 5.02:1

  // Background Colors
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color backgroundDark = Color(0xFF1E293B);  // Slate 800
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF334155);     // Slate 700

  // Card Colors
  static const Color cardBack = primary;
  static const Color cardBackGradientStart = primary;
  static const Color cardBackGradientEnd = primaryLight;
  static const Color cardMatched = Color(0xFF10B981);     // Emerald 500
  static const Color cardMatchedGlow = Color(0x4010B981);

  // Text Colors (constants for light mode)
  static const Color textPrimaryLight = Color(0xFF1E293B);     // Slate 800
  static const Color textSecondaryLight = Color(0xFF64748B);   // Slate 500
  static const Color textLight = Color(0xFFFFFFFF);
  /// Secondary text on primary backgrounds: 90% white, 4.75:1 on primary.
  /// White70 and lighter fall below 4.5:1.
  static const Color textLightSecondary = Color(0xE6FFFFFF);
  static const Color textMuted = Color(0xFF94A3B8);       // Slate 400
  /// Secondary text in dark mode. Slate 400 gives only 4.04:1 on surfaceDark;
  /// Slate 300 gives 6.97:1.
  static const Color textSecondaryDark = Color(0xFFCBD5E1); // Slate 300

  // Game UI Colors
  static const Color scorePositive = Color(0xFF10B981);   // Emerald 500
  static const Color scoreNegative = Color(0xFFEF4444);   // Red 500
  static const Color comboColor = Color(0xFFF59E0B);      // Amber 500
  static const Color timerNormal = primary;
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

  // Carries bold white text: 5.48:1 to 3.77:1 (3:1 is enough for bold).
  static const LinearGradient successGradient = LinearGradient(
    colors: [successStrong, Color(0xFF059669)], // Emerald 700 to 600
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
  static Color primaryText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? primaryOnDark : primary;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textLight : textPrimaryLight;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? textSecondaryDark
          : textSecondaryLight;

  // Card background color
  static Color cardBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? surfaceDark
          : surface;

  // Card border color
  static Color cardBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF475569) // Slate 600
          : const Color(0xFFE2E8F0); // Slate 200
}
