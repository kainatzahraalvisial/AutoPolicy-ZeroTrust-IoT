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

  // Hues derived strictly from palette (No white nodes)
  static const Color colorBrightLime = Color(0xFFBBF438);
  static const Color colorGreen = Color(0xFFC5C764);
  static const Color colorOlive = Color(0xFF80A416);

  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      _updateParticles();
      if (mounted) {
        setState(() {});
      }
    });
    _ticker.start();
  }

  void _initParticles(Size size) {
    _particles.clear();
    _lastSize = size;

    // Full screen bounds in projected units
    final double bx = size.width * 0.55;
    final double by = size.height * 0.55;
    const double bz = 90.0;

    for (int i = 0; i < particleCount; i++) {
      final double x = (_rand.nextDouble() - 0.5) * bx * 2;
      final double y = (_rand.nextDouble() - 0.5) * by * 2;
      final double z = (_rand.nextDouble() - 0.5) * bz * 2;

      final double vx = (_rand.nextDouble() - 0.5) * 0.60;
      final double vy = (_rand.nextDouble() - 0.5) * 0.60;
      final double vz = (_rand.nextDouble() - 0.5) * 0.28;

      final double r = _rand.nextDouble();
      Color c;
      if (r < 0.35) {
        c = colorBrightLime;
      } else if (r < 0.70) {
        c = colorGreen;
      } else {
        c = colorOlive;
      }

      _particles.add(Particle3D(
        x: x, y: y, z: z,
        vx: vx, vy: vy, vz: vz,
        color: c,
      ));
    }
  }

  void _updateParticles() {
    if (_lastSize == Size.zero) return;

    final double bx = _lastSize.width * 0.55;
    final double by = _lastSize.height * 0.55;
    const double bz = 90.0;

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
        if (_particles.isEmpty || (size.width - _lastSize.width).abs() > 50) {
          _initParticles(size);
        }

        return Container(
          color: Colors.black,
          width: size.width,
          height: size.height,
          child: CustomPaint(
            painter: _Particle3DPainter(
              particles: _particles,
              mouseScreenPos: widget.mousePos,
              colorBrightLime: colorBrightLime,
              colorOlive: colorOlive,
              colorGreen: colorGreen,
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
  final Color colorOlive;
  final Color colorGreen;

  _Particle3DPainter({
    required this.particles,
    required this.mouseScreenPos,
    required this.colorBrightLime,
    required this.colorOlive,
    required this.colorGreen,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const cameraZ = 400.0;
    const linkDistance = 160.0;
    const grabDistanceScreen = 220.0;

    // Check if mouse is actively hovering inside valid screen bounds
    final bool hasMouse = mouseScreenPos.dx > 0 &&
        mouseScreenPos.dy > 0 &&
        mouseScreenPos.dx < size.width &&
        mouseScreenPos.dy < size.height;

    final int count = particles.length;
    final List<Offset> proj = List.filled(count, Offset.zero);
    final List<double> scales = List.filled(count, 1.0);

    for (int i = 0; i < count; i++) {
      final p = particles[i];
      final double scale = cameraZ / (cameraZ + p.z);
      scales[i] = scale;
      proj[i] = Offset(center.dx + p.x * scale, center.dy + p.y * scale);
    }

    // 1. Draw Network Links & Mouse Grab
    for (int i = 0; i < count; i++) {
      final p1 = particles[i];
      final pt1 = proj[i];

      // Mouse Grab Reaction: Bright green lines emanate to all nearby nodes in screen space
      if (hasMouse) {
        final double distM = (pt1 - mouseScreenPos).distance;
        if (distM < grabDistanceScreen) {
          final double alphaM = (1.0 - distM / grabDistanceScreen) * 0.85;
          final grabPaint = Paint()
            ..color = colorBrightLime.withOpacity( alphaM.clamp(0.0, 1.0))
            ..strokeWidth = 1.4
            ..style = PaintingStyle.stroke;
          canvas.drawLine(pt1, mouseScreenPos, grabPaint);
        }
      }

      // Neighbor link lines (Increased brightness and clarity for background edges)
      for (int j = i + 1; j < count; j++) {
        final p2 = particles[j];
        final dx = p1.x - p2.x;
        final dy = p1.y - p2.y;
        final dz = p1.z - p2.z;
        final double dist = sqrt(dx * dx + dy * dy + dz * dz);

        if (dist < linkDistance) {
          // Stronger base alpha for back lines (0.42 max instead of 0.28)
          final double baseAlpha = (1.0 - dist / linkDistance) * 0.42;

          final pt2 = proj[j];
          final Color mixColor = Color.lerp(p1.color, p2.color, 0.5)!;

          final linePaint = Paint()
            ..color = mixColor.withOpacity( baseAlpha.clamp(0.0, 1.0))
            ..strokeWidth = 1.1
            ..style = PaintingStyle.stroke;

          canvas.drawLine(pt1, pt2, linePaint);
        }
      }
    }

    // 2. Draw Clean Node Dots (Strictly green hues)
    for (int i = 0; i < count; i++) {
      final p = particles[i];
      final pt = proj[i];
      final scale = scales[i];
      final double radius = 3.8 * scale;

      final corePaint = Paint()
        ..color = p.color.withOpacity( 0.90)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pt, max(1.0, radius * 0.55), corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _Particle3DPainter oldDelegate) => true;
}
