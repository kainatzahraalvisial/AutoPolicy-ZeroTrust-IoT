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
  final double? currentBoundsX;
  final double? currentBoundsY;
  final double boundsZ;
  final bool contained;
  final bool isActive;

  const PipelineParticles({
    super.key,
    this.particleCount = 175,
    this.linkDistance = 72,
    this.grabDistance = 0,
    this.currentBoundsX,
    this.currentBoundsY,
    this.boundsZ = 28,
    this.contained = true,
    this.isActive = true,
  });

  @override
  State<PipelineParticles> createState() => _PipelineParticlesState();
}

class _PipelineParticlesState extends State<PipelineParticles>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final List<_PipelineParticle> _particles = [];
  final Random _rand = Random();
  Size _lastSize = Size.zero;

  static const Color colorLine = Color(0xFF80A416);
  static const Color colorNode = Color(0xFFC5C764);
  static const Color colorBright = Color(0xFFBBF438);

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

  @override
  void didUpdateWidget(covariant PipelineParticles oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When becoming active again, reseed across full screen
    if (widget.isActive && !oldWidget.isActive && _lastSize != Size.zero) {
      _initParticles(_lastSize);
    }
  }

  void _initParticles(Size size) {
    _particles.clear();
    _lastSize = size;
    // Spread across entire screen initially
    final double bx = size.width * 0.52;
    final double by = size.height * 0.52;

    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(_PipelineParticle(
        x: (_rand.nextDouble() - 0.5) * bx * 2,
        y: (_rand.nextDouble() - 0.5) * by * 2,
        z: (_rand.nextDouble() - 0.5) * widget.boundsZ * 2,
        vx: (_rand.nextDouble() - 0.5) * 2.2,
        vy: (_rand.nextDouble() - 0.5) * 2.2,
        vz: (_rand.nextDouble() - 0.5) * 0.9,
      ));
    }
  }

  void _updateParticles() {
    if (_lastSize == Size.zero) return;

    // Use currentBoundsX if passed during panel slide-in, otherwise full screen
    final double activeBoundsX = widget.currentBoundsX ?? (_lastSize.width * 0.52);
    final double activeBoundsY = widget.currentBoundsY ?? (_lastSize.height * 0.52);

    for (final p in _particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.z += p.vz;

      // Soft bounce & clamp within activeBoundsX so particles cluster smoothly
      if (p.x.abs() > activeBoundsX) {
        p.vx = -p.vx.abs() * (p.x > 0 ? 1.0 : -1.0);
        p.x = p.x.clamp(-activeBoundsX, activeBoundsX);
      }
      if (p.y.abs() > activeBoundsY) {
        p.vy = -p.vy.abs() * (p.y > 0 ? 1.0 : -1.0);
        p.y = p.y.clamp(-activeBoundsY, activeBoundsY);
      }
      if (p.z.abs() > widget.boundsZ) {
        p.vz *= -1;
        p.z = p.z.clamp(-widget.boundsZ, widget.boundsZ);
      }
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
        if (_lastSize != size) {
          if (_particles.isEmpty || _lastSize == Size.zero) {
            _initParticles(size);
          } else {
            _lastSize = size;
          }
        }

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

    // Simple clean nodes without glowing halo
    final nodePaint = Paint()
      ..color = colorNode.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < c; i++) {
      final pt = proj[i];
      final scale = scales[i];
      final double radius = 2.4 * scale;
      canvas.drawCircle(pt, max(1.2, radius), nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PipelineParticlePainter oldDelegate) => true;
}
