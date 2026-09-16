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
  
  // Mokoto Red Palette (media_1788771394953.png)
  static const Color crimsonRed = Color(0xFFDF2531);        // #DF2531 - Crimson Threat Red
  static const Color crimsonRed45 = Color(0x73DF2531);      // 45% transparency
  static const Color crimsonRed65 = Color(0xA6DF2531);      // 65% transparency

  // Cyber Purple Accent (media_1788771547362.png)
  static const Color cyberPurple = Color(0xFF8B5CF6);       // #8B5CF6 - Vibrant Electric Purple
  static const Color cyberPurpleDeep = Color(0xFF6D28D9);   // #6D28D9 - Deep Purple Accent

  // Oscillate Green Palette (media_1788771383408.png)
  static const Color obsidianBlack = Color(0xFF0F0F0F);     // #0F0F0F - Dark Obsidian
  static const Color panelDark = Color(0xFF202020);         // #202020 - Dark Tactical Panel
  static const Color brightLime = Color(0xFF5DD62C);        // #5DD62C - Bright Cyber Lime
  static const Color forestOlive = Color(0xFF337418);       // #337418 - Deep Forest Olive
  static const Color textOffWhite = Color(0xFFF8F8F8);      // #F8F8F8 - Off-White Text

  // Alerts and Telemetry status
  static const Color alertRed = Color(0xFFDF2531);          // Mokoto Crimson Red
  static const Color warningOrange = Color(0xFFAD9F3C);
  static const Color statusSafe = Color(0xFF5DD62C);
  
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

class CyberLightPalette {
  static const Color featherWhite = Color(0xFFFAF9F6);
  static const Color cardWhite = Color(0xFFFFFFFF);
  
  // 5 New Swatch Colors from user (media_1789540084605.png)
  static const Color cream = Color(0xFFFFF9E1);        // #FFF9E1 - Warm Cream / Ivory
  static const Color paleSage = Color(0xFFEBECCC);     // #EBECCC - Pale Sage Green
  static const Color sage = Color(0xFFCDD4B2);         // #CDD4B2 - Sage / Gray-Green (Border/Outline)
  static const Color softLavender = Color(0xFFD4C9D8); // #D4C9D8 - Soft Lilac Lavender
  static const Color darkLavender = Color(0xFFB8A9C1); // #B8A9C1 - Darker Lavender (Auth button/Accents)
  
  // Contrasting Black / Dark Typography
  static const Color textBlack = Color(0xFF0F172A);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textSecondary = Color(0xFF334155);
}
