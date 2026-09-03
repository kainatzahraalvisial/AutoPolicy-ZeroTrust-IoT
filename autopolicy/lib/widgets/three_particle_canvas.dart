import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Particle3D {
  double x, y, z;
  double vx, vy, vz;
  final Color color;

  Particle3D({
    required this.x,
    required this.y,
    required this.z,
    required this.vx,
    required this.vy,
    required this.vz,
    required this.color,
  });
}

class ThreeParticleCanvas extends StatefulWidget {
  final Offset mousePos;
  const ThreeParticleCanvas({
    super.key,
    this.mousePos = const Offset(-9999, -9999),
  });

  @override
  State<ThreeParticleCanvas> createState() => _ThreeParticleCanvasState();
}

class _ThreeParticleCanvasState extends State<ThreeParticleCanvas>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final List<Particle3D> _particles = [];
  final Random _rand = Random();

  static const int particleCount = 240;
  static const double linkDistance = 165.0;
  static const double grabDistance = 220.0;
  static const double cameraZ = 400.0;

  // Exact color palette from user's image (032820, 80A416, C5C764, 08652C, AD9F3C, 5E7343, BBF438)
  static const Color colorWhite = Color(0xFFFFFFFF);
  static const Color colorLimeGold = Color(0xFFC5C764);
  static const Color colorOlive = Color(0xFF80A416);
  static const Color colorBrightLime = Color(0xFFBBF438);
  static const Color colorWarmGold = Color(0xFFAD9F3C);

  @override
  void initState() {
    super.initState();
    _initParticles();
    _ticker = createTicker((_) {
      _updateParticles();
      if (mounted) {
        setState(() {});
      }
    });
    _ticker.start();
  }

  void _initParticles() {
    _particles.clear();
    const double bx = 650.0;
    const double by = 420.0;
    const double bz = 110.0;

    for (int i = 0; i < particleCount; i++) {
      final double x = (_rand.nextDouble() - 0.5) * bx * 2;
      final double y = (_rand.nextDouble() - 0.5) * by * 2;
      final double z = (_rand.nextDouble() - 0.5) * bz * 2;

      final double vx = (_rand.nextDouble() - 0.5) * 0.65;
      final double vy = (_rand.nextDouble() - 0.5) * 0.65;
      final double vz = (_rand.nextDouble() - 0.5) * 0.35;

      final double r = _rand.nextDouble();
      Color c;
      if (r < 0.25) {
        c = colorWhite;
      } else if (r < 0.55) {
        c = colorLimeGold;
      } else if (r < 0.82) {
        c = colorOlive;
      } else {
        c = colorWarmGold;
      }

      _particles.add(Particle3D(
        x: x, y: y, z: z,
        vx: vx, vy: vy, vz: vz,
        color: c,
      ));
    }
  }

  void _updateParticles() {
    const double bx = 650.0;
    const double by = 420.0;
    const double bz = 110.0;

    for (final p in _particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.z += p.vz;

      if (p.x.abs() > bx) p.vx *= -1;
      if (p.y.abs() > by) p.vy *= -1;
      if (p.z.abs() > bz) p.vz *= -1;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Container(
          color: Colors.black,
          width: size.width,
          height: size.height,
          child: CustomPaint(
            painter: _Particle3DPainter(
              particles: _particles,
              mouseScreenPos: widget.mousePos,
              colorBrightLime: colorBrightLime,
              colorWhite: colorWhite,
              colorOlive: colorOlive,
              colorLimeGold: colorLimeGold,
            ),
          ),
        );
      },
    );
  }
}

class _Particle3DPainter extends CustomPainter {
  final List<Particle3D> particles;
  final Offset mouseScreenPos;
  final Color colorBrightLime;
  final Color colorWhite;
  final Color colorOlive;
  final Color colorLimeGold;

  _Particle3DPainter({
    required this.particles,
    required this.mouseScreenPos,
    required this.colorBrightLime,
    required this.colorWhite,
    required this.colorOlive,
    required this.colorLimeGold,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const cameraZ = 400.0;
    const linkDistance = 165.0;
    const grabDistance = 220.0;

    final bool hasMouse = mouseScreenPos.dx >= 0 && mouseScreenPos.dy >= 0;
    double mouse3Dx = 0.0, mouse3Dy = 0.0;
    if (hasMouse) {
      mouse3Dx = mouseScreenPos.dx - center.dx;
      mouse3Dy = mouseScreenPos.dy - center.dy;
    }

    final int count = particles.length;
    final List<Offset> proj = List.filled(count, Offset.zero);
    final List<double> scales = List.filled(count, 1.0);

    for (int i = 0; i < count; i++) {
      final p = particles[i];
      final double scale = cameraZ / (cameraZ + p.z);
      scales[i] = scale;
      proj[i] = Offset(center.dx + p.x * scale, center.dy + p.y * scale);
    }

    // 1. Inter-particle dense line network (Olive, Gold & Bright Lime)
    for (int i = 0; i < count; i++) {
      final p1 = particles[i];
      final pt1 = proj[i];

      // Mouse Grab Reaction: Bright lime connections when mouse approaches nodes
      if (hasMouse) {
        final double dxM = p1.x - mouse3Dx;
        final double dyM = p1.y - mouse3Dy;
        final double dzM = p1.z;
        final double distM = sqrt(dxM * dxM + dyM * dyM + dzM * dzM);

        if (distM < grabDistance) {
          final double alphaM = (1.0 - distM / grabDistance) * 0.75;
          final grabPaint = Paint()
            ..color = colorBrightLime.withOpacity(alphaM.clamp(0.0, 1.0))
            ..strokeWidth = 1.4
            ..style = PaintingStyle.stroke;
          canvas.drawLine(pt1, mouseScreenPos, grabPaint);
        }
      }

      // Dense web lines between neighboring nodes
      for (int j = i + 1; j < count; j++) {
        final p2 = particles[j];
        final dx = p1.x - p2.x;
        final dy = p1.y - p2.y;
        final dz = p1.z - p2.z;
        final double dist = sqrt(dx * dx + dy * dy + dz * dz);

        if (dist < linkDistance) {
          final double baseAlpha = (1.0 - dist / linkDistance) * 0.32;
          final bool isWhite1 = p1.color == colorWhite;
          final bool isWhite2 = p2.color == colorWhite;
          final double alpha1 = isWhite1 ? baseAlpha * 0.40 : baseAlpha;
          final double alpha2 = isWhite2 ? baseAlpha * 0.40 : baseAlpha;
          final double avgAlpha = ((alpha1 + alpha2) / 2.0).clamp(0.0, 1.0);

          final pt2 = proj[j];
          final Color mixColor = Color.lerp(p1.color, p2.color, 0.5)!;

          final linePaint = Paint()
            ..color = mixColor.withOpacity(avgAlpha)
            ..strokeWidth = 0.95
            ..style = PaintingStyle.stroke;

          canvas.drawLine(pt1, pt2, linePaint);
        }
      }
    }

    // 2. Glowing Nodes (Bright Yellow-Green Core + Halo) matching HTML reference
    for (int i = 0; i < count; i++) {
      final p = particles[i];
      final pt = proj[i];
      final scale = scales[i];
      final double radius = 3.8 * scale;

      // Outer radial glow halo
      final haloPaint = Paint()
        ..color = (p.color == colorWhite ? colorBrightLime : p.color).withOpacity(0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);
      canvas.drawCircle(pt, radius * 1.6, haloPaint);

      // Bright yellow-white core dot
      final corePaint = Paint()
        ..color = (p.color == colorWhite ? Colors.white : colorBrightLime).withOpacity(0.95)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pt, max(0.9, radius * 0.55), corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _Particle3DPainter oldDelegate) => true;
}
