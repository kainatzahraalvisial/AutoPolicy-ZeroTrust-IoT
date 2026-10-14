import 'package:flutter/material.dart';

/// CyberStencilHeroTitle
///
/// Replicates the visual style of the reference image:
/// - Blocky, ultra-heavy geometric letterforms
/// - 45-degree diagonal stencil cuts across the stems
/// - Chamfered outer and inner corners
/// - Accompanying technical HUD elements:
///   * Top index tags (`// [ SYS.01 ] · ZERO-TRUST CORE`)
///   * Diagonal hash marks (`//////` chevron vent array)
///   * Mechanical crossbars & datum rails with technical status pills
class CyberStencilHeroTitle extends StatelessWidget {
  final String firstLine;
  final String secondLine;
  final Color? primaryColor;
  final Color? accentColor;
  final Color? hudColor;
  final double? maxWidth;

  const CyberStencilHeroTitle({
    super.key,
    this.firstLine = 'EVERY DEVICE',
    this.secondLine = 'ZERO TRUST',
    this.primaryColor,
    this.accentColor,
    this.hudColor,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primary =
        primaryColor ?? (isDark ? Colors.white : const Color(0xFF141812));
    final accent = accentColor ??
        (isDark ? const Color(0xFFDCFF33) : const Color(0xFF6B8A0E));
    final hud = hudColor ??
        (isDark ? const Color(0xFF00E5FF) : const Color(0xFF009BB0));

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = maxWidth ?? constraints.maxWidth;
        // Target aspect ratio for 2 lines + hashes
        final double designWidth = [
          680.0,
          _CyberStencilTitlePainter.measureLine(firstLine.toUpperCase()),
          _CyberStencilTitlePainter.measureLine(secondLine.toUpperCase())
        ].reduce((a, b) => a > b ? a : b);
        const double designHeight = 175.0;

        final double scale = (availableWidth / designWidth).clamp(0.0, 1.45);
        final double renderWidth = designWidth * scale;
        final double renderHeight = designHeight * scale;

        return Semantics(
          label: '$firstLine $secondLine',
          child: SizedBox(
            width: renderWidth,
            height: renderHeight,
            child: CustomPaint(
              size: Size(renderWidth, renderHeight),
              painter: _CyberStencilTitlePainter(
                firstLine: firstLine.toUpperCase(),
                secondLine: secondLine.toUpperCase(),
                primaryColor: primary,
                accentColor: accent,
                hudColor: hud,
                isDark: isDark,
                scale: scale,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CyberStencilTitlePainter extends CustomPainter {
  final String firstLine;
  final String secondLine;
  final Color primaryColor;
  final Color accentColor;
  final Color hudColor;
  final bool isDark;
  final double scale;

  _CyberStencilTitlePainter({
    required this.firstLine,
    required this.secondLine,
    required this.primaryColor,
    required this.accentColor,
    required this.hudColor,
    required this.isDark,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(scale, scale);

    // 1. FIRST LINE (e.g. "EVERY DEVICE") - Painted in primary color
    const double line1Y = 4.0;
    _drawLineOfGlyphs(
      canvas: canvas,
      text: firstLine,
      startY: line1Y,
      color: primaryColor,
      hasGlow: false,
      glowColor: primaryColor.withOpacity(0.35),
    );

    // 2. SECOND LINE (e.g. "ZERO TRUST") - Painted in accent neon color
    const double line2Y = 82.0;
    _drawLineOfGlyphs(
      canvas: canvas,
      text: secondLine,
      startY: line2Y,
      color: accentColor,
      hasGlow: false,
      glowColor: accentColor.withOpacity(0.55),
    );

    // 3. LOWER DIAGONAL HASH MARKS (//////) ONLY - All circled items removed
    const double hudY = 158.0;
    _drawLowerHudElements(canvas, hudY);

    canvas.restore();
  }

  void _drawLowerHudElements(Canvas canvas, double y) {
    // DIAGONAL HASH MARKS (//////) - Kept intact from reference image
    final hashPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    if (isDark) {
      final hashGlow = Paint()
        ..color = accentColor.withOpacity(0.4)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      _drawHashes(canvas, y, hashGlow);
    }
    _drawHashes(canvas, y, hashPaint);
  }

  void _drawHashes(Canvas canvas, double y, Paint paint) {
    const int count = 9;
    const double hashWidth = 5.0;
    const double hashHeight = 16.0;
    const double slant = 7.0;
    const double spacing = 13.0;

    for (int i = 0; i < count; i++) {
      final double x = 2.0 + (i * spacing);
      final path = Path()
        ..moveTo(x + slant, y)
        ..lineTo(x + slant + hashWidth, y)
        ..lineTo(x + hashWidth, y + hashHeight)
        ..lineTo(x, y + hashHeight)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  void _drawLineOfGlyphs({
    required Canvas canvas,
    required String text,
    required double startY,
    required Color color,
    required bool hasGlow,
    required Color glowColor,
  }) {
    const double glyphHeight = 68.0;
    const double baseGlyphWidth = 46.0;
    const double charSpacing = 9.0;
    const double wordSpacing = 24.0;

    double curX = 0.0;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    Paint? glowPaint;
    if (hasGlow) {
      glowPaint = Paint()
        ..color = glowColor
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    }

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      if (char == ' ') {
        curX += wordSpacing;
        continue;
      }

      final double glyphWidth = _getGlyphWidth(char, baseGlyphWidth);
      final path =
          _buildCyberGlyph(char, curX, startY, glyphWidth, glyphHeight);

      if (path != null) {
        if (glowPaint != null) {
          canvas.drawPath(path, glowPaint);
        }
        canvas.drawPath(path, fillPaint);
      } else {
        // Unmapped characters must remain readable rather than become blocks.
        final glyph = TextPainter(
          text: TextSpan(
              text: char,
              style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.w800,
                  fontSize: glyphHeight,
                  height: 1,
                  color: color)),
          textDirection: TextDirection.ltr,
        )..layout();
        canvas.save();
        canvas.translate(curX, startY);
        canvas.scale(glyphWidth / glyph.width, glyphHeight / glyph.height);
        glyph.paint(canvas, Offset.zero);
        canvas.restore();
        glyph.dispose();
      }

      curX += glyphWidth + charSpacing;
    }
  }

  static double measureLine(String text) {
    var width = 0.0;
    for (final char in text.split('')) {
      width += char == ' ' ? 24.0 : _getGlyphWidth(char, 46.0) + 9.0;
    }
    return width;
  }

  static double _getGlyphWidth(String char, double baseWidth) {
    switch (char) {
      case '.':
        return baseWidth * .22;
      case 'I':
        return baseWidth * 0.44;
      case 'M':
      case 'W':
        return baseWidth * 1.25;
      case 'T':
      case 'Z':
      case 'E':
      case 'C':
      case 'O':
      case 'D':
        return baseWidth * 0.98;
      default:
        return baseWidth;
    }
  }

  /// Builds ultra-heavy geometric vector glyphs with 45° chamfered corners
  /// and 45° diagonal stencil cuts.
  Path? _buildCyberGlyph(String char, double x, double y, double w, double h) {
    final path = Path();
    final double stem = (h * 0.23).clamp(13.0, 17.0);
    final double c = (h * 0.19).clamp(10.0, 14.0); // 45° chamfer
    final double cut = 3.6; // 45° stencil slit width

    switch (char) {
      case 'C':
        // C with 45° outer chamfers and diagonal stencil cut across top bar
        // 1. Top bar with diagonal stencil split
        final topCutX = x + w * 0.46;
        path.moveTo(x + c, y);
        path.lineTo(topCutX, y);
        path.lineTo(topCutX - stem, y + stem);
        path.lineTo(x + stem, y + stem);
        path.lineTo(x + stem, y + h - stem);
        path.lineTo(x + w - stem, y + h - stem);
        path.lineTo(x + w, y + h - c);
        path.lineTo(x + w - c, y + h);
        path.lineTo(x + c, y + h);
        path.lineTo(x, y + h - c);
        path.lineTo(x, y + c);
        path.close();

        // Top right hook of C after stencil cut
        final topHook = Path()
          ..moveTo(topCutX + cut, y)
          ..lineTo(x + w - c, y)
          ..lineTo(x + w, y + c)
          ..lineTo(x + w, y + stem + 3)
          ..lineTo(x + w - stem, y + stem + 3)
          ..lineTo(x + w - stem, y + stem)
          ..lineTo(topCutX + cut - stem, y + stem)
          ..close();
        path.addPath(topHook, Offset.zero);
        return path;

      case 'Y':
        // Y with angled chamfers and diagonal stencil cut
        final midY = y + h * 0.52;
        final centerX = x + w * 0.5;

        // Left diagonal arm
        path.moveTo(x + c, y);
        path.lineTo(x + stem + 2, y);
        path.lineTo(centerX, midY);
        path.lineTo(centerX - stem * 0.7, midY);
        path.lineTo(x, y + c);
        path.close();

        // Right diagonal arm
        final rightArm = Path()
          ..moveTo(x + w - c, y)
          ..lineTo(x + w, y + c)
          ..lineTo(centerX + stem * 0.7, midY)
          ..lineTo(centerX, midY)
          ..lineTo(x + w - stem - 2, y)
          ..close();
        path.addPath(rightArm, Offset.zero);

        // Center vertical stem with diagonal cut
        final vStem = Path()
          ..moveTo(centerX - stem * 0.45, midY + cut)
          ..lineTo(centerX + stem * 0.45, midY + cut)
          ..lineTo(centerX + stem * 0.45, y + h - c)
          ..lineTo(centerX + stem * 0.45 - c, y + h)
          ..lineTo(centerX - stem * 0.45, y + h)
          ..close();
        path.addPath(vStem, Offset.zero);
        return path;

      case 'B':
        // B with chamfers and stencil split in bottom bowl
        // Main left vertical stem
        path.addRect(Rect.fromLTWH(x, y, stem, h));

        // Top bowl
        final topBowl = Path()
          ..moveTo(x + stem, y)
          ..lineTo(x + w - c, y)
          ..lineTo(x + w, y + c)
          ..lineTo(x + w, y + h * 0.48 - c)
          ..lineTo(x + w - c, y + h * 0.48)
          ..lineTo(x + stem, y + h * 0.48)
          ..lineTo(x + stem, y + h * 0.48 - stem * 0.7)
          ..lineTo(x + w - stem, y + h * 0.48 - stem * 0.7)
          ..lineTo(x + w - stem, y + stem)
          ..lineTo(x + stem, y + stem)
          ..close();
        path.addPath(topBowl, Offset.zero);

        // Bottom bowl with diagonal cut
        final botBowl = Path()
          ..moveTo(x + stem, y + h * 0.52)
          ..lineTo(x + w - c, y + h * 0.52)
          ..lineTo(x + w, y + h * 0.52 + c)
          ..lineTo(x + w, y + h - c - cut)
          ..lineTo(x + w - stem, y + h - stem - cut)
          ..lineTo(x + w - stem, y + h * 0.52 + stem * 0.7)
          ..lineTo(x + stem, y + h * 0.52 + stem * 0.7)
          ..close();
        path.addPath(botBowl, Offset.zero);

        final botLower = Path()
          ..moveTo(x + stem, y + h - stem)
          ..lineTo(x + w - stem - cut, y + h - stem)
          ..lineTo(x + w - c, y + h)
          ..lineTo(x + stem, y + h)
          ..close();
        path.addPath(botLower, Offset.zero);
        return path;

      case 'E':
        // E: Left vertical stem, top bar, middle bar with 45° diagonal cut, bottom bar
        path.moveTo(x, y + c);
        path.lineTo(x + c, y);
        path.lineTo(x + w - c, y);
        path.lineTo(x + w, y + c);
        path.lineTo(x + w, y + stem);
        path.lineTo(x + stem, y + stem);
        path.lineTo(x + stem, y + h - stem);
        path.lineTo(x + w, y + h - stem);
        path.lineTo(x + w, y + h - c);
        path.lineTo(x + w - c, y + h);
        path.lineTo(x + c, y + h);
        path.lineTo(x, y + h - c);
        path.close();

        // Middle bar with 45° diagonal cut
        final midYStart = y + h * 0.5 - stem * 0.4;
        final midYEnd = midYStart + stem * 0.8;
        final cutX = x + stem + (w - stem) * 0.45;

        // Middle bar left fragment
        final midLeft = Path()
          ..moveTo(x + stem, midYStart)
          ..lineTo(cutX, midYStart)
          ..lineTo(cutX - stem * 0.6, midYEnd)
          ..lineTo(x + stem, midYEnd)
          ..close();
        path.addPath(midLeft, Offset.zero);

        // Middle bar right fragment
        final midRight = Path()
          ..moveTo(cutX + cut, midYStart)
          ..lineTo(x + w * 0.82, midYStart)
          ..lineTo(x + w * 0.82, midYEnd)
          ..lineTo(cutX + cut - stem * 0.6, midYEnd)
          ..close();
        path.addPath(midRight, Offset.zero);
        return path;

      case 'R':
        // R: Left stem, top bowl with 45° cut, angled right leg with chamfered foot
        path.addRect(Rect.fromLTWH(x, y, stem, h));

        // Top loop with diagonal cut
        final rLoop = Path()
          ..moveTo(x + stem, y)
          ..lineTo(x + w - c, y)
          ..lineTo(x + w, y + c)
          ..lineTo(x + w, y + h * 0.48 - c)
          ..lineTo(x + w - c, y + h * 0.48)
          ..lineTo(x + stem, y + h * 0.48)
          ..lineTo(x + stem, y + h * 0.48 - stem * 0.7)
          ..lineTo(x + w - stem, y + h * 0.48 - stem * 0.7)
          ..lineTo(x + w - stem, y + stem)
          ..lineTo(x + stem, y + stem)
          ..close();
        path.addPath(rLoop, Offset.zero);

        // Angled right leg with diagonal cut & chamfered foot
        final leg = Path()
          ..moveTo(x + stem + 6, y + h * 0.48 + cut)
          ..lineTo(x + stem + 6 + stem * 0.8, y + h * 0.48 + cut)
          ..lineTo(x + w, y + h - c)
          ..lineTo(x + w - c, y + h)
          ..lineTo(x + w - stem, y + h)
          ..close();
        path.addPath(leg, Offset.zero);
        return path;

      case 'V':
        // V: Ultra heavy chamfered V with diagonal cut on right stem
        final apexX = x + w * 0.5;
        // Left arm
        path.moveTo(x + c, y);
        path.lineTo(x + stem + 2, y);
        path.lineTo(apexX, y + h - c);
        path.lineTo(apexX - stem * 0.6, y + h);
        path.lineTo(x, y + c);
        path.close();

        // Right arm with diagonal cut
        final rightV = Path()
          ..moveTo(x + w - c, y)
          ..lineTo(x + w, y + c)
          ..lineTo(apexX + stem * 0.6 + cut, y + h * 0.5)
          ..lineTo(apexX + cut, y + h * 0.5)
          ..lineTo(x + w - stem - 2, y)
          ..close();
        path.addPath(rightV, Offset.zero);

        final rightVBottom = Path()
          ..moveTo(apexX + stem * 0.6, y + h * 0.5 + cut)
          ..lineTo(apexX + stem * 0.6, y + h)
          ..lineTo(apexX, y + h - c)
          ..lineTo(apexX, y + h * 0.5 + cut)
          ..close();
        path.addPath(rightVBottom, Offset.zero);
        return path;

      case 'F':
        path.addRect(Rect.fromLTWH(x, y, stem, h));
        path.addRect(Rect.fromLTWH(x, y, w, stem));
        path.addRect(Rect.fromLTWH(x, y + h * .42, w * .82, stem * .85));
        return path;

      case 'M':
        path.addPolygon([
          Offset(x, y + h),
          Offset(x, y),
          Offset(x + stem * .85, y),
          Offset(x + w * .5, y + h * .43),
          Offset(x + w - stem * .85, y),
          Offset(x + w, y),
          Offset(x + w, y + h),
          Offset(x + w - stem * .85, y + h),
          Offset(x + w - stem * .85, y + h * .30),
          Offset(x + w * .5, y + h * .70),
          Offset(x + stem * .85, y + h * .30),
          Offset(x + stem * .85, y + h),
        ], true);
        return path;

      case 'D':
        path.fillType = PathFillType.evenOdd;
        path.addPolygon([
          Offset(x, y),
          Offset(x + w - c, y),
          Offset(x + w, y + c),
          Offset(x + w, y + h - c),
          Offset(x + w - c, y + h),
          Offset(x, y + h),
        ], true);
        path.addRRect(RRect.fromRectAndRadius(
            Rect.fromLTRB(
                x + stem * .8, y + stem, x + w - stem * .75, y + h - stem),
            Radius.circular(c * .4)));
        return path;

      case 'I':
        // Centered solid block with chamfers and stencil slice
        final ix = x + (w - stem) * 0.5;
        final mid = y + h * 0.5;
        path.moveTo(ix, y + c);
        path.lineTo(ix + c, y);
        path.lineTo(ix + stem, y);
        path.lineTo(ix + stem, mid - cut * 0.5);
        path.lineTo(ix, mid - cut * 0.5 + stem * 0.6);
        path.close();

        final iBot = Path()
          ..moveTo(ix + stem, mid + cut * 0.5)
          ..lineTo(ix + stem, y + h);
        iBot.lineTo(ix + stem - c, y + h);
        iBot.lineTo(ix, y + h - c);
        iBot.lineTo(ix, mid + cut * 0.5 + stem * 0.6);
        iBot.close();
        path.addPath(iBot, Offset.zero);
        return path;

      case 'Z':
        // Z with chamfered top/bottom and diagonal stencil cut
        path.moveTo(x + c, y);
        path.lineTo(x + w, y);
        path.lineTo(x + w, y + stem);
        path.lineTo(x + stem * 1.5, y + stem);
        path.lineTo(x, y + h - stem);
        path.lineTo(x, y + h);
        path.lineTo(x + w - c, y + h);
        path.lineTo(x + w, y + h - c);
        path.lineTo(x + w, y + h - stem);
        path.lineTo(x + stem, y + h - stem);
        path.lineTo(x + w - stem * 0.5, y + stem * 1.5);
        path.lineTo(x + w - stem * 0.5, y + stem);
        path.lineTo(x + c, y);
        path.close();
        return path;

      case 'O':
        // A generous, genuinely transparent counter survives mobile scaling.
        final wall = w * .23;
        final outer = Path()
          ..moveTo(x + c, y)
          ..lineTo(x + w - c, y)
          ..lineTo(x + w, y + c)
          ..lineTo(x + w, y + h - c)
          ..lineTo(x + w - c, y + h)
          ..lineTo(x + c, y + h)
          ..lineTo(x, y + h - c)
          ..lineTo(x, y + c)
          ..close();
        final inner = Path()
          ..addRRect(RRect.fromRectAndRadius(
              Rect.fromLTRB(x + wall, y + stem, x + w - wall, y + h - stem),
              Radius.circular(w * .10)));
        return outer
          ..fillType = PathFillType.evenOdd
          ..addPath(inner, Offset.zero);

      case 'P':
        path.fillType = PathFillType.evenOdd;
        path.moveTo(x, y);
        path.lineTo(x + w - c, y);
        path.lineTo(x + w, y + c);
        path.lineTo(x + w, y + h * .53 - c);
        path.lineTo(x + w - c, y + h * .53);
        path.lineTo(x + stem, y + h * .53);
        path.lineTo(x + stem, y + h);
        path.lineTo(x, y + h);
        path.close();
        path.addRect(Rect.fromLTRB(x + stem, y + stem * .75, x + w - stem * .65,
            y + h * .53 - stem * .7));
        return path;

      case 'N':
        path.addRect(Rect.fromLTWH(x, y, stem * .8, h));
        path.addRect(Rect.fromLTWH(x + w - stem * .8, y, stem * .8, h));
        path.addPolygon([
          Offset(x + stem * .6, y),
          Offset(x + stem * 1.4, y),
          Offset(x + w - stem * .6, y + h),
          Offset(x + w - stem * 1.4, y + h)
        ], true);
        return path;

      case 'A':
        path.addPolygon([
          Offset(x, y + h),
          Offset(x + w * .30, y),
          Offset(x + w * .70, y),
          Offset(x + w, y + h),
          Offset(x + w - stem * .8, y + h),
          Offset(x + w * .5, y + stem),
          Offset(x + stem * .8, y + h)
        ], true);
        path.addRect(Rect.fromLTWH(
            x + stem * .7, y + h * .59, w - stem * 1.4, stem * .7));
        return path;

      case '.':
        return Path()..addRect(Rect.fromLTWH(x, y + h - w, w, w));

      case 'T':
        // T: Top bar with chamfers, center vertical stem with 45° cut
        final tx = x + (w - stem) * 0.5;
        path.moveTo(x + c, y);
        path.lineTo(x + w - c, y);
        path.lineTo(x + w, y + c);
        path.lineTo(x + w, y + stem);
        path.lineTo(tx + stem, y + stem);
        path.lineTo(tx + stem, y + h * 0.5);
        path.lineTo(tx, y + h * 0.5 + stem * 0.6);
        path.lineTo(tx, y + stem);
        path.lineTo(x, y + stem);
        path.lineTo(x, y + c);
        path.close();

        final tBot = Path()
          ..moveTo(tx + stem, y + h * 0.5 + cut)
          ..lineTo(tx + stem, y + h)
          ..lineTo(tx + stem - c, y + h)
          ..lineTo(tx, y + h - c)
          ..lineTo(tx, y + h * 0.5 + cut + stem * 0.6)
          ..close();
        path.addPath(tBot, Offset.zero);
        return path;

      case 'U':
        // U: Left and right vertical stems, bottom connector with chamfers
        path.moveTo(x, y);
        path.lineTo(x + stem, y);
        path.lineTo(x + stem, y + h - stem);
        path.lineTo(x + w - stem, y + h - stem);
        path.lineTo(x + w - stem, y);
        path.lineTo(x + w, y);
        path.lineTo(x + w, y + h - c);
        path.lineTo(x + w - c, y + h);
        path.lineTo(x + c, y + h);
        path.lineTo(x, y + h - c);
        path.close();
        return path;

      case 'S':
        // S: Blocky chamfered S with 45° cut in the middle
        path.moveTo(x + c, y);
        path.lineTo(x + w, y);
        path.lineTo(x + w, y + stem);
        path.lineTo(x + stem, y + stem);
        path.lineTo(x + stem, y + h * 0.48);
        path.lineTo(x + w - c, y + h * 0.48);
        path.lineTo(x + w, y + h * 0.48 + c);
        path.lineTo(x + w, y + h);
        path.lineTo(x + c, y + h);
        path.lineTo(x, y + h - c);
        path.lineTo(x, y + h - stem);
        path.lineTo(x + w - stem, y + h - stem);
        path.lineTo(x + w - stem, y + h * 0.54);
        path.lineTo(x + c, y + h * 0.54);
        path.lineTo(x, y + h * 0.54 - c);
        path.lineTo(x, y + c);
        path.close();
        return path;

      default:
        return null;
    }
  }

  @override
  bool shouldRepaint(_CyberStencilTitlePainter old) =>
      old.firstLine != firstLine ||
      old.secondLine != secondLine ||
      old.primaryColor != primaryColor ||
      old.accentColor != accentColor ||
      old.scale != scale;
}
