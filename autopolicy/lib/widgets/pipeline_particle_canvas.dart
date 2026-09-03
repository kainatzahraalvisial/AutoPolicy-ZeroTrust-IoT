import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class _PipelineParticle {
  double x, y, z;
  double vx, vy, vz;

  _PipelineParticle({
    required this.x,
    required this.y,
    required this.z,
    required this.vx,
    required this.vy,
    required this.vz,
  });
}

class PipelineParticleCanvas extends StatefulWidget {
  const PipelineParticleCanvas({super.key});

  @override
  State<PipelineParticleCanvas> createState() => _PipelineParticleCanvasState();
}

class _PipelineParticleCanvasState extends State<PipelineParticleCanvas>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final List<_PipelineParticle> _particles = [];
  final Random _rand = Random();

  static const int count = 120;
  static const double linkDist = 62.0;
  static const double bounds = 110.0;

  static const Color colorLine = Color(0xFF80A416);
  static const Color colorNode = Color(0xFFC5C764);
  static const Color colorBright = Color(0xFFBBF438);

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
    for (int i = 0; i < count; i++) {
      _particles.add(_PipelineParticle(
        x: (_rand.nextDouble() - 0.5) * bounds * 2,
        y: (_rand.nextDouble() - 0.5) * bounds * 2.4,
        z: (_rand.nextDouble() - 0.5) * 40,
        vx: (_rand.nextDouble() - 0.5) * 0.4,
        vy: (_rand.nextDouble() - 0.5) * 0.4,
        vz: (_rand.nextDouble() - 0.5) * 0.2,
      ));
    }
  }

  void _updateParticles() {
    for (final p in _particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.z += p.vz;

      if (p.x.abs() > bounds) p.vx *= -1;
      if (p.y.abs() > bounds * 1.2) p.vy *= -1;
      if (p.z.abs() > 25) p.vz *= -1;
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
            painter: _PipelineParticlePainter(
              particles: _particles,
              colorLine: colorLine,
              colorNode: colorNode,
              colorBright: colorBright,
            ),
          ),
        );
      },
    );
  }
}

class _PipelineParticlePainter extends CustomPainter {
  final List<_PipelineParticle> particles;
  final Color colorLine;
  final Color colorNode;
  final Color colorBright;

  _PipelineParticlePainter({
    required this.particles,
    required this.colorLine,
    required this.colorNode,
    required this.colorBright,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const cameraZ = 220.0;
    const linkDist = 62.0;

    final int c = particles.length;
    final List<Offset> proj = List.filled(c, Offset.zero);
    final List<double> scales = List.filled(c, 1.0);

    for (int i = 0; i < c; i++) {
      final p = particles[i];
      final double scale = cameraZ / (cameraZ + p.z);
      scales[i] = scale;
      proj[i] = Offset(center.dx + p.x * scale, center.dy + p.y * scale);
    }

    // Inter-particle links
    for (int i = 0; i < c; i++) {
      final p1 = particles[i];
      final pt1 = proj[i];

      for (int j = i + 1; j < c; j++) {
        final p2 = particles[j];
        final dx = p1.x - p2.x;
        final dy = p1.y - p2.y;
        final dz = p1.z - p2.z;
        final double dist = sqrt(dx * dx + dy * dy + dz * dz);

        if (dist < linkDist) {
          final double alpha = (1.0 - dist / linkDist) * 0.45;
          final pt2 = proj[j];

          final linePaint = Paint()
            ..color = colorLine.withOpacity(alpha.clamp(0.0, 1.0))
            ..strokeWidth = 0.95
            ..style = PaintingStyle.stroke;

          canvas.drawLine(pt1, pt2, linePaint);
        }
      }
    }

    // Nodes
    for (int i = 0; i < c; i++) {
      final pt = proj[i];
      final scale = scales[i];
      final double radius = 3.5 * scale;

      final haloPaint = Paint()
        ..color = colorNode.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
      canvas.drawCircle(pt, radius * 1.4, haloPaint);

      final corePaint = Paint()
        ..color = Colors.white.withOpacity(0.9)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pt, max(0.8, radius * 0.5), corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PipelineParticlePainter oldDelegate) => true;
}
