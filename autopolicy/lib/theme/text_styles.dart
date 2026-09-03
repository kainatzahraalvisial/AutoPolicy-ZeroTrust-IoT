import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class CyberTextStyles {
  // Futuristic display titles (uses Outfit for next-level modern elegance)
  static TextStyle displayTitle({
    double fontSize = 24.0,
    Color color = const Color(0xFF7B96EC), // Premium periwinkle blue by default
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: 0.5,
    );
  }

  // Technical mono details (uses Share Tech Mono)
  static TextStyle technical({
    double fontSize = 14.0,
    Color color = const Color(0xFF8E9BB4), // Premium muted slate-grey by default
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return GoogleFonts.shareTechMono(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: 0.5,
    );
  }

  // UI interface font (uses Plus Jakarta Sans for sleek modern readability)
  static TextStyle interface({
    double fontSize = 14.0,
    Color color = const Color(0xFFE2E8F0),
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: 0.2,
    );
  }

  // Coordinated typography styles
  static TextStyle heading1 = displayTitle(fontSize: 32, color: const Color(0xFF7B96EC)); // Vibrant periwinkle
  static TextStyle heading2 = displayTitle(fontSize: 22, color: const Color(0xFFF8FAFC)); // Sleek ice white
  static TextStyle heading3 = displayTitle(fontSize: 16, color: const Color(0xFFE2E8F0)); // Soft white
  
  static TextStyle techBody = technical(fontSize: 14, color: const Color(0xFFE2E8F0));
  static TextStyle techMuted = technical(fontSize: 12, color: const Color(0xFF8E9BB4)); // Slate grey
  static TextStyle techAlert = technical(fontSize: 14, color: CyberColors.alertRed);
  
  static TextStyle label = interface(fontSize: 12, color: const Color(0xFF8E9BB4), fontWeight: FontWeight.w600);
  static TextStyle value = interface(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold);

  static void updateTheme(bool isDarkMode) {
    heading1 = displayTitle(
      fontSize: 32, 
      color: isDarkMode ? const Color(0xFF7B96EC) : const Color(0xFF1E3A8A), // Deep Blue in Light Mode
    );
    heading2 = displayTitle(
      fontSize: 22, 
      color: isDarkMode ? const Color(0xFFF8FAFC) : Colors.black, // Pure black
    );
    heading3 = displayTitle(
      fontSize: 16, 
      color: isDarkMode ? const Color(0xFFE2E8F0) : Colors.black87, // Dark black-grey
    );
    
    techBody = technical(
      fontSize: 14, 
      color: isDarkMode ? const Color(0xFFCBD5E1) : Colors.black87,
    );
    techMuted = technical(
      fontSize: 12, 
      color: isDarkMode ? const Color(0xFF8E9BB4) : Colors.black54, // Highly visible black-grey
    );
    
    label = interface(
      fontSize: 12, 
      color: isDarkMode ? const Color(0xFF8E9BB4) : Colors.black87, 
      fontWeight: FontWeight.w600,
    );
    value = interface(
      fontSize: 14, 
      color: isDarkMode ? Colors.white : Colors.black, 
      fontWeight: FontWeight.bold,
    );
  }
}
