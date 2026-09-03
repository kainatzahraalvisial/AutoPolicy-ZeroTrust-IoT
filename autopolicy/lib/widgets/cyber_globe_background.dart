import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Ultra-premium animated 3D holographic cyber globe background.
/// All effects are drawn procedurally via CustomPaint — zero images, zero packages.
/// Every visual layer animates continuously at 60fps.
class CyberGlobeBackground extends StatefulWidget {
  final Widget? child;
  const CyberGlobeBackground({super.key, this.child});

  @override
  State<CyberGlobeBackground> createState() => _CyberGlobeBackgroundState();
}

class _CyberGlobeBackgroundState extends State<CyberGlobeBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 30))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Stack(
      children: [
        // 1) Base gradient
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF050816), Color(0xFF0B1020), Color(0xFF06000E)],
              ),
            ),
          ),
        ),
        // 2) Animated canvas — SizedBox.expand guarantees full-size constraints
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => SizedBox.expand(
                child: CustomPaint(
                  painter: _GlobePainter(_ctrl.value, isWide),
                ),
              ),
            ),
          ),
        ),
        // 3) Child overlay
        if (widget.child != null) Positioned.fill(child: widget.child!),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  PAINTER — 15 cinematic visual layers
// ═══════════════════════════════════════════════════════════════════════════════
class _GlobePainter extends CustomPainter {
  final double p; // progress 0→1
  final bool wide;

  const _GlobePainter(this.p, this.wide);

  // ── Pre-computed static data (generated once, shared across all frames) ──
  static final _s1 = _genStars(90, 0.85, 1.2, 42);
  static final _s2 = _genStars(55, 0.80, 1.8, 137);
  static final _s3 = _genStars(25, 0.90, 2.5, 256);
  static final _rain = _genRain(14, 99);
  static final _orb = _genOrbParticles(35, 777);
  static final _arcs = <_Arc>[
    _Arc(0.20, 0.55, 0.88, 0.10, const Color(0xFFBF7FFF), 0.40),
    _Arc(0.40, 0.22, 0.10, 0.18, const Color(0xFF00E5FF), 0.32),
    _Arc(0.12, 0.80, 0.92, 0.42, const Color(0xFFE040FB), 0.52),
    _Arc(0.48, 0.35, 0.06, 0.50, const Color(0xFF7C4DFF), 0.38),
    _Arc(0.30, 0.90, 0.78, 0.06, const Color(0xFF00FF87), 0.45),
  ];

  @override
  void paint(Canvas canvas, Size s) {
    if (s.width < 20 || s.height < 20) return;

    // Globe geometry — positioned center-right on desktop, center on mobile
    final cx = wide ? s.width * 0.56 : s.width * 0.50;
    final cy = wide ? s.height * 0.52 : s.height * 0.60;
    final r = math.min(s.width, s.height) * (wide ? 0.38 : 0.32);
    final rot = p * 2 * math.pi;
    final c = Offset(cx, cy);

    _paintScanlines(canvas, s);
    _paintStarfield(canvas, s);
    _paintPerspectiveGrid(canvas, s, c);
    _paintAmbientGlow(canvas, c, r);
    _paintWireframe(canvas, c, r, rot);
    _paintGlobeDots(canvas, c, r, rot);
    _paintScanWave(canvas, c, r, rot);
    _paintRimHalo(canvas, c, r);
    _paintOrbitalTrails(canvas, s, c, r, rot);
    _paintRadarPulse(canvas, c, r);
    _paintFloatingParticles(canvas, s, c, r);
    _paintMatrixRain(canvas, s);
    _paintVignette(canvas, s);
  }

  // ───────────────────────── 1. SCANLINES ──────────────────────────────────
  void _paintScanlines(Canvas canvas, Size s) {
    final p2 = Paint()..style = PaintingStyle.stroke..strokeWidth = 0.4;
    for (double y = 0; y < s.height; y += 4.0) {
      p2.color = const Color(0xFF1A0030).withOpacity(0.18);
      canvas.drawLine(Offset(0, y), Offset(s.width, y), p2);
    }
  }

  // ───────────────────────── 2. STARFIELD (3 parallax layers) ──────────────
  void _paintStarfield(Canvas canvas, Size s) {
    final pt = Paint()..style = PaintingStyle.fill;
    void drawLayer(List<_Star> stars, double drift, double baseOp) {
      for (final st in stars) {
        final tw = 0.3 + 0.7 * math.sin(p * math.pi * 4 + st.ph);
        pt.color = Colors.white.withOpacity(baseOp * tw);
        final dx = (st.x + p * drift) % 1.0;
        canvas.drawCircle(Offset(dx * s.width, st.y * s.height), st.sz * tw, pt);
      }
    }
    drawLayer(_s1, 0.01, 0.22);
    drawLayer(_s2, 0.025, 0.35);
    drawLayer(_s3, 0.05, 0.55);
  }

  // ───────────────────────── 3. PERSPECTIVE GRID ───────────────────────────
  void _paintPerspectiveGrid(Canvas canvas, Size s, Offset globe) {
    final pt = Paint()..style = PaintingStyle.stroke..strokeWidth = 0.4;
    final vx = globe.dx;
    final vy = globe.dy;
    // Horizontal lines converging toward globe center
    for (int i = 0; i < 22; i++) {
      final t = i / 22.0;
      final y = s.height - (s.height - vy) * t * t;
      pt.color = const Color(0xFF6A0DAD).withOpacity(0.04 + 0.05 * (1 - t));
      canvas.drawLine(Offset(0, y), Offset(s.width, y), pt);
    }
    // Radial lines converging to globe center
    for (int i = -12; i <= 12; i++) {
      final bx = vx + i * s.width * 0.055;
      pt.color = const Color(0xFF6A0DAD).withOpacity(0.025);
      canvas.drawLine(Offset(bx, s.height), Offset(vx, vy), pt);
    }
  }

  // ───────────────────────── 4. AMBIENT GLOW ──────────────────────────────
  void _paintAmbientGlow(Canvas canvas, Offset c, double r) {
    final pt = Paint()..style = PaintingStyle.fill;
    // Pulsing intensity
    final pulse = 0.85 + 0.15 * math.sin(p * math.pi * 4);
    for (int i = 0; i < 20; i++) {
      final f = i / 20.0;
      final gr = r * (1.8 - f * 1.0);
      pt.color = const Color(0xFF7B2FBE).withOpacity(0.01 * pulse + f * f * 0.10 * pulse);
      canvas.drawCircle(c, gr, pt);
    }
    // Inner hot core
    for (int i = 0; i < 6; i++) {
      final f = i / 6.0;
      pt.color = const Color(0xFFE040FB).withOpacity(0.015 * (1.0 - f) * pulse);
      canvas.drawCircle(c, r * (0.6 - f * 0.3), pt);
    }
  }

  // ───────────────────────── 5. WIREFRAME ─────────────────────────────────
  void _paintWireframe(Canvas canvas, Offset c, double r, double rot) {
    final pt = Paint()..style = PaintingStyle.stroke..strokeWidth = 0.5;
    // Latitude
    for (int d = -80; d <= 80; d += 18) {
      final lat = d * math.pi / 180;
      final rr = r * math.cos(lat);
      final yy = -r * math.sin(lat);
      pt.color = const Color(0xFF9D4EDD).withOpacity(0.10);
      final pa = Path();
      bool on = false;
      for (int s = 0; s <= 360; s += 3) {
        final lng = s * math.pi / 180;
        final x3 = rr * math.sin(lng), z3 = rr * math.cos(lng);
        final xR = x3 * math.cos(rot) + z3 * math.sin(rot);
        final zR = -x3 * math.sin(rot) + z3 * math.cos(rot);
        if (zR < 0) { on = false; continue; }
        final px = c.dx + xR, py = c.dy + yy;
        if (!on) { pa.moveTo(px, py); on = true; } else { pa.lineTo(px, py); }
      }
      canvas.drawPath(pa, pt);
    }
    // Longitude
    for (int d = 0; d < 360; d += 24) {
      final lng = d * math.pi / 180;
      pt.color = const Color(0xFF9D4EDD).withOpacity(0.07);
      final pa = Path();
      bool on = false;
      for (int s = -90; s <= 90; s += 3) {
        final lat = s * math.pi / 180;
        final x3 = r * math.cos(lat) * math.sin(lng);
        final y3 = -r * math.sin(lat);
        final z3 = r * math.cos(lat) * math.cos(lng);
        final xR = x3 * math.cos(rot) + z3 * math.sin(rot);
        final zR = -x3 * math.sin(rot) + z3 * math.cos(rot);
        if (zR < 0) { on = false; continue; }
        if (!on) { pa.moveTo(c.dx + xR, c.dy + y3); on = true; }
        else { pa.lineTo(c.dx + xR, c.dy + y3); }
      }
      canvas.drawPath(pa, pt);
    }
  }

  // ───────────────────────── 6. GLOBE DOTS ────────────────────────────────
  void _paintGlobeDots(Canvas canvas, Offset c, double r, double rot) {
    const int latN = 34, lngMax = 68;
    final dp = Paint()..style = PaintingStyle.fill;

    for (int li = 0; li < latN; li++) {
      final lat = ((li / (latN - 1)) - 0.5) * math.pi;
      final cL = math.cos(lat), sL = math.sin(lat);
      final rr = r * cL;
      final dots = (lngMax * cL).round().clamp(6, lngMax);

      for (int gi = 0; gi < dots; gi++) {
        final lng = (gi / dots) * 2 * math.pi;
        final x3 = rr * math.sin(lng), y3 = -r * sL, z3 = rr * math.cos(lng);
        final xR = x3 * math.cos(rot) + z3 * math.sin(rot);
        final zR = -x3 * math.sin(rot) + z3 * math.cos(rot);
        if (zR < -r * 0.03) continue;

        final depth = ((zR / r) + 1.0) / 2.0;
        final land = _landMask(lat, lng + rot * 0.1);
        if (!land && depth < 0.55 && (li + gi) % 4 != 0) continue;

        final px = c.dx + xR, py = c.dy + y3;
        final op = land ? 0.30 + depth * 0.70 : 0.10 + depth * 0.22;
        final sz = land ? 0.7 + depth * 1.8 : 0.35 + depth * 0.7;

        // Pulsing nodes: every 7th land dot glows
        final isNode = land && (li * 17 + gi * 13) % 7 == 0;
        final nodePulse = isNode ? 0.5 + 0.5 * math.sin(p * math.pi * 6 + li + gi) : 0.0;

        Color col;
        if (isNode && depth > 0.5) {
          col = Color.lerp(const Color(0xFF00FF87), Colors.white, nodePulse)!;
        } else if (depth > 0.85 && land) {
          col = Color.lerp(const Color(0xFFE2C5FF), Colors.white, (depth - 0.85) / 0.15)!;
        } else {
          col = Color.lerp(
            const Color(0xFF3A0070),
            land ? const Color(0xFFD8B4FE) : const Color(0xFF8A2BE2),
            depth,
          )!;
        }

        dp.color = col.withOpacity((op + nodePulse * 0.3).clamp(0.0, 1.0));
        canvas.drawCircle(Offset(px, py), sz + nodePulse * 1.5, dp);

        // Bright front-face glow
        if (depth > 0.88 && land) {
          dp.color = Colors.white.withOpacity(0.25 * depth);
          canvas.drawCircle(Offset(px, py), sz * 2.0, dp);
        }

        // Node pulse ring
        if (isNode && depth > 0.5) {
          canvas.drawCircle(Offset(px, py), sz * 3.0 + nodePulse * 4.0, Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.6
            ..color = const Color(0xFF00FF87).withOpacity(0.3 * nodePulse));
        }
      }
    }
  }

  bool _landMask(double lat, double lng) {
    return math.sin(lat * 4.2) * math.cos(lng * 2.8) +
        math.cos(lat * 1.8) * math.sin(lng * 5.4) * 0.5 +
        math.sin(lat * 6.5 + lng * 1.8) * 0.3 > 0.12;
  }

  // ───────────────────────── 7. SCAN WAVE ─────────────────────────────────
  void _paintScanWave(Canvas canvas, Offset c, double r, double rot) {
    // A bright vertical plane sweeping across the globe
    final sweepAngle = p * 2 * math.pi * 1.5; // 1.5x rotation speed
    // Draw a glowing vertical line at the sweep position
    final sx = c.dx + r * math.cos(sweepAngle) * 0.98;
    // Vertical sweep bar
    canvas.drawLine(
      Offset(sx, c.dy - r * 0.85),
      Offset(sx, c.dy + r * 0.85),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = const Color(0xFF00FF87).withOpacity(0.08),
    );
    // Wider faint sweep
    canvas.drawLine(
      Offset(sx, c.dy - r * 0.85),
      Offset(sx, c.dy + r * 0.85),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20.0
        ..color = const Color(0xFF00FF87).withOpacity(0.02),
    );
  }

  // ───────────────────────── 8. RIM HALO ──────────────────────────────────
  void _paintRimHalo(Canvas canvas, Offset c, double r) {
    // Multi-layer atmospheric edge
    for (int i = 0; i < 12; i++) {
      final t = 1.0 - i / 12.0;
      canvas.drawCircle(c, r + i * 2.5, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8 - i * 0.2
        ..color = const Color(0xFFBF7FFF).withOpacity(0.35 * t * t));
    }
    // Sharp inner rim
    canvas.drawCircle(c, r, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = const Color(0xFFF3E8FF).withOpacity(0.80));
    // Pink bloom ring
    canvas.drawCircle(c, r + 5, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = const Color(0xFFE040FB).withOpacity(0.12));
  }

  // ───────────────────────── 9. ORBITAL TRAILS ────────────────────────────
  void _paintOrbitalTrails(Canvas canvas, Size s, Offset c, double r, double rot) {
    for (final a in _arcs) {
      final lat = (a.latF - 0.5) * math.pi * 0.6;
      final lng = a.lngF * 2 * math.pi + rot;
      final cL = math.cos(lat);
      final x3 = r * cL * math.sin(lng), y3 = -r * math.sin(lat);
      final z3 = r * cL * math.cos(lng);
      final xR = x3 * math.cos(rot) + z3 * math.sin(rot);
      final zR = -x3 * math.sin(rot) + z3 * math.cos(rot);
      if (zR < 0) continue;

      final start = Offset(c.dx + xR, c.dy + y3);
      final end = Offset(a.exF * s.width, a.eyF * s.height);
      final ctrl = Offset(
        (start.dx + end.dx) / 2 + (end.dy - start.dy) * 0.15,
        math.min(start.dy, end.dy) - 50 - s.height * 0.04,
      );

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy);

      final sp = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
      sp.color = a.col.withOpacity(0.06); sp.strokeWidth = 6; canvas.drawPath(path, sp);
      sp.color = a.col.withOpacity(0.18); sp.strokeWidth = 2.5; canvas.drawPath(path, sp);
      sp.color = a.col.withOpacity(0.65); sp.strokeWidth = 1.0; canvas.drawPath(path, sp);

      // Moving energy particle
      final t = ((p * a.spd * 2.5) % 1.0);
      final mt = 1.0 - t;
      final pp = Offset(
        mt*mt*start.dx + 2*mt*t*ctrl.dx + t*t*end.dx,
        mt*mt*start.dy + 2*mt*t*ctrl.dy + t*t*end.dy,
      );
      final fp = Paint()..style = PaintingStyle.fill;
      fp.color = a.col.withOpacity(0.08); canvas.drawCircle(pp, 10, fp);
      fp.color = a.col.withOpacity(0.25); canvas.drawCircle(pp, 5, fp);
      fp.color = a.col.withOpacity(0.80); canvas.drawCircle(pp, 2.5, fp);
      fp.color = Colors.white; canvas.drawCircle(pp, 1.2, fp);

      // Surface anchor
      fp.color = a.col.withOpacity(0.35); canvas.drawCircle(start, 5, fp);
      fp.color = Colors.white.withOpacity(0.9); canvas.drawCircle(start, 1.8, fp);
    }
  }

  // ───────────────────────── 10. RADAR PULSE ──────────────────────────────
  void _paintRadarPulse(Canvas canvas, Offset c, double r) {
    for (int i = 0; i < 3; i++) {
      final rp = ((p * 1.8 + i * 0.33) % 1.0);
      final rr = r * 0.15 + rp * r * 0.95;
      final op = (1.0 - rp) * 0.18;
      canvas.drawCircle(c, rr, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFF00FF87).withOpacity(op));
    }
  }

  // ───────────────────────── 11. FLOATING PARTICLES ───────────────────────
  void _paintFloatingParticles(Canvas canvas, Size s, Offset c, double r) {
    final fp = Paint()..style = PaintingStyle.fill;
    for (final op in _orb) {
      final angle = op.angF * 2 * math.pi + p * op.spd * 2 * math.pi;
      final dist = r * (1.15 + op.radF * 0.45);
      final px = c.dx + math.cos(angle) * dist;
      final py = c.dy + math.sin(angle) * dist * 0.5; // elliptical
      if (px < 0 || px > s.width || py < 0 || py > s.height) continue;

      final tw = 0.4 + 0.6 * math.sin(p * math.pi * 5 + op.ph);
      fp.color = const Color(0xFFBF7FFF).withOpacity(0.20 * tw);
      canvas.drawCircle(Offset(px, py), op.sz * tw, fp);
      fp.color = Colors.white.withOpacity(0.5 * tw);
      canvas.drawCircle(Offset(px, py), op.sz * 0.4 * tw, fp);
    }
  }

  // ───────────────────────── 12. MATRIX RAIN ──────────────────────────────
  void _paintMatrixRain(Canvas canvas, Size s) {
    final fp = Paint()..style = PaintingStyle.fill;
    for (final rc in _rain) {
      for (int j = 0; j < rc.len; j++) {
        final rawY = (rc.yStart + p * rc.spd + j * 0.02) % 1.2;
        if (rawY > 1.0) continue;
        final x = rc.xFrac * s.width;
        final y = rawY * s.height;
        final fade = (1.0 - j / rc.len) * math.sin(rawY * math.pi);
        fp.color = const Color(0xFF00FF87).withOpacity(0.10 * fade);
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x, y, 5, 7), const Radius.circular(1)),
          fp,
        );
      }
    }
  }

  // ───────────────────────── 13. VIGNETTE ─────────────────────────────────
  void _paintVignette(Canvas canvas, Size s) {
    // Top fade
    canvas.drawRect(
      Rect.fromLTWH(0, 0, s.width, s.height * 0.20),
      Paint()..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Colors.black.withOpacity(0.70), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, s.width, s.height * 0.20)),
    );
    // Bottom fade
    canvas.drawRect(
      Rect.fromLTWH(0, s.height * 0.85, s.width, s.height * 0.15),
      Paint()..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
      ).createShader(Rect.fromLTWH(0, s.height * 0.85, s.width, s.height * 0.15)),
    );
    // Left dark zone (desktop: for branding readability)
    if (wide) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, s.width * 0.35, s.height),
        Paint()..shader = LinearGradient(
          begin: Alignment.centerLeft, end: Alignment.centerRight,
          colors: [Colors.black.withOpacity(0.60), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, 0, s.width * 0.35, s.height)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GlobePainter old) => old.p != p || old.wide != wide;

  // ════════════ STATIC DATA GENERATORS ════════════════════════════════════
  static List<_Star> _genStars(int n, double yMax, double szMax, int seed) {
    final rng = math.Random(seed);
    return List.generate(n, (_) => _Star(
      rng.nextDouble(), rng.nextDouble() * yMax,
      0.4 + rng.nextDouble() * szMax, rng.nextDouble() * math.pi * 2,
    ));
  }

  static List<_Rain> _genRain(int n, int seed) {
    final rng = math.Random(seed);
    return List.generate(n, (_) => _Rain(
      rng.nextDouble(), rng.nextDouble(),
      0.15 + rng.nextDouble() * 0.35, 4 + rng.nextInt(8),
    ));
  }

  static List<_Orb> _genOrbParticles(int n, int seed) {
    final rng = math.Random(seed);
    return List.generate(n, (_) => _Orb(
      rng.nextDouble(), rng.nextDouble(),
      0.08 + rng.nextDouble() * 0.30,
      0.8 + rng.nextDouble() * 2.5, rng.nextDouble() * math.pi * 2,
    ));
  }
}

// ═══════════════════ DATA CLASSES ══════════════════════════════════════════
class _Star { final double x, y, sz, ph; const _Star(this.x, this.y, this.sz, this.ph); }
class _Rain { final double xFrac, yStart, spd; final int len; const _Rain(this.xFrac, this.yStart, this.spd, this.len); }
class _Orb  { final double angF, radF, spd, sz, ph; const _Orb(this.angF, this.radF, this.spd, this.sz, this.ph); }
class _Arc  { final double latF, lngF, exF, eyF, spd; final Color col; const _Arc(this.latF, this.lngF, this.exF, this.eyF, this.col, this.spd); }
