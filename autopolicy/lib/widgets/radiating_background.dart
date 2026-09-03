import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class RadiatingBackground extends StatefulWidget {
  final Widget? child;

  const RadiatingBackground({super.key, this.child});

  @override
  State<RadiatingBackground> createState() => _RadiatingBackgroundState();
}

class _RadiatingBackgroundState extends State<RadiatingBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark Base Canvas
        Positioned.fill(
          child: Container(
            color: CyberColors.backgroundDark,
          ),
        ),

        // Glowing Core Ambient Gradient
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  Color(0xFF0F1E4A),
                  Color(0xFF070B18),
                  Color(0xFF02040A),
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),
        ),

        // Procedural Radiating Ribbons
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _RadiatingRibbonPainter(_controller.value),
              );
            },
          ),
        ),

        // Cyber Grid Overlay (Semi-transparent for technical depth)
        Positioned.fill(
          child: Opacity(
            opacity: 0.18,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage("https://pub-c0683416e9f24c08b4ef2183c51f0f4a.r2.dev/grid_pattern.png"), // optional fallback
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),
        ),

        // Optional scanlines
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.05),
                    Colors.transparent,
                    Colors.black.withOpacity(0.05),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Foreground content
        if (widget.child != null) Positioned.fill(child: widget.child!),
      ],
    );
  }
}

class _RadiatingRibbonPainter extends CustomPainter {
  final double progress;
  const _RadiatingRibbonPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final Offset center = Offset(cx, cy);

    final double maxRadius = math.sqrt(cx * cx + cy * cy) * 1.2;

    // Number of major metallic blades/ribbons
    const int ribbonCount = 28;
    final math.Random random = math.Random(1337); // Seeded for deterministic beautiful shapes

    for (int i = 0; i < ribbonCount; i++) {
      // Base angle + slow rotational drift
      final double driftDir = (i % 2 == 0) ? 1.0 : -1.0;
      final double baseAngle = (i * (2 * math.pi / ribbonCount)) + (progress * 2 * math.pi * 0.05 * driftDir);

      // Random jitter factors (using the seeded random)
      final double lengthFactor = 0.5 + (random.nextDouble() * 0.7); // Length of shard
      final double widthFactor = 0.3 + (random.nextDouble() * 0.8);  // Tapering width
      final double phaseShift = random.nextDouble() * math.pi;

      // Pulse brightness slowly
      final double opacityPulse = 0.45 + 0.25 * math.sin(progress * 2 * math.pi * 3 + phaseShift);

      // Draw thick 3D-like shaded blade
      _drawBlade(
        canvas,
        center,
        baseAngle,
        maxRadius * lengthFactor,
        28.0 * widthFactor,
        opacityPulse,
        i % 3, // Alternate gradient styles (cyan, blue, cobalt)
      );

      // Draw thin bright tech lines overlay
      if (i % 2 == 0) {
        _drawTechRay(
          canvas,
          center,
          baseAngle + 0.03,
          maxRadius * lengthFactor * 1.1,
          opacityPulse * 0.8,
        );
      }
    }

    // Centered neon light burst
    final coreGlow = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.45,
        colors: [
          const Color(0xFF00F5FF).withOpacity(0.25),
          const Color(0xFF0033FF).withOpacity(0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: cx * 0.5));
    canvas.drawCircle(center, cx * 0.5, coreGlow);
  }

  void _drawBlade(
    Canvas canvas,
    Offset center,
    double angle,
    double length,
    double baseWidth,
    double opacity,
    int styleIndex,
  ) {
    // Four-point blade polygon path
    final path = Path();
    
    // Starting slightly offset from the core to leave a dark center
    final double startOffset = 40.0;
    
    // Coordinates at start
    final double sx1 = center.dx + startOffset * math.cos(angle - 0.04);
    final double sy1 = center.dy + startOffset * math.sin(angle - 0.04);
    
    final double sx2 = center.dx + startOffset * math.cos(angle + 0.04);
    final double sy2 = center.dy + startOffset * math.sin(angle + 0.04);

    // Coordinates at mid point (bulge)
    final double midD = length * 0.45;
    final double mx1 = center.dx + midD * math.cos(angle - (baseWidth * 0.0006));
    final double my1 = center.dy + midD * math.sin(angle - (baseWidth * 0.0006));
    
    final double mx2 = center.dx + midD * math.cos(angle + (baseWidth * 0.0006));
    final double my2 = center.dy + midD * math.sin(angle + (baseWidth * 0.0006));

    // Coordinates at tip (tapered point)
    final double tx = center.dx + length * math.cos(angle);
    final double ty = center.dy + length * math.sin(angle);

    path.moveTo(sx1, sy1);
    path.lineTo(mx1, my1);
    path.lineTo(tx, ty);
    path.lineTo(mx2, my2);
    path.lineTo(sx2, sy2);
    path.close();

    // Metallic Gradient Colors
    List<Color> colors;
    if (styleIndex == 0) {
      // Cyan to Blue
      colors = [
        const Color(0xFF00F5FF).withOpacity(0.0),
        const Color(0xFF00BFFF).withOpacity(0.48 * opacity),
        const Color(0xFF0033CC).withOpacity(0.35 * opacity),
        const Color(0xFF050818).withOpacity(0.0),
      ];
    } else if (styleIndex == 1) {
      // Pure Royal Cobalt
      colors = [
        const Color(0xFF0055FF).withOpacity(0.0),
        const Color(0xFF0044FF).withOpacity(0.55 * opacity),
        const Color(0xFF0A0F35).withOpacity(0.25 * opacity),
        const Color(0xFF02040C).withOpacity(0.0),
      ];
    } else {
      // Bright Neon Indigo Sparkle
      colors = [
        const Color(0xFF00F5FF).withOpacity(0.0),
        const Color(0xFF00F5FF).withOpacity(0.60 * opacity),
        const Color(0xFF1E00FF).withOpacity(0.30 * opacity),
        Colors.transparent,
      ];
    }

    final bladePaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment(math.cos(angle - math.pi), math.sin(angle - math.pi)),
        end: Alignment(math.cos(angle), math.sin(angle)),
        colors: colors,
        stops: const [0.0, 0.35, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: length));

    canvas.drawPath(path, bladePaint);
  }

  void _drawTechRay(
    Canvas canvas,
    Offset center,
    double angle,
    double length,
    double opacity,
  ) {
    final double tx = center.dx + length * math.cos(angle);
    final double ty = center.dy + length * math.sin(angle);

    final rayPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        begin: Alignment(math.cos(angle - math.pi), math.sin(angle - math.pi)),
        end: Alignment(math.cos(angle), math.sin(angle)),
        colors: [
          const Color(0xFF00F5FF).withOpacity(0.0),
          const Color(0xFF00F5FF).withOpacity(0.85 * opacity),
          Colors.transparent,
        ],
        stops: const [0.1, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: length));

    canvas.drawLine(
      Offset(center.dx + 60 * math.cos(angle), center.dy + 60 * math.sin(angle)),
      Offset(tx, ty),
      rayPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RadiatingRibbonPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
