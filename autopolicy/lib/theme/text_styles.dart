import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class CyberTextStyles {
  // Barlow font for display titles, subheadings, paragraphs, sidebar, and cards
  static TextStyle displayTitle({
    double fontSize = 26.0,
    Color color = const Color(0xFF7B96EC),
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return GoogleFonts.barlow(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: 0.5,
    );
  }

  // Technical details (uses Barlow with medium/semi-bold weight for high legibility)
  static TextStyle technical({
    double fontSize = 15.0,
    Color color = const Color(0xFF8E9BB4),
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return GoogleFonts.barlow(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: 0.3,
    );
  }

  // UI interface font (uses Barlow for crisp modern cyber legibility)
  static TextStyle interface({
    double fontSize = 16.0,
    Color color = const Color(0xFFE2E8F0),
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return GoogleFonts.barlow(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: 0.2,
    );
  }

  // Body & Paragraph font (uses Barlow for optimal readability & contrast)
  static TextStyle paragraph({
    double fontSize = 16.0,
    Color color = const Color(0xFFD5E5D3),
    FontWeight fontWeight = FontWeight.normal,
    double height = 1.5,
  }) {
    return GoogleFonts.barlow(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: 0.2,
    );
  }

  // Coordinated typography styles
  static TextStyle heading1 = displayTitle(fontSize: 34, color: const Color(0xFF7B96EC));
  static TextStyle heading2 = displayTitle(fontSize: 24, color: const Color(0xFFF8FAFC));
  static TextStyle heading3 = displayTitle(fontSize: 18, color: const Color(0xFFE2E8F0));
  
  static TextStyle techBody = paragraph(fontSize: 16.0, color: const Color(0xFFE2E8F0));
  static TextStyle techMuted = paragraph(fontSize: 14.5, color: const Color(0xFF9EBA9C));
  static TextStyle techAlert = technical(fontSize: 15.0, color: CyberColors.alertRed, fontWeight: FontWeight.bold);
  
  static TextStyle label = interface(fontSize: 14.0, color: const Color(0xFF9EBA9C), fontWeight: FontWeight.w600);
  static TextStyle value = interface(fontSize: 16.5, color: Colors.white, fontWeight: FontWeight.bold);

  static void updateTheme(bool isDarkMode) {
    heading1 = displayTitle(
      fontSize: 34, 
      color: isDarkMode ? const Color(0xFF7B96EC) : const Color(0xFF1E3A8A),
    );
    heading2 = displayTitle(
      fontSize: 24, 
      color: isDarkMode ? const Color(0xFFF8FAFC) : Colors.black,
    );
    heading3 = displayTitle(
      fontSize: 18, 
      color: isDarkMode ? const Color(0xFFE2E8F0) : Colors.black87,
    );
    
    techBody = paragraph(
      fontSize: 16.0, 
      color: isDarkMode ? const Color(0xFFCBD5E1) : Colors.black87,
    );
    techMuted = paragraph(
      fontSize: 14.5, 
      color: isDarkMode ? const Color(0xFF9EBA9C) : Colors.black54,
    );
    
    label = interface(
      fontSize: 14.0, 
      color: isDarkMode ? const Color(0xFF9EBA9C) : Colors.black87, 
      fontWeight: FontWeight.w600,
    );
    value = interface(
      fontSize: 16.5, 
      color: isDarkMode ? Colors.white : Colors.black, 
      fontWeight: FontWeight.bold,
    );
  }
}
