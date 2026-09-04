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

class PipelineParticles extends StatefulWidget {
  final int particleCount;
  final double linkDistance;
  final double grabDistance;
  final double boundsX;
  final double boundsY;
  final double boundsZ;
  final bool contained;

  const PipelineParticles({
    super.key,
    this.particleCount = 120,
    this.linkDistance = 62,
    this.grabDistance = 0,
    this.boundsX = 110,
    this.boundsY = 132,
    this.boundsZ = 20,
    this.contained = true,
  });

  @override
  State<PipelineParticles> createState() => _PipelineParticlesState();
}

class _PipelineParticlesState extends State<PipelineParticles>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final List<_PipelineParticle> _particles = [];
  final Random _rand = Random();

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
    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(_PipelineParticle(
        x: (_rand.nextDouble() - 0.5) * widget.boundsX * 2,
        y: (_rand.nextDouble() - 0.5) * widget.boundsY * 2,
        z: (_rand.nextDouble() - 0.5) * widget.boundsZ * 2,
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

      if (p.x.abs() > widget.boundsX) p.vx *= -1;
      if (p.y.abs() > widget.boundsY) p.vy *= -1;
      if (p.z.abs() > widget.boundsZ) p.vz *= -1;
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
              linkDistance: widget.linkDistance,
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
  final double linkDistance;
  final Color colorLine;
  final Color colorNode;
  final Color colorBright;

  _PipelineParticlePainter({
    required this.particles,
    required this.linkDistance,
    required this.colorLine,
    required this.colorNode,
    required this.colorBright,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const cameraZ = 220.0;

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

        if (dist < linkDistance) {
          final double alpha = (1.0 - dist / linkDistance) * 0.45;
          final pt2 = proj[j];

          final linePaint = Paint()
            ..color = colorLine.withOpacity(alpha.clamp(0.0, 1.0))
            ..strokeWidth = 0.95
            ..style = PaintingStyle.stroke;

          canvas.drawLine(pt1, pt2, linePaint);
        }
      }
    }

    // Nodes (glowing yellow-green points matching HTML spec)
    for (int i = 0; i < c; i++) {
      final pt = proj[i];
      final scale = scales[i];
      final double radius = 3.5 * scale;

      final haloPaint = Paint()
        ..color = colorBright.withOpacity(0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
      canvas.drawCircle(pt, radius * 1.4, haloPaint);

      final corePaint = Paint()
        ..color = colorNode.withOpacity(0.95)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pt, max(0.8, radius * 0.5), corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PipelineParticlePainter oldDelegate) => true;
}
