import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable Opaque Cyber Stat/Number Card matching user swatches & HUD frame design
/// Features:
/// - Crisp 1.6px contrasting HUD boundary stroke frame
/// - Rich 100% solid opaque background fill
/// - Top-Right solid chamfer cut polygon badge
/// - Bottom-Left '<<<' technical chevron indicator marks
/// - Segmented bottom status tick bar
class CyberStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String sub;
  final IconData? icon;
  final Color borderColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final String? tag;
  final bool isAlert;

  const CyberStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.sub,
    this.icon,
    required this.borderColor,
    this.backgroundColor,
    this.onTap,
    this.tag,
    this.isAlert = false,
  });

  Color get _solidBgColor {
    if (backgroundColor != null) return backgroundColor!;
    final int val = borderColor.value;
    if (val == const Color(0xFFFFE997).value || val == const Color(0xFFC5C764).value || val == const Color(0xFFFDFDC9).value) {
      return const Color(0xFFFFE997); // 1. Soft Yellow #FFE997
    } else if (val == const Color(0xFFA88AED).value) {
      return const Color(0xFFA88AED); // 2. Indigo Purple #A88AED
    } else if (val == const Color(0xFFC4E320).value || val == const Color(0xFF5DD62C).value) {
      return const Color(0xFFC4E320); // 3. Bright Light Green #C4E320
    } else if (val == const Color(0xFF80A416).value || val == const Color(0xFF337418).value) {
      return const Color(0xFF80A416); // 4. Olive Green #80A416
    } else if (val == const Color(0xFFB91C1D).value) {
      return const Color(0xFFB91C1D); // 5. Crimson Red #B91C1D
    }
    return borderColor.withOpacity(1.0);
  }

  bool get _isLightSolidFill {
    return _solidBgColor.computeLuminance() > 0.40;
  }

  bool get _isRedThreatCard {
    return isAlert || _solidBgColor.value == const Color(0xFFB91C1D).value;
  }

  bool get _isSolidFill {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Exact requested text colors: #EBECEE for white text, yellow for threat amount on red cards!
    final Color titleColor = _isLightSolidFill ? const Color(0xFF0A0A0E) : const Color(0xFFEBECEE);
    final Color valueColor = _isRedThreatCard
        ? const Color(0xFFFFEA00) // Bright Yellowish color for threat amount on red cards!
        : (_isLightSolidFill ? const Color(0xFF050A07) : const Color(0xFFEBECEE));
    final Color subColor = _isRedThreatCard
        ? const Color(0xFFFFD54F)
        : (_isLightSolidFill ? const Color(0xFF1E293B) : const Color(0xFFD1D5DB));
    final Color accentColor = _isLightSolidFill ? const Color(0xFF050A07) : const Color(0xFFEBECEE);

    Widget cardContent = CustomPaint(
      painter: _OpaqueStatCardPainter(
        borderColor: borderColor,
        solidBackgroundColor: _solidBgColor,
        isSolidFill: _isSolidFill,
        isLightSolidFill: _isLightSolidFill,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 32, 22, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Title & Icon (Barlow bold font)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: GoogleFonts.barlow(
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                      letterSpacing: 0.8,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 6),
                  Icon(icon, color: accentColor, size: 18),
                ],
              ],
            ),
            const SizedBox(height: 8),

            // Middle Row: Big Numerical Value & Subtitle (Barlow bold)
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: GoogleFonts.barlow(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: valueColor,
                    letterSpacing: 0.5,
                    shadows: _isRedThreatCard
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFFEA00).withOpacity(0.5),
                              blurRadius: 10,
                            )
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    sub,
                    style: GoogleFonts.barlow(
                      fontSize: 12.5,
                      color: subColor,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Bottom Row: Optional Corner Tag (Clean bottom-left so + + reticles graphic is unobscured!)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (tag != null)
                  Text(
                    tag!,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      color: accentColor.withOpacity(0.9),
                      letterSpacing: 1.0,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        hoverColor: accentColor.withOpacity(0.12),
        splashColor: accentColor.withOpacity(0.20),
        borderRadius: BorderRadius.circular(4),
        child: cardContent,
      );
    }

    return cardContent;
  }
}

class _OpaqueStatCardPainter extends CustomPainter {
  final Color borderColor;
  final Color solidBackgroundColor;
  final bool isSolidFill;
  final bool isLightSolidFill;

  _OpaqueStatCardPainter({
    required this.borderColor,
    required this.solidBackgroundColor,
    required this.isSolidFill,
    required this.isLightSolidFill,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double c = 14.0; // Corner chamfer size

    final Color strokeColor = isLightSolidFill
        ? const Color(0xFF050A07)
        : const Color(0xFFEBECEE); // Exact #EBECEE specified by user

    // 1. Armor HUD Notched Polygon Boundary Path (Matching media_1789022641185.png)
    final path = Path()
      ..moveTo(c, 0)
      ..lineTo(w - c - 18, 0)
      ..lineTo(w - c - 12, 5)
      ..lineTo(w - c, 5)
      ..lineTo(w, 5 + c)
      ..lineTo(w, h / 2 - 12)
      ..lineTo(w - 4, h / 2 - 8)
      ..lineTo(w - 4, h / 2 + 8)
      ..lineTo(w, h / 2 + 12)
      ..lineTo(w, h - c)
      ..lineTo(w - c, h)
      ..lineTo(c + 18, h)
      ..lineTo(c + 12, h - 5)
      ..lineTo(c, h - 5)
      ..lineTo(0, h - 5 - c)
      ..lineTo(0, h / 2 + 12)
      ..lineTo(4, h / 2 + 8)
      ..lineTo(4, h / 2 - 8)
      ..lineTo(0, h / 2 - 12)
      ..lineTo(0, c)
      ..close();

    // Fill 100% Solid Opaque Background
    final fillPaint = Paint()
      ..color = solidBackgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Boundary Frame Stroke Line
    final borderPaint = Paint()
      ..color = strokeColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, borderPaint);

    // 2. Top-Left Slanted Parallel Bars (///) - Matching Image Accents
    final barPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.fill;

    const double barW = 4.0;
    const double barH = 11.0;
    const double barX = 14.0;
    const double barY = 10.0;

    for (int i = 0; i < 3; i++) {
      final barPath = Path();
      final double xOffset = barX + (i * 7.5);
      barPath.moveTo(xOffset + 4, barY);
      barPath.lineTo(xOffset + 4 + barW, barY);
      barPath.lineTo(xOffset + barW, barY + barH);
      barPath.lineTo(xOffset, barY + barH);
      barPath.close();
      canvas.drawPath(barPath, barPaint);
    }

    // 3. Top-Right Directional Chevrons (<<) - Matching Image Accents
    final chevronPaint = Paint()
      ..color = strokeColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final double chevX = w - 34.0;
    const double chevY = 12.0;
    for (int i = 0; i < 2; i++) {
      final double cx = chevX + (i * 8.0);
      final chevPath = Path()
        ..moveTo(cx + 6, chevY)
        ..lineTo(cx, chevY + 5)
        ..lineTo(cx + 6, chevY + 10);
      canvas.drawPath(chevPath, chevronPaint);
    }

    // 4. Bottom-Left Target Crosshair Reticles (+ + / + +) - Matching Image Accents
    final reticlePaint = Paint()
      ..color = strokeColor.withOpacity(0.85)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    const double retX = 16.0;
    final double retY = h - 26.0;
    const double crossLen = 3.5;

    for (int row = 0; row < 2; row++) {
      for (int col = 0; col < 2; col++) {
        final double rx = retX + (col * 10.0);
        final double ry = retY + (row * 10.0);
        canvas.drawLine(Offset(rx, ry - crossLen), Offset(rx, ry + crossLen), reticlePaint);
        canvas.drawLine(Offset(rx - crossLen, ry), Offset(rx + crossLen, ry), reticlePaint);
      }
    }

    // 5. Vertical Side Vent Hatch Ticks - Matching Right Edge of Image
    final hatchPaint = Paint()
      ..color = strokeColor.withOpacity(0.75)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final double hatchX = w - 8.0;
    final double hatchStartY = h / 2 - 14.0;
    for (int i = 0; i < 5; i++) {
      final double hy = hatchStartY + (i * 7.0);
      canvas.drawLine(Offset(hatchX, hy), Offset(hatchX + 4, hy - 4), hatchPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OpaqueStatCardPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.solidBackgroundColor != solidBackgroundColor ||
        oldDelegate.isSolidFill != isSolidFill ||
        oldDelegate.isLightSolidFill != isLightSolidFill;
  }
}
