import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

class CyberTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: CyberColors.backgroundDark,
      primaryColor: CyberColors.neonGreen,
      colorScheme: const ColorScheme.dark(
        primary: CyberColors.neonGreen,
        secondary: CyberColors.neonCyan,
        surface: CyberColors.cardBg,
        error: CyberColors.alertRed,
      ),
      cardTheme: CardThemeData(
        color: CyberColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: CyberColors.borderNeonCyan, width: 1),
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(CyberColors.neonCyan.withOpacity(0.3)),
        trackColor: WidgetStateProperty.all(Colors.transparent),
        radius: const Radius.circular(8),
      ),
      textTheme: TextTheme(
        headlineMedium: CyberTextStyles.heading1,
        headlineSmall: CyberTextStyles.heading2,
        titleMedium: CyberTextStyles.heading3,
        bodyLarge: CyberTextStyles.techBody,
        bodyMedium: CyberTextStyles.paragraph(fontSize: 15.0),
        bodySmall: CyberTextStyles.techMuted,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CyberColors.cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CyberColors.borderNeonCyan),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CyberColors.borderNeonCyan),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CyberColors.neonGreen),
        ),
        labelStyle: CyberTextStyles.technical(color: CyberColors.textMuted),
        hintStyle: CyberTextStyles.technical(color: CyberColors.textMuted.withOpacity(0.5)),
      ),
      dividerTheme: const DividerThemeData(
        color: CyberColors.gridLine,
        space: 1,
        thickness: 1,
      ),
    );
  }
}
