import 'dart:math' as math;
import 'package:flutter/material.dart';

class RadiatingCyberBackground extends StatefulWidget {
  final Widget child;
  final Animation<double> animation;

  const RadiatingCyberBackground({
    super.key,
    required this.child,
    required this.animation,
  });

  @override
  State<RadiatingCyberBackground> createState() => _RadiatingCyberBackgroundState();
}

class _RadiatingCyberBackgroundState extends State<RadiatingCyberBackground> {
  late final List<_RayModel> _raysLayer1;
  late final List<_RayModel> _raysLayer2;

  @override
  void initState() {
    super.initState();
    _generateRays();
  }

  void _generateRays() {
    final rand = math.Random(42); // Seeded for beautiful, consistent distribution

    // Layer 1: Broad, deep cyber-teal backdrop blades (slower, matches circled lines)
    _raysLayer1 = List.generate(24, (index) {
      final baseAngle = (index * 2 * math.pi / 24) + (rand.nextDouble() * 0.15 - 0.075);
      return _RayModel(
        angle: baseAngle,
        width: 14.0 + rand.nextDouble() * 18.0,
        lengthFactor: 0.85 + rand.nextDouble() * 0.2,
        opacity: 0.18 + rand.nextDouble() * 0.22,
        color: const Color(0xFF034F5C), // Premium deep dark teal-cyan
        speedMultiplier: 0.3 + rand.nextDouble() * 0.4,
      );
    });

    // Layer 2: Sharp, elegant glowing dark cyan rays (faster & shinier, matches circled lines)
    _raysLayer2 = List.generate(20, (index) {
      final baseAngle = (index * 2 * math.pi / 20) + (rand.nextDouble() * 0.2 - 0.1);
      return _RayModel(
        angle: baseAngle,
        width: 4.0 + rand.nextDouble() * 6.0,
        lengthFactor: 0.7 + rand.nextDouble() * 0.35,
        opacity: 0.35 + rand.nextDouble() * 0.25,
        color: const Color(0xFF0A6E82), // Glowing sophisticated dark cyan-teal
        speedMultiplier: -0.6 - rand.nextDouble() * 0.5, // Counter-rotates
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        final double animValue = widget.animation.value;

        return Stack(
          children: [
            // Base Cinematic cybernetic background gradient
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      Color(0xFF021720), // Premium very dark teal-cyan core
                      Color(0xFF000508), // Near pitch-black teal outer edge
                    ],
                  ),
                ),
              ),
            ),

            // Dynamic Radiating Spoke Layers
            Positioned.fill(
              child: CustomPaint(
                painter: _CyberRaysPainter(
                  raysLayer1: _raysLayer1,
                  raysLayer2: _raysLayer2,
                  animValue: animValue,
                ),
              ),
            ),

            // Subtle dark overlay to ensure maximum readability of form text
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.9,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.65),
                    ],
                  ),
                ),
              ),
            ),

            // Main screen content
            Positioned.fill(child: widget.child),
          ],
        );
      },
    );
  }
}

class _RayModel {
  final double angle;
  final double width;
  final double lengthFactor;
  final double opacity;
  final Color color;
  final double speedMultiplier;

  _RayModel({
    required this.angle,
    required this.width,
    required this.lengthFactor,
    required this.opacity,
    required this.color,
    required this.speedMultiplier,
  });
}

class _CyberRaysPainter extends CustomPainter {
  final List<_RayModel> raysLayer1;
  final List<_RayModel> raysLayer2;
  final double animValue;

  _CyberRaysPainter({
    required this.raysLayer1,
    required this.raysLayer2,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height) / 2;

    // Draw Layer 1 (Cobalt deep blades)
    for (var ray in raysLayer1) {
      final double currentAngle = ray.angle + (animValue * 2 * math.pi * 0.015 * ray.speedMultiplier);
      _drawBlade(canvas, center, currentAngle, ray.width, maxRadius * ray.lengthFactor, ray.color, ray.opacity);
    }

    // Draw Layer 2 (Electric cyan sharp rays)
    for (var ray in raysLayer2) {
      final double currentAngle = ray.angle + (animValue * 2 * math.pi * 0.015 * ray.speedMultiplier);
      
      // Pulse opacity slightly with animation
      final double pulseOpacity = (ray.opacity * (0.8 + 0.2 * math.sin(animValue * 2 * math.pi + ray.angle))).clamp(0.0, 1.0);
      _drawBlade(canvas, center, currentAngle, ray.width, maxRadius * ray.lengthFactor, ray.color, pulseOpacity);
    }
  }

  void _drawBlade(Canvas canvas, Offset center, double angle, double startWidth, double length, Color color, double opacity) {
    final Path path = Path();
    
    // Tapered blade geometry calculations
    final double endWidth = startWidth * 3.5; // Expands outward

    // Orthogonal offsets for drawing the blade polygons
    final double cosAngle = math.cos(angle);
    final double sinAngle = math.sin(angle);
    final double cosOrtho = -sinAngle;
    final double sinOrtho = cosAngle;

    // Starting offset from the center so rays don't overlap inside the center of the card
    const double minRadius = 40.0;
    final Offset pStartLeft = Offset(
      center.dx + cosAngle * minRadius - cosOrtho * (startWidth / 2),
      center.dy + sinAngle * minRadius - sinOrtho * (startWidth / 2),
    );
    final Offset pStartRight = Offset(
      center.dx + cosAngle * minRadius + cosOrtho * (startWidth / 2),
      center.dy + sinAngle * minRadius + sinOrtho * (startWidth / 2),
    );

    // End points near the screen boundary
    final Offset pEndLeft = Offset(
      center.dx + cosAngle * length - cosOrtho * (endWidth / 2),
      center.dy + sinAngle * length - sinOrtho * (endWidth / 2),
    );
    final Offset pEndRight = Offset(
      center.dx + cosAngle * length + cosOrtho * (endWidth / 2),
      center.dy + sinAngle * length + sinOrtho * (endWidth / 2),
    );

    path.moveTo(pStartLeft.dx, pStartLeft.dy);
    path.lineTo(pEndLeft.dx, pEndLeft.dy);
    path.lineTo(pEndRight.dx, pEndRight.dy);
    path.lineTo(pStartRight.dx, pStartRight.dy);
    path.close();

    // Metallic shader gradient along the blade's length
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [
          color.withOpacity(opacity),
          color.withOpacity(opacity * 0.4),
          color.withOpacity(0.0),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromPoints(center + Offset(cosAngle * minRadius, sinAngle * minRadius), center + Offset(cosAngle * length, sinAngle * length)));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CyberRaysPainter oldDelegate) {
    return oldDelegate.animValue != animValue;
  }
}
