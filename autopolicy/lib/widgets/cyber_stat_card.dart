import 'cyber_hud_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';

/// Reusable Opaque Cyber Stat/Number Card matching user swatches & HUD frame design
/// Features:
/// - Crisp 1.6px contrasting HUD boundary stroke frame
/// - Rich 100% solid opaque background fill
/// - Top-Right notched chamfer polygon with « chevrons
/// - Top-Left slanted parallel bars (///)
/// - Vertical side vent tick marks on right edge
class CyberStatCard extends ConsumerWidget {
  final String title;
  final String value;
  final String sub;
  final IconData? icon;
  final Color borderColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final String? tag;
  final bool isAlert;
  final bool compact;

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
    this.compact = false,
  });

  Color _resolveSolidBgColor(bool isDarkMode) {
    if (backgroundColor != null) return backgroundColor!;
    final int val = borderColor.value;

    // Threat Card / Alert is ALWAYS Red #D82734 at the end
    if (isAlert ||
        val == const Color(0xFFD82734).value ||
        val == const Color(0xFF810100).value ||
        val == const Color(0xFFB91C1D).value ||
        val == const Color(0xFFDF2531).value ||
        tag == 'H22' ||
        tag == '//22' ||
        tag == 'E06' ||
        tag == 'M06' ||
        tag == 'L04') {
      return const Color(0xFFD82734);
    }

    if (!isDarkMode) {
      // Light Theme Sequence:
      // 1. #FFF9E1
      if (val == const Color(0xFFFFF9E1).value ||
          val == const Color(0xFFFFEDA8).value ||
          val == const Color(0xFFFFE997).value ||
          val == const Color(0xFFC5C764).value ||
          val == const Color(0xFFFDFDC9).value ||
          tag == 'H17' ||
          tag == '//17' ||
          tag == 'E01' ||
          tag == 'M01' ||
          tag == 'L01') {
        return const Color(0xFFFFF9E1);
      }
      // 2. #EBECCC
      if (val == const Color(0xFFEBECCC).value ||
          val == const Color(0xFFC4E326).value ||
          val == const Color(0xFFC4E320).value ||
          val == const Color(0xFF5DD62C).value ||
          tag == 'H18' ||
          tag == '//18' ||
          tag == 'E02' ||
          tag == 'M02' ||
          tag == 'L02') {
        return const Color(0xFFEBECCC);
      }
      // 3. #CDD4B2
      if (val == const Color(0xFFCDD4B2).value ||
          val == const Color(0xFFDCA278).value ||
          val == const Color(0xFFB1A9DA).value ||
          val == const Color(0xFFA88AED).value ||
          tag == 'H19' ||
          tag == '//19' ||
          tag == 'E03' ||
          tag == 'M03' ||
          tag == 'L03') {
        if (val == const Color(0xFFDCA278).value || tag == 'L03') {
          return const Color(0xFFDCA278);
        }
        return const Color(0xFFCDD4B2);
      }
      // 4. #D4C9D8
      if (val == const Color(0xFFD4C9D8).value ||
          val == const Color(0xFF80A416).value ||
          val == const Color(0xFF337418).value ||
          tag == 'H20' ||
          tag == '//20' ||
          tag == 'E04' ||
          tag == 'M04') {
        return const Color(0xFFD4C9D8);
      }
      // 5. #B8A9C1
      if (val == const Color(0xFFB8A9C1).value ||
          val == const Color(0xFF9D8DF1).value ||
          val == const Color(0xFF9D4EDD).value ||
          tag == 'H21' ||
          tag == '//21' ||
          tag == 'E05' ||
          tag == 'M05') {
        return const Color(0xFFB8A9C1);
      }
      return borderColor;
    } else {
      // Dark Theme Sequence matching user image:
      // 1. #FFEDA8 (Cream Yellow)
      if (val == const Color(0xFFFFF9E1).value ||
          val == const Color(0xFFFFEDA8).value ||
          val == const Color(0xFFFFE997).value ||
          val == const Color(0xFFC5C764).value ||
          val == const Color(0xFFFDFDC9).value ||
          tag == 'H17' ||
          tag == '//17' ||
          tag == 'E01' ||
          tag == 'M01' ||
          tag == 'L01') {
        return const Color(0xFFFFEDA8);
      }
      // 2. #C4E326 (Bright Neon Lime-Green)
      if (val == const Color(0xFFEBECCC).value ||
          val == const Color(0xFFC4E326).value ||
          val == const Color(0xFFC4E320).value ||
          val == const Color(0xFF5DD62C).value ||
          tag == 'H18' ||
          tag == '//18' ||
          tag == 'E02' ||
          tag == 'M02' ||
          tag == 'L02') {
        return const Color(0xFFC4E326);
      }
      // 3. #B1A9DA (Pastel Lavender)
      if (val == const Color(0xFFCDD4B2).value ||
          val == const Color(0xFFDCA278).value ||
          val == const Color(0xFFB1A9DA).value ||
          val == const Color(0xFFA88AED).value ||
          tag == 'H19' ||
          tag == '//19' ||
          tag == 'E03' ||
          tag == 'M03' ||
          tag == 'L03') {
        return const Color(0xFFB1A9DA);
      }
      // 4. #80A416 (Olive Green)
      if (val == const Color(0xFFD4C9D8).value ||
          val == const Color(0xFF80A416).value ||
          val == const Color(0xFF337418).value ||
          tag == 'H20' ||
          tag == '//20' ||
          tag == 'E04' ||
          tag == 'M04') {
        return const Color(0xFF80A416);
      }
      // 5. #9D8DF1 (Vibrant Light Purple)
      if (val == const Color(0xFFB8A9C1).value ||
          val == const Color(0xFF9D8DF1).value ||
          val == const Color(0xFF9D4EDD).value ||
          tag == 'H21' ||
          tag == '//21' ||
          tag == 'E05' ||
          tag == 'M05') {
        return const Color(0xFF9D8DF1);
      }
      return borderColor;
    }
  }

  bool _isLightSolidFill(Color bg) {
    final int val = bg.value;
    if (val == const Color(0xFFFFF9E1).value ||
        val == const Color(0xFFEBECCC).value ||
        val == const Color(0xFFCDD4B2).value ||
        val == const Color(0xFFD4C9D8).value ||
        val == const Color(0xFFB8A9C1).value ||
        val == const Color(0xFFFFEDA8).value ||
        val == const Color(0xFFC4E326).value ||
        val == const Color(0xFFB1A9DA).value ||
        val == const Color(0xFF9D8DF1).value) {
      return true;
    }
    return bg.computeLuminance() > 0.38;
  }

  bool _isRedThreatCard(Color bg) {
    final int val = bg.value;
    return isAlert ||
        val == const Color(0xFFD82734).value ||
        val == const Color(0xFF810100).value ||
        val == const Color(0xFFB91C1D).value ||
        tag == 'H22' ||
        tag == '//22';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider);
    final Color solidBg = _resolveSolidBgColor(isDarkMode);
    final bool isLight = _isLightSolidFill(solidBg);
    final bool isRedThreat = _isRedThreatCard(solidBg);

    final Color titleColor =
        isLight ? const Color(0xFF0A0A0E) : const Color(0xFFFFFFFF);
    final Color valueColor = isRedThreat
        ? const Color(0xFFFFEA00)
        : (isLight ? const Color(0xFF050A07) : const Color(0xFFFFFFFF));
    final Color subColor = isRedThreat
        ? const Color(0xFFFFD54F)
        : (isLight ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0));
    final Color accentColor =
        isLight ? const Color(0xFF050A07) : const Color(0xFFFFFFFF);

    Widget cardContent = CustomPaint(
      painter: _OpaqueStatCardPainter(
        borderColor: borderColor,
        solidBackgroundColor: solidBg,
        isSolidFill: true,
        isLightSolidFill: isLight,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Title & clearance for decorative corner marks
            Row(
              children: [
                const SizedBox(width: 22), // Space for /// bars
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: GoogleFonts.barlow(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 4),
                  Icon(icon, color: accentColor, size: 14),
                ],
                const SizedBox(width: 18), // Space for « chevrons
              ],
            ),

            // Middle: Big Numerical Value & Subtitle
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: GoogleFonts.barlow(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: valueColor,
                      letterSpacing: 0.5,
                      shadows: isRedThreat
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFFEA00).withOpacity(0.5),
                                blurRadius: 10,
                              )
                            ]
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  maxLines: 1,
                  style: GoogleFonts.barlow(
                    fontSize: 10.5,
                    color: subColor,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),

            // Bottom Row: Corner Tag
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (tag != null)
                  Flexible(
                    child: Text(
                      tag!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        color: accentColor.withOpacity(0.85),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return DashboardCardLift(
          child: InkWell(
        onTap: onTap,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: cardContent,
      ));
    }

    return DashboardCardLift(child: cardContent);
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
    const double c = 14.0;

    final Color strokeColor =
        isLightSolidFill ? const Color(0xFF0F1410) : const Color(0xFF140505);
    final Color symbolColor = isLightSolidFill
        ? const Color(0xFF0F1410).withOpacity(0.70)
        : const Color(0xFFFFFFFF).withOpacity(0.70);

    // Armor HUD Notched Polygon Boundary Path
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

    // Solid Background Fill
    canvas.drawPath(
      path,
      Paint()
        ..color = solidBackgroundColor
        ..style = PaintingStyle.fill,
    );

    // Dark Cyber Stroke Frame
    canvas.drawPath(
      path,
      Paint()
        ..color = strokeColor
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke,
    );

    // 1. Top-Left Slanted Parallel Bars (///)
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

    // 2. Top-Right Directional Chevrons (<<)
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

    // 3. Vertical Side Vent Hatch Ticks on Right Edge
    final hatchPaint = Paint()
      ..color = symbolColor.withOpacity(0.50)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final double hatchX = w - 6.0;
    final double hatchStartY = h / 2 - 10.0;
    for (int i = 0; i < 4; i++) {
      final double hy = hatchStartY + (i * 6.0);
      canvas.drawLine(
          Offset(hatchX, hy), Offset(hatchX + 3, hy - 3), hatchPaint);
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
