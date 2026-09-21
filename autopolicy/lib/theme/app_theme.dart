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
      cardTheme: CardTheme(
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
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF8B5CF6);
          }
          return const Color(0xFFFFF9E1);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFFD4C9D8);
          }
          return const Color(0xFFEBECCC);
        }),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: Color(0xFF8B5CF6),
        thumbColor: Color(0xFF8B5CF6),
        inactiveTrackColor: Color(0xFFEBECCC),
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
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF7F8F0),
      primaryColor: const Color(0xFF80A416),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF80A416),
        secondary: Color(0xFF7C3AED),
        surface: Color(0xFFFAF9F6),
        error: Color(0xFFD82734),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFFFAF9F6),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFCDD4B2), width: 1),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF8B5CF6);
          }
          return const Color(0xFFFFF9E1);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFFD4C9D8);
          }
          return const Color(0xFFEBECCC);
        }),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: Color(0xFF8B5CF6),
        thumbColor: Color(0xFF8B5CF6),
        inactiveTrackColor: Color(0xFFEBECCC),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFAF9F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCDD4B2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCDD4B2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF80A416)),
        ),
        labelStyle: CyberTextStyles.technical(color: const Color(0xFF64748B)),
        hintStyle: CyberTextStyles.technical(color: const Color(0xFF94A3B8)),
      ),
    );
  }
}
