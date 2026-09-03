import 'dart:math' as math;
import 'package:flutter/material.dart';

class LiquidBubble {
  double xPercent;
  double yPercent;
  final double baseRadius;
  final double speedY;
  final double driftSpeed;
  final double driftRange;
  final double morphSpeed;
  final double morphAmplitude;
  final int morphFrequency;
  final List<Color> gradientColors;
  final Color shadowColor;
  final bool isForeground;

  double timeOffset = 0;
  double driftPhase = 0;

  LiquidBubble({
    required this.xPercent,
    required this.yPercent,
    required this.baseRadius,
    required this.speedY,
    required this.driftSpeed,
    required this.driftRange,
    required this.morphSpeed,
    required this.morphAmplitude,
    required this.morphFrequency,
    required this.gradientColors,
    required this.shadowColor,
    required this.isForeground,
  }) {
    timeOffset = math.Random().nextDouble() * 100;
    driftPhase = math.Random().nextDouble() * math.pi * 2;
  }

  void update(double dt) {
    timeOffset += dt * morphSpeed;
    driftPhase += dt * driftSpeed;
    
    // Float upwards slowly
    yPercent -= speedY * dt;
    if (yPercent < -0.2) {
      yPercent = 1.2; // Wrap around to bottom
      xPercent = math.Random().nextDouble();
    }
  }
}

class LiquidBubbleBackground extends StatefulWidget {
  final Widget child;

  const LiquidBubbleBackground({
    super.key,
    required this.child,
  });

  @override
  State<LiquidBubbleBackground> createState() => _LiquidBubbleBackgroundState();
}

class _LiquidBubbleBackgroundState extends State<LiquidBubbleBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  final List<LiquidBubble> _bubbles = [];
  
  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _initializeBubbles();
  }

  void _initializeBubbles() {
    final rand = math.Random();
    
    // Background layer bubbles (large, slow, floating behind)
    _bubbles.add(LiquidBubble(
      xPercent: 0.15,
      yPercent: 0.25,
      baseRadius: 100,
      speedY: 0.015,
      driftSpeed: 0.2,
      driftRange: 0.05,
      morphSpeed: 0.6,
      morphAmplitude: 8.0,
      morphFrequency: 4,
      gradientColors: [
        const Color(0xFF8B5CF6).withOpacity(0.4), // Chrome Violet
        const Color(0xFFEC4899).withOpacity(0.15), // Pink Glow
        const Color(0xFF06B6D4).withOpacity(0.3), // Cyan Glass
      ],
      shadowColor: const Color(0x33EC4899),
      isForeground: false,
    ));

    _bubbles.add(LiquidBubble(
      xPercent: 0.85,
      yPercent: 0.70,
      baseRadius: 140,
      speedY: 0.01,
      driftSpeed: 0.15,
      driftRange: 0.04,
      morphSpeed: 0.4,
      morphAmplitude: 12.0,
      morphFrequency: 3,
      gradientColors: [
        const Color(0xFF10B981).withOpacity(0.4), // Emerald
        const Color(0xFF06B6D4).withOpacity(0.2), // Cyan
        const Color(0xFF3B82F6).withOpacity(0.1), // Indigo
      ],
      shadowColor: const Color(0x2210B981),
      isForeground: false,
    ));

    _bubbles.add(LiquidBubble(
      xPercent: 0.78,
      yPercent: 0.15,
      baseRadius: 80,
      speedY: 0.02,
      driftSpeed: 0.3,
      driftRange: 0.06,
      morphSpeed: 0.8,
      morphAmplitude: 7.0,
      morphFrequency: 5,
      gradientColors: [
        const Color(0xFFD946EF).withOpacity(0.35), // Magenta
        const Color(0xFF8B5CF6).withOpacity(0.25), // Purple
        const Color(0xFF06B6D4).withOpacity(0.15), // Cyan
      ],
      shadowColor: const Color(0x22D946EF),
      isForeground: false,
    ));

    // Foreground layer bubbles (smaller, glossier, floating in front of card)
    _bubbles.add(LiquidBubble(
      xPercent: 0.28,
      yPercent: 0.85,
      baseRadius: 65,
      speedY: 0.025,
      driftSpeed: 0.4,
      driftRange: 0.08,
      morphSpeed: 1.1,
      morphAmplitude: 6.0,
      morphFrequency: 4,
      gradientColors: [
        const Color(0xFF06B6D4).withOpacity(0.6), // Cyan Spark
        const Color(0xFF10B981).withOpacity(0.3), // Emerald
        const Color(0xFFFFFFFF).withOpacity(0.15), // Specular
      ],
      shadowColor: const Color(0x4406B6D4),
      isForeground: true,
    ));

    _bubbles.add(LiquidBubble(
      xPercent: 0.82,
      yPercent: 0.45,
      baseRadius: 55,
      speedY: 0.03,
      driftSpeed: 0.5,
      driftRange: 0.07,
      morphSpeed: 1.3,
      morphAmplitude: 5.5,
      morphFrequency: 5,
      gradientColors: [
        const Color(0xFFEC4899).withOpacity(0.55), // Hot Pink
        const Color(0xFF8B5CF6).withOpacity(0.35), // Indigo Glow
        const Color(0xFF06B6D4).withOpacity(0.2), // Cyan Specular
      ],
      shadowColor: const Color(0x44EC4899),
      isForeground: true,
    ));

    _bubbles.add(LiquidBubble(
      xPercent: 0.12,
      yPercent: 0.55,
      baseRadius: 75,
      speedY: 0.018,
      driftSpeed: 0.25,
      driftRange: 0.05,
      morphSpeed: 0.7,
      morphAmplitude: 8.5,
      morphFrequency: 3,
      gradientColors: [
        const Color(0xFF8B5CF6).withOpacity(0.45), // Royal Purple
        const Color(0xFF3B82F6).withOpacity(0.3), // Blue
        const Color(0xFF00F5FF).withOpacity(0.25), // Neon Cyan
      ],
      shadowColor: const Color(0x338B5CF6),
      isForeground: true,
    ));
    
    // Tiny decorative bubbles
    for (int i = 0; i < 4; i++) {
      _bubbles.add(LiquidBubble(
        xPercent: rand.nextDouble(),
        yPercent: rand.nextDouble(),
        baseRadius: 15.0 + rand.nextDouble() * 20.0,
        speedY: 0.03 + rand.nextDouble() * 0.02,
        driftSpeed: 0.6 + rand.nextDouble() * 0.4,
        driftRange: 0.05,
        morphSpeed: 1.5,
        morphAmplitude: 2.0,
        morphFrequency: 4,
        gradientColors: [
          Colors.white.withOpacity(0.5),
          const Color(0xFF06B6D4).withOpacity(0.3),
          Colors.transparent,
        ],
        shadowColor: Colors.transparent,
        isForeground: rand.nextBool(),
      ));
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ticker,
      child: widget.child, // Cache the login screen child widget
      builder: (context, child) {
        // Update all bubble states based on approximate frame delta time (~16ms)
        const double dt = 0.016;
        for (var bubble in _bubbles) {
          bubble.update(dt);
        }

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF021722), // Premium deep dark teal-cyan (mockup line color)
                Color(0xFF05313D), // Cinematic sophisticated steel teal-cyan
                Color(0xFF00060A), // Near pitch-black teal outer edge
              ],
            ),
          ),
          child: SizedBox.expand(
            child: Stack(
              children: [
                // 1. BACKGROUND BUBBLES (behind glass)
                Positioned.fill(
                  child: CustomPaint(
                    painter: BubblePainter(
                      bubbles: _bubbles.where((b) => !b.isForeground).toList(),
                    ),
                  ),
                ),
      
                // 2. CENTRAL FORM / INTERACTIVE LAYER
                Positioned.fill(child: child ?? const SizedBox.shrink()), // Reuse cached child
      
                // 3. FOREGROUND BUBBLES (floating in front)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: BubblePainter(
                        bubbles: _bubbles.where((b) => b.isForeground).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BubblePainter extends CustomPainter {
  final List<LiquidBubble> bubbles;

  BubblePainter({required this.bubbles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var bubble in bubbles) {
      final double driftOffset = math.sin(bubble.driftPhase) * bubble.driftRange * size.width;
      final double cx = (bubble.xPercent * size.width) + driftOffset;
      final double cy = bubble.yPercent * size.height;
      final double r = bubble.baseRadius;

      // Draw drop shadow if present
      if (bubble.shadowColor != Colors.transparent) {
        final shadowPaint = Paint()
          ..color = bubble.shadowColor
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.35);
        canvas.drawCircle(Offset(cx, cy + r * 0.15), r, shadowPaint);
      }

      // Generate morphing liquid path using sine wave modulations
      final Path path = Path();
      const int numPoints = 80;
      
      for (int i = 0; i <= numPoints; i++) {
        final double angle = (i * 2 * math.pi) / numPoints;
        // Morph the radius mathematically using sine waves
        final double radialWiggle = math.sin(angle * bubble.morphFrequency + bubble.timeOffset) * bubble.morphAmplitude;
        final double currentRadius = r + radialWiggle;

        final double px = cx + currentRadius * math.cos(angle);
        final double py = cy + currentRadius * math.sin(angle);

        if (i == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();

      // Draw base color with complex linear/radial composite gradient
      final Paint bubblePaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.9,
          colors: bubble.gradientColors,
          stops: bubble.gradientColors.length == 3 ? const [0.0, 0.6, 1.0] : null,
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

      canvas.drawPath(path, bubblePaint);

      // Draw chrome border rim representing thin-film iridescence
      final Paint rimPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r > 30 ? 2.5 : 1.0
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.95), // White reflection
            const Color(0xFF00FFFF).withOpacity(0.7), // Cyan shimmer
            const Color(0xFFFF00D0).withOpacity(0.55), // Hot magenta
            const Color(0xFF00FF7F).withOpacity(0.35), // Chrome green edge
            Colors.white.withOpacity(0.1),
          ],
          stops: const [0.0, 0.25, 0.55, 0.8, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

      canvas.drawPath(path, rimPaint);

      // Draw organic specular reflection (glossy highlight on top-left)
      if (r > 25) {
        final double specRadius = r * 0.35;
        final double specCx = cx - r * 0.35;
        final double specCy = cy - r * 0.35;

        final Paint specularPaint = Paint()
          ..style = PaintingStyle.fill
          ..shader = RadialGradient(
            center: const Alignment(-0.2, -0.2),
            radius: 0.85,
            colors: [
              Colors.white.withOpacity(0.85),
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.0),
            ],
            stops: const [0.0, 0.45, 1.0],
          ).createShader(Rect.fromCircle(center: Offset(specCx, specCy), radius: specRadius));

        canvas.drawCircle(Offset(specCx, specCy), specRadius, specularPaint);
      }

      // Draw secondary glowing refractive highlight on bottom-right
      if (r > 35) {
        final double refRadius = r * 0.4;
        final double refCx = cx + r * 0.3;
        final double refCy = cy + r * 0.3;

        final Paint refractivePaint = Paint()
          ..style = PaintingStyle.fill
          ..shader = RadialGradient(
            center: const Alignment(0.3, 0.3),
            radius: 0.9,
            colors: [
              const Color(0xFF00FFFF).withOpacity(0.35),
              const Color(0xFFFF00D0).withOpacity(0.15),
              Colors.transparent,
            ],
            stops: const [0.0, 0.6, 1.0],
          ).createShader(Rect.fromCircle(center: Offset(refCx, refCy), radius: refRadius));

        canvas.drawCircle(Offset(refCx, refCy), refRadius, refractivePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
