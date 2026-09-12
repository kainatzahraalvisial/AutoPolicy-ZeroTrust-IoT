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
    // 6 Exact Swatch Colors from user image in exact sequence:
    if (val == const Color(0xFFFFEDA8).value || val == const Color(0xFFFFE997).value || val == const Color(0xFFC5C764).value || val == const Color(0xFFFDFDC9).value) {
      return const Color(0xFFFFEDA8); // 1. #FFEDA8 (Pale Cream Yellow)
    } else if (val == const Color(0xFFC4E326).value || val == const Color(0xFFC4E320).value || val == const Color(0xFF5DD62C).value) {
      return const Color(0xFFC4E326); // 2. #C4E326 (Bright Neon Lime-Green)
    } else if (val == const Color(0xFFB1A9DA).value || val == const Color(0xFFA88AED).value) {
      return const Color(0xFFB1A9DA); // 3. #B1A9DA (Pastel Lavender)
    } else if (val == const Color(0xFF80A416).value || val == const Color(0xFF337418).value) {
      return const Color(0xFF80A416); // 4. #80A416 (Olive Green)
    } else if (val == const Color(0xFF9D8DF1).value || val == const Color(0xFF9D4EDD).value) {
      return const Color(0xFF9D8DF1); // 5. #9D8DF1 (Vibrant Light Purple)
    } else if (val == const Color(0xFF810100).value || val == const Color(0xFFB91C1D).value || val == const Color(0xFFDF2531).value) {
      return const Color(0xFF810100); // 6. #810100 (Deep Crimson Red)
    }
    return borderColor;
  }

  bool get _isLightSolidFill {
    final int val = _solidBgColor.value;
    if (val == const Color(0xFFFFEDA8).value ||
        val == const Color(0xFFC4E326).value ||
        val == const Color(0xFFB1A9DA).value ||
        val == const Color(0xFF9D8DF1).value) {
      return true; // Light swatches need dark, crisp typography
    }
    return _solidBgColor.computeLuminance() > 0.40;
  }

  bool get _isRedThreatCard {
    final int val = _solidBgColor.value;
    return isAlert || val == const Color(0xFF810100).value || val == const Color(0xFFB91C1D).value;
  }

  bool get _isSolidFill {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final Color titleColor = _isLightSolidFill ? const Color(0xFF0A0A0E) : const Color(0xFFFFFFFF);
    final Color valueColor = _isRedThreatCard
        ? const Color(0xFFFFEA00) // Bright Yellowish color for threat amount on red cards
        : (_isLightSolidFill ? const Color(0xFF050A07) : const Color(0xFFFFFFFF));
    final Color subColor = _isRedThreatCard
        ? const Color(0xFFFFD54F)
        : (_isLightSolidFill ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0));
    final Color accentColor = _isLightSolidFill ? const Color(0xFF050A07) : const Color(0xFFFFFFFF);

    Widget cardContent = CustomPaint(
      painter: _OpaqueStatCardPainter(
        borderColor: borderColor,
        solidBackgroundColor: _solidBgColor,
        isSolidFill: _isSolidFill,
        isLightSolidFill: _isLightSolidFill,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 20, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Title & Icon with right padding so it never collides with chevrons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 28.0),
                    child: Text(
                      title.toUpperCase(),
                      style: GoogleFonts.barlow(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                        letterSpacing: 0.6,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 4),
                  Icon(icon, color: accentColor, size: 16),
                ],
              ],
            ),
            const SizedBox(height: 4),

            // Middle Row: Big Numerical Value & Subtitle (Clean layout with zero symbol overlap)
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: GoogleFonts.barlow(
                    fontSize: 28,
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
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    sub,
                    style: GoogleFonts.barlow(
                      fontSize: 11.5,
                      color: subColor,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Bottom Row: Corner Tag
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
                      color: accentColor.withOpacity(0.85),
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

    // Dark cyber stroke - NEVER white boundary!
    final Color strokeColor = isLightSolidFill
        ? const Color(0xFF0F1410)
        : const Color(0xFF140505);

    // Decorative symbol accent color
    final Color symbolColor = isLightSolidFill
        ? const Color(0xFF0F1410).withOpacity(0.70)
        : const Color(0xFFFFFFFF).withOpacity(0.70);

    // 1. Armor HUD Notched Polygon Boundary Path
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

    // Fill 100% Solid Opaque Background with swatch color
    final fillPaint = Paint()
      ..color = solidBackgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Boundary Frame Stroke Line: Dark Cyber Frame (NO WHITE BOUNDARY)
    final borderPaint = Paint()
      ..color = strokeColor
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, borderPaint);

    // 2. Top-Left Slanted Parallel Bars (///) - Sits neatly above title
    final barPaint = Paint()
      ..color = symbolColor
      ..style = PaintingStyle.fill;

    const double barW = 3.0;
    const double barH = 8.0;
    const double barX = 14.0;
    const double barY = 8.0;

    for (int i = 0; i < 3; i++) {
      final barPath = Path();
      final double xOffset = barX + (i * 6.0);
      barPath.moveTo(xOffset + 3, barY);
      barPath.lineTo(xOffset + 3 + barW, barY);
      barPath.lineTo(xOffset + barW, barY + barH);
      barPath.lineTo(xOffset, barY + barH);
      barPath.close();
      canvas.drawPath(barPath, barPaint);
    }

    // 3. Top-Right Directional Chevrons (<<)
    final chevronPaint = Paint()
      ..color = symbolColor
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final double chevX = w - 28.0;
    const double chevY = 9.0;
    for (int i = 0; i < 2; i++) {
      final double cx = chevX + (i * 7.0);
      final chevPath = Path()
        ..moveTo(cx + 5, chevY)
        ..lineTo(cx, chevY + 4)
        ..lineTo(cx + 5, chevY + 8);
      canvas.drawPath(chevPath, chevronPaint);
    }

    // 4. Vertical Side Vent Hatch Ticks on Right Edge
    final hatchPaint = Paint()
      ..color = symbolColor.withOpacity(0.5)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final double hatchX = w - 6.0;
    final double hatchStartY = h / 2 - 10.0;
    for (int i = 0; i < 4; i++) {
      final double hy = hatchStartY + (i * 6.0);
      canvas.drawLine(Offset(hatchX, hy), Offset(hatchX + 3, hy - 3), hatchPaint);
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
