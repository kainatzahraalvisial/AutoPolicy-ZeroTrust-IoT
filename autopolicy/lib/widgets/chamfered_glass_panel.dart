import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ChamferedGlassPanel extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double chamferLarge;
  final double chamferSmall;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const ChamferedGlassPanel({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.chamferLarge = 70.0,
    this.chamferSmall = 20.0,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Frosted Blur layer
          Positioned.fill(
            child: ClipPath(
              clipper: ChamferedClipper(
                chamferLarge: chamferLarge,
                chamferSmall: chamferSmall,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF070B1E).withOpacity(0.55),
                        const Color(0xFF0F1532).withOpacity(0.35),
                        const Color(0xFF050818).withOpacity(0.65),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Custom Painted Borders, Glowing Outlines and Tactical Metallic Accents
          Positioned.fill(
            child: CustomPaint(
              painter: ChamferedPanelPainter(
                chamferLarge: chamferLarge,
                chamferSmall: chamferSmall,
                borderColor: CyberColors.neonCyan,
                glowColor: Colors.blueAccent,
              ),
            ),
          ),

          // The Content
          ClipPath(
            clipper: ChamferedClipper(
              chamferLarge: chamferLarge,
              chamferSmall: chamferSmall,
            ),
            child: Container(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 36, vertical: 48),
              color: Colors.transparent,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class ChamferedClipper extends CustomClipper<Path> {
  final double chamferLarge;
  final double chamferSmall;

  ChamferedClipper({
    required this.chamferLarge,
    required this.chamferSmall,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final double w = size.width;
    final double h = size.height;

    // Start Top-Left (small chamfer notch)
    path.moveTo(0, chamferSmall);
    path.lineTo(chamferSmall, 0);

    // Top-Right (large chamfer notch)
    path.lineTo(w - chamferLarge, 0);
    path.lineTo(w, chamferLarge);

    // Bottom-Right (small chamfer notch)
    path.lineTo(w, h - chamferSmall);
    path.lineTo(w - chamferSmall, h);

    // Bottom-Left (large chamfer notch)
    path.lineTo(chamferLarge, h);
    path.lineTo(0, h - chamferLarge);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant ChamferedClipper oldClipper) {
    return oldClipper.chamferLarge != chamferLarge ||
        oldClipper.chamferSmall != chamferSmall;
  }
}

class ChamferedPanelPainter extends CustomPainter {
  final double chamferLarge;
  final double chamferSmall;
  final Color borderColor;
  final Color glowColor;

  ChamferedPanelPainter({
    required this.chamferLarge,
    required this.chamferSmall,
    required this.borderColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final path = Path();
    path.moveTo(0, chamferSmall);
    path.lineTo(chamferSmall, 0);
    path.lineTo(w - chamferLarge, 0);
    path.lineTo(w, chamferLarge);
    path.lineTo(w, h - chamferSmall);
    path.lineTo(w - chamferSmall, h);
    path.lineTo(chamferLarge, h);
    path.lineTo(0, h - chamferLarge);
    path.close();

    // 1. Draw heavy ambient outer shadow
    final shadowPaint = Paint()
      ..color = glowColor.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 30);
    canvas.drawPath(path, shadowPaint);

    // 2. Draw glass inner reflection highlights
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        center: const Alignment(-0.5, -0.6),
        radius: 1.2,
        colors: [
          const Color(0xFF00F5FF).withOpacity(0.04),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(path, fillPaint);

    // 3. Draw dual-gradient thin sharp border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          borderColor.withOpacity(0.6),
          borderColor.withOpacity(0.15),
          Colors.blueAccent.withOpacity(0.4),
          borderColor.withOpacity(0.7),
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(path, borderPaint);

    // 4. DRAW LEFT TACTICAL METALLIC CLIPS
    // Drawing 3 horizontal slats overlaying the left border at y: [80, 130, 180]
    final clipPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF2E395A),
          Color(0xFF13172E),
          Color(0xFF0D0F1D),
        ],
      ).createShader(Rect.fromLTWH(-50, 0, w + 100, h));

    final clipStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color(0xFF455588).withOpacity(0.8);

    final clipShadow = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    const double clipWidth = 8.0;
    const double clipHeight = 32.0;
    final List<double> leftClipYs = [90.0, 140.0, 190.0];

    for (var y in leftClipYs) {
      final clipPath = Path()
        ..moveTo(-clipWidth, y)
        ..lineTo(1.0, y)
        ..lineTo(1.0, y + clipHeight)
        ..lineTo(-clipWidth, y + clipHeight)
        ..lineTo(-clipWidth - 3, y + clipHeight - 5)
        ..lineTo(-clipWidth - 3, y + 5)
        ..close();

      // Shadow
      canvas.drawPath(clipPath.shift(const Offset(-1, 2)), clipShadow);
      // Slat fill
      canvas.drawPath(clipPath, clipPaint);
      // Slat stroke
      canvas.drawPath(clipPath, clipStroke);

      // Light glow indicator inside clips
      final microIndicator = Paint()
        ..color = borderColor.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(-clipWidth + 2, y + 8, 2, clipHeight - 16), microIndicator);
    }

    // 5. DRAW RIGHT BOTTOM NESTED VENTS/STEPS
    // In the image on the right/bottom-right there are 3 distinct stacked plates/steps
    final List<double> rightClipYs = [h - 190.0, h - 140.0, h - 90.0];
    const double ventWidth = 10.0;
    const double ventHeight = 34.0;

    for (var y in rightClipYs) {
      final ventPath = Path()
        ..moveTo(w - 1.0, y)
        ..lineTo(w + ventWidth, y)
        ..lineTo(w + ventWidth + 3, y + 5)
        ..lineTo(w + ventWidth + 3, y + ventHeight - 5)
        ..lineTo(w + ventWidth, y + ventHeight)
        ..lineTo(w - 1.0, y + ventHeight)
        ..close();

      // Shadow
      canvas.drawPath(ventPath.shift(const Offset(1, 2)), clipShadow);
      // Fill
      canvas.drawPath(ventPath, clipPaint);
      // Stroke
      canvas.drawPath(ventPath, clipStroke);

      // Tech detailing groove in the vent
      final groovePaint = Paint()
        ..color = Colors.black.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawLine(Offset(w + 3, y + 10), Offset(w + 3, y + ventHeight - 10), groovePaint);
    }
  }

  @override
  bool shouldRepaint(covariant ChamferedPanelPainter oldDelegate) {
    return oldDelegate.chamferLarge != chamferLarge ||
        oldDelegate.chamferSmall != chamferSmall ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.glowColor != glowColor;
  }
}
