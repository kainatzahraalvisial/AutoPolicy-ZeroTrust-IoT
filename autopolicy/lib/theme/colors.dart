import 'package:flutter/material.dart';

class CyberColors {
  // Base dark backgrounds
  static const Color backgroundDark = Color(0xFF050816); // #050816
  static const Color backgroundLight = Color(0xFF0B1020); // #0B1020
  
  // Card & Panel backgrounds (with glassmorphism in mind)
  static const Color cardBg = Color(0xFF151B2F); // #151B2F
  static const Color panelBg = Color(0xFF1F294D); // #1F294D
  
  // High-frequency neon accents
  static const Color neonGreen = Color(0xFF00FF9F); // #00FF9F
  static const Color neonCyan = Color(0xFF00F5FF); // #00F5FF
  
  // Alerts and Telemetry status
  static const Color alertRed = Color(0xFFFF4757); // #FF4757
  static const Color warningOrange = Color(0xFFFFA502); // #FFA502
  static const Color statusSafe = Color(0xFF00FF9F);
  
  // Border and accent styling lines
  static const Color borderNeonGreen = Color(0x3300FF9F); // semi-transparent
  static const Color borderNeonCyan = Color(0x3300F5FF); // semi-transparent
  static const Color gridLine = Color(0x0D00F5FF); // ultra-faint cyan grid
  
  // Muted tech greys
  static const Color textMuted = Color(0xFF8B9BB4);
  static const Color textActive = Color(0xFFE2E8F0);
  
  // Ambient glows
  static const List<BoxShadow> greenGlow = [
    BoxShadow(
      color: Color(0x4D00FF9F),
      blurRadius: 12,
      spreadRadius: 1,
    )
  ];
  
  static const List<BoxShadow> cyanGlow = [
    BoxShadow(
      color: Color(0x4D00F5FF),
      blurRadius: 12,
      spreadRadius: 1,
    )
  ];

  static const List<BoxShadow> redGlow = [
    BoxShadow(
      color: Color(0x4DFF4757),
      blurRadius: 12,
      spreadRadius: 1,
    )
  ];
}
