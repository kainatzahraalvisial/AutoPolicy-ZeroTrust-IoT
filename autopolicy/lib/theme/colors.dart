import 'package:flutter/material.dart';

class CyberColors {
  // 6-Color Cyber Palette
  static const Color color1DarkEmerald = Color(0xFF032820); // #032820 - Accent Dark
  static const Color color2Olive = Color(0xFF80A416);       // #80A416 - Primary Accent
  static const Color color3LimeGold = Color(0xFFC5C764);    // #C5C764 - Frames / Borders
  static const Color color4BrightEmerald = Color(0xFF08652C); // #08652C - Deep Emerald Accent
  static const Color color5WarmOliveGold = Color(0xFFAD9F3C); // #AD9F3C - Warm Gold Badges
  static const Color color6Sage = Color(0xFF5E7343);         // #5E7343 - Sage / Muted Accent

  // Base dark cyber black backgrounds
  static const Color backgroundDark = Color(0xFF050A07);
  static const Color backgroundLight = Color(0xFF08120C);
  
  // Card & Panel dark backgrounds
  static const Color cardBg = Color(0xFF0C140E);
  static const Color panelBg = Color(0xFF08120C);
  
  // High-frequency neon accents
  static const Color neonGreen = Color(0xFFBBF438);
  static const Color neonCyan = Color(0xFFC5C764);
  
  // Alerts and Telemetry status
  static const Color alertRed = Color(0xFFFF4757);
  static const Color warningOrange = Color(0xFFAD9F3C);
  static const Color statusSafe = Color(0xFFBBF438);
  
  // Border and accent styling lines
  static const Color borderNeonGreen = Color(0x66BBF438);
  static const Color borderNeonCyan = Color(0x66C5C764);
  static const Color gridLine = Color(0x2280A416);
  
  // Muted tech greys & text
  static const Color textMuted = Color(0xFF829A80);
  static const Color textActive = Color(0xFFEDF5EB);
  
  // Ambient glows
  static const List<BoxShadow> greenGlow = [
    BoxShadow(
      color: Color(0x66BBF438),
      blurRadius: 16,
      spreadRadius: 1,
    )
  ];
  
  static const List<BoxShadow> cyanGlow = [
    BoxShadow(
      color: Color(0x66C5C764),
      blurRadius: 16,
      spreadRadius: 1,
    )
  ];

  static const List<BoxShadow> redGlow = [
    BoxShadow(
      color: Color(0x66FF4757),
      blurRadius: 16,
      spreadRadius: 1,
    )
  ];
}
