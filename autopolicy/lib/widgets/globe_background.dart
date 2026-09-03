import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Full-screen animated 3D holographic globe background.
/// Inspired by Sellix "Cross-border finance" dark purple LED sphere.
class GlobeBackground extends StatefulWidget {
  final Widget? child;
  const GlobeBackground({super.key, this.child});

  @override
  State<GlobeBackground> createState() => _GlobeBackgroundState();
}

class _GlobeBackgroundState extends State<GlobeBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
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
        // Deep dark background
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF03000A),
                  Color(0xFF070014),
                  Color(0xFF020007),
                ],
              ),
            ),
          ),
        ),

        // Globe canvas — SizedBox.expand forces full-screen constraints
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return SizedBox.expand(
                child: CustomPaint(
                  painter: _GlobePainter(_controller.value),
                ),
              );
            },
          ),
        ),

        // Foreground child
        if (widget.child != null) Positioned.fill(child: widget.child!),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _GlobePainter extends CustomPainter {
  final double progress;

  static final List<_Star> _stars = _generateStars();

  static final List<_ArcDef> _arcs = [
    _ArcDef(latFrac: 0.25, lngFrac: 0.62, endDx: 0.85, endDy: 0.12,
        color: Color(0xFFBF7FFF), speed: 0.42),
    _ArcDef(latFrac: 0.38, lngFrac: 0.18, endDx: 0.12, endDy: 0.20,
        color: Color(0xFF00CFFF), speed: 0.31),
    _ArcDef(latFrac: 0.15, lngFrac: 0.78, endDx: 0.90, endDy: 0.38,
        color: Color(0xFFE040FB), speed: 0.55),
    _ArcDef(latFrac: 0.45, lngFrac: 0.32, endDx: 0.08, endDy: 0.42,
        color: Color(0xFF7C4DFF), speed: 0.37),
  ];

  const _GlobePainter(this.progress);

  static List<_Star> _generateStars() {
    final rng = math.Random(1337);
    return List.generate(160, (_) => _Star(
      xFrac: rng.nextDouble(),
      yFrac: rng.nextDouble() * 0.80,
      size: 0.5 + rng.nextDouble() * 1.6,
      phase: rng.nextDouble() * math.pi * 2,
    ));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || size.width < 10 || size.height < 10) return;

    final double cx = size.width / 2;
    final double cy = size.height * 0.92;
    final double radius = math.min(size.width, size.height) * 0.68;
    final double rotY = progress * 2 * math.pi;
    final Offset center = Offset(cx, cy);

    _drawRidges(canvas, size);
    _drawStars(canvas, size);
    _drawAmbientGlow(canvas, center, radius);
    _drawWireframe(canvas, center, radius, rotY);
    _drawDots(canvas, center, radius, rotY);
    _drawRimHalo(canvas, center, radius);
    _drawArcs(canvas, size, center, radius, rotY);
    _drawVignette(canvas, size);
  }

  void _drawRidges(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    for (double y = 0; y < size.height; y += 14) {
      p.color = (y ~/ 14) % 6 == 0
          ? const Color(0xFF2A0055).withOpacity(0.22)
          : const Color(0xFF150030).withOpacity(0.12);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  void _drawStars(Canvas canvas, Size size) {
    final p = Paint()..style = PaintingStyle.fill;
    for (final s in _stars) {
      final t = 0.3 + 0.7 * math.sin(progress * math.pi * 3 + s.phase);
      p.color = Colors.white.withOpacity(0.4 * t);
      canvas.drawCircle(
        Offset(s.xFrac * size.width, s.yFrac * size.height),
        s.size * t, p,
      );
    }
  }

  void _drawAmbientGlow(Canvas canvas, Offset c, double r) {
    final p = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 18; i++) {
      final frac = i / 18.0;
      final gr = r * (1.7 - frac * 0.9);
      p.color = const Color(0xFF7B2FBE).withOpacity(0.012 + frac * frac * 0.12);
      canvas.drawCircle(c, gr, p);
    }
  }

  void _drawWireframe(Canvas canvas, Offset c, double r, double rotY) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    // Latitude
    for (int d = -80; d <= 80; d += 20) {
      final lat = d * math.pi / 180;
      final rr = r * math.cos(lat);
      final yOff = -r * math.sin(lat);
      p.color = const Color(0xFF9D4EDD).withOpacity(0.14);
      final path = Path();
      bool on = false;
      for (int s = 0; s <= 360; s += 4) {
        final lng = s * math.pi / 180;
        final x3 = rr * math.sin(lng);
        final z3 = rr * math.cos(lng);
        final xR = x3 * math.cos(rotY) + z3 * math.sin(rotY);
        final zR = -x3 * math.sin(rotY) + z3 * math.cos(rotY);
        if (zR < 0) { on = false; continue; }
        if (!on) { path.moveTo(c.dx + xR, c.dy + yOff); on = true; }
        else { path.lineTo(c.dx + xR, c.dy + yOff); }
      }
      canvas.drawPath(path, p);
    }

    // Longitude
    for (int d = 0; d < 360; d += 30) {
      final lng = d * math.pi / 180;
      p.color = const Color(0xFF9D4EDD).withOpacity(0.10);
      final path = Path();
      bool on = false;
      for (int s = -90; s <= 90; s += 4) {
        final lat = s * math.pi / 180;
        final x3 = r * math.cos(lat) * math.sin(lng);
        final y3 = -r * math.sin(lat);
        final z3 = r * math.cos(lat) * math.cos(lng);
        final xR = x3 * math.cos(rotY) + z3 * math.sin(rotY);
        final zR = -x3 * math.sin(rotY) + z3 * math.cos(rotY);
        if (zR < 0) { on = false; continue; }
        if (!on) { path.moveTo(c.dx + xR, c.dy + y3); on = true; }
        else { path.lineTo(c.dx + xR, c.dy + y3); }
      }
      canvas.drawPath(path, p);
    }
  }

  void _drawDots(Canvas canvas, Offset c, double r, double rotY) {
    const int latN = 36;
    const int lngMax = 72;
    final dp = Paint()..style = PaintingStyle.fill;

    for (int li = 0; li < latN; li++) {
      final lat = ((li / (latN - 1)) - 0.5) * math.pi;
      final cL = math.cos(lat);
      final sL = math.sin(lat);
      final rr = r * cL;
      final dots = (lngMax * cL).round().clamp(8, lngMax);

      for (int gi = 0; gi < dots; gi++) {
        final lng = (gi / dots) * 2 * math.pi;
        final x3 = rr * math.sin(lng);
        final y3 = -r * sL;
        final z3 = rr * math.cos(lng);
        final xR = x3 * math.cos(rotY) + z3 * math.sin(rotY);
        final zR = -x3 * math.sin(rotY) + z3 * math.cos(rotY);
        if (zR < -r * 0.02) continue;

        final depth = ((zR / r) + 1.0) / 2.0;
        final land = _land(lat, lng + rotY * 0.1);

        if (!land && depth < 0.6 && (li + gi) % 4 != 0) continue;

        final px = c.dx + xR;
        final py = c.dy + y3;
        final op = land ? (0.35 + depth * 0.65) : (0.12 + depth * 0.25);
        final sz = land ? (0.8 + depth * 1.5) : (0.4 + depth * 0.7);

        Color col;
        if (depth > 0.85 && land) {
          col = Color.lerp(const Color(0xFFE2C5FF), Colors.white, (depth - 0.85) / 0.15)!;
        } else {
          col = Color.lerp(
            const Color(0xFF4B0082),
            land ? const Color(0xFFD8B4FE) : const Color(0xFF8A2BE2),
            depth,
          )!;
        }

        dp.color = col.withOpacity(op.clamp(0.0, 1.0));
        canvas.drawCircle(Offset(px, py), sz, dp);

        if (depth > 0.88 && land && (li + gi) % 3 == 0) {
          dp.color = Colors.white.withOpacity(0.3 * depth);
          canvas.drawCircle(Offset(px, py), sz * 1.8, dp);
        }
      }
    }
  }

  bool _land(double lat, double lng) {
    final v = math.sin(lat * 4.2) * math.cos(lng * 2.8) +
        math.cos(lat * 1.8) * math.sin(lng * 5.4) * 0.5 +
        math.sin(lat * 6.5 + lng * 1.8) * 0.3;
    return v > 0.12;
  }

  void _drawRimHalo(Canvas canvas, Offset c, double r) {
    for (int i = 0; i < 10; i++) {
      final t = 1.0 - i / 10.0;
      canvas.drawCircle(c, r + i * 2.5, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 - i * 0.2
        ..color = const Color(0xFFBF7FFF).withOpacity(0.40 * t * t));
    }
    canvas.drawCircle(c, r, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFF3E8FF).withOpacity(0.85));
  }

  void _drawArcs(Canvas canvas, Size size, Offset c, double r, double rotY) {
    for (final a in _arcs) {
      final lat = (a.latFrac - 0.5) * math.pi * 0.6;
      final lng = a.lngFrac * 2 * math.pi + rotY;
      final cL = math.cos(lat);
      final x3 = r * cL * math.sin(lng);
      final y3 = -r * math.sin(lat);
      final z3 = r * cL * math.cos(lng);
      final xR = x3 * math.cos(rotY) + z3 * math.sin(rotY);
      final zR = -x3 * math.sin(rotY) + z3 * math.cos(rotY);
      if (zR < 0) continue;

      final start = Offset(c.dx + xR, c.dy + y3);
      final end = Offset(a.endDx * size.width, a.endDy * size.height);
      final ctrl = Offset(
        (start.dx + end.dx) / 2 + (end.dy - start.dy) * 0.15,
        math.min(start.dy, end.dy) - 60 - size.height * 0.04,
      );

      // Triple-stroke glow
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy);
      final sp = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
      sp.color = a.color.withOpacity(0.08); sp.strokeWidth = 5; canvas.drawPath(path, sp);
      sp.color = a.color.withOpacity(0.20); sp.strokeWidth = 2.5; canvas.drawPath(path, sp);
      sp.color = a.color.withOpacity(0.70); sp.strokeWidth = 1.0; canvas.drawPath(path, sp);

      // Moving particle
      final t = ((progress * a.speed * 2.5) % 1.0);
      final mt = 1.0 - t;
      final pp = Offset(
        mt * mt * start.dx + 2 * mt * t * ctrl.dx + t * t * end.dx,
        mt * mt * start.dy + 2 * mt * t * ctrl.dy + t * t * end.dy,
      );
      final fp = Paint()..style = PaintingStyle.fill;
      fp.color = a.color.withOpacity(0.10); canvas.drawCircle(pp, 9, fp);
      fp.color = a.color.withOpacity(0.30); canvas.drawCircle(pp, 5, fp);
      fp.color = a.color.withOpacity(0.85); canvas.drawCircle(pp, 2.5, fp);
      fp.color = Colors.white; canvas.drawCircle(pp, 1.2, fp);

      // Anchor dot
      fp.color = a.color.withOpacity(0.4); canvas.drawCircle(start, 6, fp);
      fp.color = Colors.white; canvas.drawCircle(start, 2, fp);
    }
  }

  void _drawVignette(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.22),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.65), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.22)),
    );
  }

  @override
  bool shouldRepaint(covariant _GlobePainter old) => old.progress != progress;
}

class _Star {
  final double xFrac, yFrac, size, phase;
  const _Star({required this.xFrac, required this.yFrac, required this.size, required this.phase});
}

class _ArcDef {
  final double latFrac, lngFrac, endDx, endDy, speed;
  final Color color;
  const _ArcDef({required this.latFrac, required this.lngFrac, required this.endDx,
      required this.endDy, required this.color, required this.speed});
}
