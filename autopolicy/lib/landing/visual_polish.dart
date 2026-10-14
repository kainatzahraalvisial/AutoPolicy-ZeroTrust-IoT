import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/cyber_stencil_title.dart';
import '../theme/colors.dart';

class ExploreEyebrow extends StatelessWidget {
  final bool dark;
  final double fontSize;
  const ExploreEyebrow({super.key, required this.dark, this.fontSize = 9.5});
  @override
  Widget build(BuildContext context) => SizedBox(
      height: 20,
      child: Align(
          alignment: Alignment.centerLeft,
          child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text('ANOMALY DETECTION · ZERO TRUST · POLICY AUTOMATION',
                  style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w700,
                      fontSize: fontSize,
                      letterSpacing: 2.2,
                      color: dark
                          ? const Color(0xFFC5C764)
                          : const Color(0xFF526B0E))))));
}

/// Delay belongs to the presentation only; telemetry never restarts the reveal.
class HeroEntrance extends StatelessWidget {
  final Widget child;
  final int delay;
  final double distance;
  const HeroEntrance(
      {super.key, required this.child, this.delay = 0, this.distance = 12});
  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    final total = delay + 620;
    return TweenAnimationBuilder<double>(
        tween: Tween(begin: reduced ? 1 : 0, end: 1),
        duration: Duration(milliseconds: reduced ? 0 : total),
        child: child,
        builder: (context, value, child) {
          final t = reduced
              ? 1.0
              : Curves.easeOutCubic
                  .transform(((value * total - delay) / 620).clamp(0.0, 1.0));
          return IgnorePointer(
              ignoring: t < .05,
              child: Opacity(
                  opacity: t,
                  child: Transform.translate(
                      offset: Offset(0, distance * (1 - t)), child: child)));
        });
  }
}

/// Invisible suffix reserves the final line breaks and height from frame one.
class TypingParagraph extends StatelessWidget {
  final String text;
  final TextStyle style;
  final int delay;
  const TypingParagraph(
      {super.key, required this.text, required this.style, this.delay = 0});
  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    final characters = text.characters.toList();
    final total = delay + characters.length * 22;
    return Semantics(
        label: text,
        child: ExcludeSemantics(
            child: TweenAnimationBuilder<double>(
                key: ValueKey(text),
                tween: Tween(begin: reduced ? 1 : 0, end: 1),
                duration: Duration(milliseconds: reduced ? 0 : total),
                builder: (context, value, _) {
                  final count = reduced
                      ? characters.length
                      : ((value * total - delay) / 22)
                          .floor()
                          .clamp(0, characters.length);
                  return Text.rich(TextSpan(style: style, children: [
                    TextSpan(text: characters.take(count).join()),
                    TextSpan(
                        text: characters.skip(count).join(),
                        style: const TextStyle(color: Colors.transparent)),
                  ]));
                })));
  }
}

/// Static atmosphere is cheap, non-interactive, and continuous behind the iframe.
class HeroAtmosphere extends StatelessWidget {
  final Rect scene;
  final bool dark;
  final Offset? glowCenter;
  const HeroAtmosphere(
      {super.key, required this.scene, required this.dark, this.glowCenter});
  @override
  Widget build(BuildContext context) => IgnorePointer(
      child: RepaintBoundary(
          child: CustomPaint(
              painter: _Atmosphere(scene, dark, glowCenter),
              size: Size.infinite)));
}

class _Atmosphere extends CustomPainter {
  final Rect scene;
  final bool dark;
  final Offset? glowCenter;
  const _Atmosphere(this.scene, this.dark, this.glowCenter);

  void field(
      Canvas canvas, Offset center, double rx, double ry, List<Color> colors,
      [List<double>? stops]) {
    if (rx <= 0 || ry <= 0) return;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(rx, ry);
    canvas.drawCircle(
        Offset.zero,
        1,
        Paint()
          ..shader = RadialGradient(
            colors: colors,
            stops: stops ?? const [0.0, 0.45, 1.0],
          ).createShader(const Rect.fromLTWH(-1, -1, 2, 2)));
    canvas.restore();
  }

  void _drawVerticalBeam(Canvas canvas, double x, double top, double bottom,
      double width, Color color, double opacity,
      {double blur = 18}) {
    if (opacity <= 0 || bottom <= top) return;
    final rect = Rect.fromLTWH(x - width / 2, top, width, bottom - top);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          color.withOpacity(opacity * 0.35),
          color.withOpacity(opacity),
          color.withOpacity(opacity * 0.75),
          Colors.transparent,
        ],
        stops: const [0.0, 0.18, 0.55, 0.85, 1.0],
      ).createShader(rect)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    canvas.drawRect(rect, paint);
  }

  void _drawHoloGlassPanel(
    Canvas canvas,
    Rect rect,
    Color color,
    double fillOpacity,
    double borderOpacity, {
    double skewY = -0.22,
  }) {
    final path = Path()
      ..moveTo(rect.left, rect.top - rect.width * skewY * 0.5)
      ..lineTo(rect.right, rect.top + rect.width * skewY * 0.5)
      ..lineTo(rect.right, rect.bottom + rect.width * skewY * 0.5)
      ..lineTo(rect.left, rect.bottom - rect.width * skewY * 0.5)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(fillOpacity * 0.35),
          color.withOpacity(fillOpacity),
          color.withOpacity(fillOpacity * 0.10),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);
    canvas.drawPath(path, fillPaint);

    // Crisp luminous top & side edges of the holographic glass plane
    final edgePath = Path()
      ..moveTo(rect.left, rect.bottom - rect.width * skewY * 0.5)
      ..lineTo(rect.left, rect.top - rect.width * skewY * 0.5)
      ..lineTo(rect.right, rect.top + rect.width * skewY * 0.5)
      ..lineTo(rect.right, rect.bottom + rect.width * skewY * 0.5);
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFE6FF68).withOpacity(borderOpacity),
          color.withOpacity(borderOpacity * 0.55),
          Colors.transparent,
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(rect);
    canvas.drawPath(edgePath, edgePaint);
  }

  void _drawStarPoint(
      Canvas canvas, Offset pos, double radius, Color color, double opacity,
      {bool cross = false}) {
    canvas.drawCircle(
      pos,
      radius * 3.2,
      Paint()
        ..color = color.withOpacity(opacity * 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(
      pos,
      radius,
      Paint()..color = const Color(0xFFF2FF9B).withOpacity(opacity),
    );
    if (cross) {
      final p = Paint()
        ..color = color.withOpacity(opacity * 0.55)
        ..strokeWidth = 0.8;
      canvas.drawLine(
          pos.translate(-radius * 3.5, 0), pos.translate(radius * 3.5, 0), p);
      canvas.drawLine(
          pos.translate(0, -radius * 3.5), pos.translate(0, radius * 3.5), p);
    }
  }

  void paintLightEnvironment(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                LandingLightPalette.canvas,
                LandingLightPalette.canvas,
                LandingLightPalette.ivory
              ],
              stops: [
                0,
                .62,
                1
              ]).createShader(rect));
    final center =
        glowCenter ?? Offset(scene.center.dx, scene.top + scene.height * .48);
    // Separate pastel fields give the light environment depth without a green veil.
    field(canvas, center, scene.width * .65, scene.height * .72, [
      const Color(0xFFB7EAB9).withOpacity(.60),
      LandingLightPalette.mint.withOpacity(.36),
      LandingLightPalette.mint.withOpacity(0)
    ], const [
      0,
      .46,
      1
    ]);
    field(canvas, Offset(size.width * .95, size.height * .07), size.width * .43,
        size.height * .52, [
      LandingLightPalette.violet.withOpacity(.32),
      LandingLightPalette.lavender.withOpacity(.40),
      LandingLightPalette.lavender.withOpacity(0)
    ], const [
      0,
      .40,
      1
    ]);
    field(canvas, Offset(size.width * .07, size.height * .93), size.width * .40,
        size.height * .45, [
      const Color(0xFFF9D3E1).withOpacity(.45),
      LandingLightPalette.blush.withOpacity(.32),
      LandingLightPalette.blush.withOpacity(0)
    ], const [
      0,
      .45,
      1
    ]);
    field(canvas, Offset(size.width * .90, size.height), size.width * .44,
        size.height * .45, [
      const Color(0xFFBDE8ED).withOpacity(.46),
      LandingLightPalette.cyan.withOpacity(.30),
      LandingLightPalette.cyan.withOpacity(0)
    ], const [
      0,
      .42,
      1
    ]);
    // A small floor glow follows the model, independently of the broad backdrop.
    field(canvas, Offset(scene.center.dx, scene.top + scene.height * .76),
        scene.width * .40, scene.height * .15, [
      LandingLightPalette.paleLime.withOpacity(.55),
      LandingLightPalette.chartreuse.withOpacity(.14),
      LandingLightPalette.paleLime.withOpacity(0)
    ], const [
      0,
      .45,
      1
    ]);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    if (!dark) {
      paintLightEnvironment(canvas, size);
      return;
    }
    final isPortrait = size.height > size.width || size.width < 900;
    final fullRect = Offset.zero & size;

    // ─────────────────────────────────────────────────────────────────────────
    // 1. BASE LAYER: Deep obsidian / cyber green-black foundation
    // ─────────────────────────────────────────────────────────────────────────
    final baseGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: dark
          ? const [
              Color(0xFF040604),
              Color(0xFF060E07),
              Color(0xFF071409),
              Color(0xFF06160B),
              Color(0xFF041008),
            ]
          : const [
              Color(0xFFFAF9F6),
              Color(0xFFF4F6EE),
              Color(0xFFE9EFE2),
            ],
      stops: dark ? const [0.0, 0.28, 0.58, 0.82, 1.0] : const [0.0, 0.5, 1.0],
    );
    canvas.drawRect(
        fullRect, Paint()..shader = baseGradient.createShader(fullRect));

    final center =
        glowCenter ?? Offset(scene.center.dx, scene.top + scene.height * 0.48);
    final double scale = dark ? 1.0 : 0.45;

    // ─────────────────────────────────────────────────────────────────────────
    // 2. FAINT CYBER COORDINATE GRID & STARFIELD NODES
    // ─────────────────────────────────────────────────────────────────────────
    if (dark) {
      final gridPaint = Paint()
        ..color = const Color(0xFF88B81A).withOpacity(0.028)
        ..strokeWidth = 0.7;
      const double step = 88.0;
      for (double x = step; x < size.width; x += step) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }
      for (double y = step; y < size.height; y += step) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 3. AMBIENT ENVIRONMENTAL WASH & BOTTOM-RIGHT CORNER ILLUMINATION
    // ─────────────────────────────────────────────────────────────────────────
    field(
      canvas,
      center,
      scene.width * 0.68,
      scene.height * 0.58,
      [
        const Color(0xFF3E5E08).withOpacity(0.45 * scale),
        const Color(0xFF1A2E05).withOpacity(0.26 * scale),
        Colors.transparent,
      ],
      const [0.0, 0.48, 1.0],
    );

    // Bottom-right warm chartreuse corner wash (matches reference bottom-right glow)
    field(
      canvas,
      Offset(size.width * 0.90, size.height * 0.92),
      size.width * 0.36,
      size.height * 0.34,
      [
        const Color(0xFF80A416).withOpacity(0.42 * scale),
        const Color(0xFF435B09).withOpacity(0.20 * scale),
        Colors.transparent,
      ],
      const [0.0, 0.45, 1.0],
    );

    // Bottom-center-left subtle green floor reflection under buttons/platform
    field(
      canvas,
      Offset(size.width * 0.56, size.height * 0.94),
      size.width * 0.34,
      size.height * 0.22,
      [
        const Color(0xFF6B9612).withOpacity(0.22 * scale),
        Colors.transparent,
      ],
      const [0.0, 1.0],
    );

    // ─────────────────────────────────────────────────────────────────────────
    // 4. HOLOGRAPHIC VERTICAL LIGHT COLUMNS & TRANSLUCENT GLASS PLANES BEHIND 3D MODEL
    // ─────────────────────────────────────────────────────────────────────────
    final double modelTop = center.dy - scene.height * 0.42;
    final double modelMidY = center.dy + scene.height * 0.08;

    // Soft rising chartreuse light beams behind the central tower and side nodes
    _drawVerticalBeam(
        canvas,
        center.dx - scene.width * 0.22,
        modelTop + scene.height * 0.06,
        modelMidY,
        scene.width * 0.14,
        const Color(0xFFA8DC1E),
        0.30 * scale,
        blur: 22);
    _drawVerticalBeam(
        canvas,
        center.dx - scene.width * 0.04,
        modelTop - scene.height * 0.04,
        modelMidY,
        scene.width * 0.18,
        const Color(0xFFC8F528),
        0.38 * scale,
        blur: 24);
    _drawVerticalBeam(
        canvas,
        center.dx + scene.width * 0.15,
        modelTop,
        modelMidY + scene.height * 0.04,
        scene.width * 0.16,
        const Color(0xFFB4E622),
        0.34 * scale,
        blur: 20);
    _drawVerticalBeam(
        canvas,
        center.dx + scene.width * 0.30,
        modelTop + scene.height * 0.10,
        modelMidY + scene.height * 0.06,
        scene.width * 0.12,
        const Color(0xFF88BD16),
        0.26 * scale,
        blur: 18);

    // Crisp vertical laser light streaks rising behind the tower
    for (final dxFactor in [-0.25, -0.14, -0.06, 0.07, 0.16, 0.24, 0.33]) {
      _drawVerticalBeam(
        canvas,
        center.dx + scene.width * dxFactor,
        center.dy - scene.height * (0.36 - dxFactor.abs() * 0.25),
        center.dy + scene.height * 0.04,
        3.5,
        const Color(0xFFE6FF66),
        0.38 * scale,
        blur: 3.5,
      );
    }

    // Isometric translucent holographic glass panels behind the 3D tower (matching reference)
    if (!isPortrait) {
      // Back-right tall holographic glass panel
      _drawHoloGlassPanel(
        canvas,
        Rect.fromLTWH(
          center.dx + scene.width * 0.08,
          center.dy - scene.height * 0.35,
          scene.width * 0.095,
          scene.height * 0.28,
        ),
        const Color(0xFFB8EC24),
        0.16 * scale,
        0.42 * scale,
        skewY: 0.26,
      );
      // Far-right mid holographic glass panel
      _drawHoloGlassPanel(
        canvas,
        Rect.fromLTWH(
          center.dx + scene.width * 0.21,
          center.dy - scene.height * 0.23,
          scene.width * 0.13,
          scene.height * 0.24,
        ),
        const Color(0xFFA2D81C),
        0.15 * scale,
        0.36 * scale,
        skewY: 0.26,
      );
      // Left-side stepped holographic glass panel
      _drawHoloGlassPanel(
        canvas,
        Rect.fromLTWH(
          center.dx - scene.width * 0.33,
          center.dy - scene.height * 0.14,
          scene.width * 0.08,
          scene.height * 0.14,
        ),
        const Color(0xFFB8EC24),
        0.14 * scale,
        0.34 * scale,
        skewY: -0.24,
      );
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 5. PRIMARY CORE GLOW BEHIND THE 3D MODEL & UNDER-PLATFORM FLARES
    // ─────────────────────────────────────────────────────────────────────────
    // Central intense chartreuse-lime aura
    field(
      canvas,
      center.translate(0, -scene.height * 0.04),
      scene.width * 0.44,
      scene.height * 0.40,
      [
        const Color(0xFFC4E326).withOpacity(0.58 * scale),
        const Color(0xFF88B416).withOpacity(0.34 * scale),
        const Color(0xFF476309).withOpacity(0.12 * scale),
        Colors.transparent,
      ],
      const [0.0, 0.35, 0.68, 1.0],
    );

    // Bright specular heart behind tower
    field(
      canvas,
      center.translate(0, -scene.height * 0.06),
      scene.width * 0.22,
      scene.height * 0.24,
      [
        const Color(0xFFE8FF72).withOpacity(0.54 * scale),
        const Color(0xFFC4E326).withOpacity(0.32 * scale),
        Colors.transparent,
      ],
      const [0.0, 0.42, 1.0],
    );

    // Under-platform Left Corner Neon Flare (matches the bright green streak at left corner of base)
    final leftBaseFlare = Offset(
      center.dx - scene.width * 0.39,
      center.dy + scene.height * 0.09,
    );
    field(
      canvas,
      leftBaseFlare,
      scene.width * 0.14,
      scene.height * 0.07,
      [
        const Color(0xFFDFFF4F).withOpacity(0.55 * scale),
        const Color(0xFF8CC418).withOpacity(0.24 * scale),
        Colors.transparent,
      ],
      const [0.0, 0.42, 1.0],
    );
    // Crisp diagonal light streak at left base corner
    final flareLinePaint = Paint()
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0)
      ..color = const Color(0xFFEAFF75).withOpacity(0.70 * scale);
    canvas.drawLine(
      leftBaseFlare.translate(-scene.width * 0.05, scene.height * 0.025),
      leftBaseFlare.translate(scene.width * 0.04, -scene.height * 0.02),
      flareLinePaint,
    );

    // Under-platform Bottom-Left & Bottom-Center downward light bursts
    final bottomLeftBurst = Offset(
      center.dx - scene.width * 0.15,
      center.dy + scene.height * 0.29,
    );
    field(
      canvas,
      bottomLeftBurst,
      scene.width * 0.07,
      scene.height * 0.13,
      [
        const Color(0xFFD8FF44).withOpacity(0.50 * scale),
        const Color(0xFF7CB214).withOpacity(0.20 * scale),
        Colors.transparent,
      ],
      const [0.0, 0.40, 1.0],
    );

    final bottomApexBurst = Offset(
      center.dx - scene.width * 0.02,
      center.dy + scene.height * 0.41,
    );
    field(
      canvas,
      bottomApexBurst,
      scene.width * 0.08,
      scene.height * 0.15,
      [
        const Color(0xFFBFF028).withOpacity(0.36 * scale),
        const Color(0xFF638E0E).withOpacity(0.14 * scale),
        Colors.transparent,
      ],
      const [0.0, 0.45, 1.0],
    );

    // ─────────────────────────────────────────────────────────────────────────
    // 6. LUMINOUS PLANETARY DOME RIM ARC BEHIND THE 3D MODEL (Top-Left to Top-Right)
    // ─────────────────────────────────────────────────────────────────────────
    final domeRect = Rect.fromCenter(
      center: Offset(
        center.dx + scene.width * 0.03,
        center.dy + scene.height * 0.08,
      ),
      width: scene.width * 0.96,
      height: scene.height * 0.94,
    );

    // 6a. Misty green nebula clouds along the inside of the upper-left dome rim
    for (final double deg in [195, 212, 230, 248, 266, 284]) {
      final double rad = deg * math.pi / 180.0;
      final Offset cloudPos = Offset(
        domeRect.center.dx + (domeRect.width * 0.46) * math.cos(rad),
        domeRect.center.dy + (domeRect.height * 0.46) * math.sin(rad),
      );
      field(
        canvas,
        cloudPos,
        scene.width * 0.14,
        scene.height * 0.11,
        [
          const Color(0xFFB8EC26).withOpacity(0.32 * scale),
          const Color(0xFF72A312).withOpacity(0.15 * scale),
          Colors.transparent,
        ],
        const [0.0, 0.48, 1.0],
      );
    }

    // 6b. Wide outer atmospheric bloom along the dome arc (165° -> 335°)
    const double domeStart = 162 * math.pi / 180.0;
    const double domeSweep = 172 * math.pi / 180.0;
    final domeShader = SweepGradient(
      center: Alignment.center,
      startAngle: 0,
      endAngle: math.pi * 2,
      colors: [
        Colors.transparent,
        const Color(0xFF78B012).withOpacity(0.05 * scale),
        const Color(0xFFB8F024).withOpacity(0.75 * scale),
        const Color(0xFFEAFF70).withOpacity(0.95 * scale),
        const Color(0xFFC4F228).withOpacity(0.80 * scale),
        const Color(0xFF82B816).withOpacity(0.32 * scale),
        Colors.transparent,
      ],
      stops: const [0.0, 0.44, 0.54, 0.64, 0.74, 0.88, 1.0],
    ).createShader(domeRect);

    // Wide soft glow around the dome arc
    canvas.drawArc(
      domeRect,
      domeStart,
      domeSweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 26.0
        ..shader = domeShader
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    // Medium neon bloom along the dome arc
    canvas.drawArc(
      domeRect,
      domeStart,
      domeSweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0
        ..shader = domeShader
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Razor-sharp intense lime-white core rim line
    canvas.drawArc(
      domeRect,
      domeStart,
      domeSweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..shader = domeShader,
    );

    // ─────────────────────────────────────────────────────────────────────────
    // 7. SWEEPING ORBITAL LIGHT LINES & INTERSECTING ASTRO RINGS (Circled in user ref)
    // ─────────────────────────────────────────────────────────────────────────
    // 7a. Outer Left-to-Top sweeping orbital line (grazes top of dome with bright flare)
    final outerOrbitRect = Rect.fromCenter(
      center: Offset(
        center.dx + scene.width * 0.16,
        center.dy + scene.height * 0.16,
      ),
      width: scene.width * 1.36,
      height: scene.height * 1.24,
    );
    canvas.drawArc(
      outerOrbitRect,
      148 * math.pi / 180.0,
      145 * math.pi / 180.0,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.15
        ..color = const Color(0xFFC8F53B).withOpacity(0.38 * scale),
    );
    // Tangent flare where outer orbit meets top of dome
    _drawStarPoint(
      canvas,
      Offset(center.dx - scene.width * 0.03, domeRect.top + 3),
      2.6,
      const Color(0xFFE8FF6B),
      0.85 * scale,
      cross: true,
    );

    // 7b. Top-Right intersecting diagonal/curved light ray
    final topRightRayPath = Path()
      ..moveTo(center.dx - scene.width * 0.06, 0)
      ..quadraticBezierTo(
        center.dx + scene.width * 0.22,
        center.dy - scene.height * 0.34,
        size.width,
        center.dy - scene.height * 0.04,
      );
    canvas.drawPath(
      topRightRayPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = const Color(0xFFC4E834).withOpacity(0.34 * scale),
    );
    // Secondary steeper top-right orbital arc
    final topRightSteepPath = Path()
      ..moveTo(center.dx + scene.width * 0.10, 0)
      ..quadraticBezierTo(
        center.dx + scene.width * 0.16,
        center.dy - scene.height * 0.22,
        center.dx + scene.width * 0.44,
        center.dy + scene.height * 0.12,
      );
    canvas.drawPath(
      topRightSteepPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..color = const Color(0xFFA8D41E).withOpacity(0.24 * scale),
    );

    // 7c. Bottom-Left sweeping concentric elliptical orbital rings (below Explore / View Architecture)
    final bottomLeftOrbit1 = Rect.fromCenter(
      center: Offset(size.width * 0.24, size.height * 1.08),
      width: size.width * 0.46,
      height: size.height * 0.62,
    );
    canvas.drawArc(
      bottomLeftOrbit1,
      195 * math.pi / 180.0,
      145 * math.pi / 180.0,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = const Color(0xFFA6D41D).withOpacity(0.24 * scale),
    );

    final bottomLeftOrbit2 = Rect.fromCenter(
      center: Offset(size.width * 0.30, size.height * 1.15),
      width: size.width * 0.66,
      height: size.height * 0.84,
    );
    canvas.drawArc(
      bottomLeftOrbit2,
      190 * math.pi / 180.0,
      150 * math.pi / 180.0,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..color = const Color(0xFF94C018).withOpacity(0.16 * scale),
    );

    // Sweeping arc connecting lower-left under buttons toward lower-center of platform
    final lowerSweepPath = Path()
      ..moveTo(size.width * 0.42, size.height * 0.68)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.86,
        size.width * 0.68,
        size.height,
      );
    canvas.drawPath(
      lowerSweepPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = const Color(0xFFACE020).withOpacity(0.26 * scale),
    );

    // 7d. Bottom-Right Bright Neon Energy Sweep (under the right edge of 3D platform)
    final brSweepPath = Path()
      ..moveTo(size.width * 0.69, size.height)
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height * 0.88,
        size.width * 0.99,
        size.height * 0.72,
      );
    // Outer blur glow for bottom-right sweep
    canvas.drawPath(
      brSweepPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0
        ..color = const Color(0xFFB4EC22).withOpacity(0.42 * scale)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // Crisp bright lime-yellow core for bottom-right sweep
    canvas.drawPath(
      brSweepPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = const Color(0xFFEAFF70).withOpacity(0.85 * scale),
    );

    // Secondary parallel bottom-right orbital line
    final brSweepOuter = Path()
      ..moveTo(size.width * 0.78, size.height)
      ..quadraticBezierTo(
        size.width * 0.89,
        size.height * 0.92,
        size.width,
        size.height * 0.82,
      );
    canvas.drawPath(
      brSweepOuter,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = const Color(0xFFC4EE38).withOpacity(0.35 * scale),
    );

    // ─────────────────────────────────────────────────────────────────────────
    // 8. GLOWING STAR SPECKS & TECH INTERSECTION DOTS
    // ─────────────────────────────────────────────────────────────────────────
    if (dark) {
      final stars = <List<double>>[
        [0.27, 0.08, 1.8],
        [0.25, 0.18, 1.3],
        [0.44, 0.20, 1.5],
        [0.43, 0.36, 1.4],
        [0.46, 0.67, 1.7],
        [0.47, 0.89, 1.5],
        [0.52, 0.82, 1.3],
        [0.84, 0.89, 1.8],
        [0.95, 0.50, 1.6],
        [0.97, 0.42, 1.4],
      ];
      for (final s in stars) {
        _drawStarPoint(
          canvas,
          Offset(size.width * s[0], size.height * s[1]),
          s[2],
          const Color(0xFFD6FF4B),
          0.75,
        );
      }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 9. SUBTLE VIGNETTE & TEXT CONTRAST PROTECTION
    // ─────────────────────────────────────────────────────────────────────────
    if (!isPortrait && dark) {
      final textShieldRect = Rect.fromLTWH(
          0, size.height * 0.18, size.width * 0.42, size.height * 0.56);
      final textShieldGradient = RadialGradient(
        center: const Alignment(-0.35, 0.0),
        radius: 0.95,
        colors: [
          const Color(0xFF050705).withOpacity(0.45),
          Colors.transparent,
        ],
      );
      canvas.drawRect(textShieldRect,
          Paint()..shader = textShieldGradient.createShader(textShieldRect));
    }
  }

  @override
  bool shouldRepaint(_Atmosphere old) =>
      old.scene != scene || old.dark != dark || old.glowCenter != glowCenter;
}

/// One short entrance timeline per chapter/stage; progress ticks never restart it.
class StaggeredCopy extends StatelessWidget {
  final List<Widget> children;
  const StaggeredCopy({super.key, required this.children});
  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduced ? 1 : 0, end: 1),
      duration: Duration(milliseconds: reduced ? 0 : 400),
      builder: (context, value, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(children.length, (i) {
          if (children[i] is SizedBox) return children[i];
          final start = math.min(i * .035, .32);
          final t = Curves.easeOutCubic
              .transform(((value - start) / (1 - start)).clamp(0.0, 1.0));
          return Opacity(
              opacity: t,
              child: Transform.translate(
                  offset: Offset(0, 9 * (1 - t)), child: children[i]));
        }),
      ),
    );
  }
}

/// Theme-adaptive PNG wordmark logo
class AutoPolicyWordmark extends StatelessWidget {
  final bool dark;
  final double? height;
  final double? width;
  const AutoPolicyWordmark(
      {super.key, required this.dark, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    final imagePath =
        dark ? 'assets/images/logo_dark.png' : 'assets/images/logo_light.png';
    return Image.asset(
      imagePath,
      height: height,
      width: width,
      alignment: Alignment.centerLeft,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      isAntiAlias: true,
      errorBuilder: (ctx, err, stack) => Image.asset(
        dark
            ? 'assets/images/exec-2772fd73-2c51-4a0f-b67f-bddddac23aa0.png'
            : 'assets/images/exec-d66326b0-56de-4c49-b9b6-8532701a0611.png',
        height: height,
        width: width,
        alignment: Alignment.centerLeft,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        isAntiAlias: true,
      ),
    );
  }
}

class _Shield extends CustomPainter {
  final bool dark;
  const _Shield(this.dark);
  @override
  void paint(Canvas canvas, Size size) {
    final green = dark ? const Color(0xFFBCDA27) : const Color(0xFF80A416);
    final metal = dark ? const Color(0xFFD6DBD9) : const Color(0xFF5E7343);
    final shield = Path()
      ..moveTo(24, 2)
      ..lineTo(45, 11)
      ..lineTo(44, 31)
      ..quadraticBezierTo(42, 42, 24, 52)
      ..quadraticBezierTo(6, 42, 4, 31)
      ..lineTo(3, 11)
      ..close();
    canvas.drawPath(shield, Paint()..color = green.withOpacity(.06));
    canvas.drawPath(
        shield,
        Paint()
          ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [metal, green, metal]).createShader(Offset.zero & size)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);
    const center = Offset(24, 26);
    const nodes = [
      Offset(24, 11),
      Offset(12, 20),
      Offset(36, 20),
      Offset(10, 34),
      Offset(38, 34),
      Offset(24, 44)
    ];
    final wire = Paint()
      ..color = green
      ..strokeWidth = 1.5;
    for (final point in nodes) {
      canvas.drawLine(center, point, wire);
    }
    final network = Path()
      ..moveTo(24, 11)
      ..lineTo(12, 20)
      ..lineTo(10, 34)
      ..lineTo(24, 44)
      ..lineTo(38, 34)
      ..lineTo(36, 20)
      ..close();
    canvas.drawPath(
        network,
        Paint()
          ..color = metal.withOpacity(.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
    for (final point in nodes) {
      canvas.drawCircle(point, 2.6, Paint()..color = metal);
      canvas.drawCircle(point.translate(-.5, -.5), 1,
          Paint()..color = dark ? Colors.white : const Color(0xFFCDD4B2));
    }
    canvas.drawCircle(
        center,
        6,
        Paint()
          ..shader = RadialGradient(colors: [
            dark ? const Color(0xFFE4FF9B) : const Color(0xFFBFD46D),
            green
          ]).createShader(Rect.fromCircle(center: center, radius: 6)));
  }

  @override
  bool shouldRepaint(_Shield oldDelegate) => oldDelegate.dark != dark;
}

/// Independently masked lines settle into place; no perpetual distracting loop.
class HeroHeading extends StatelessWidget {
  final String text;
  final Color foreground, accent;
  final double size;
  final bool emphasize;
  final int delay;
  const HeroHeading(
      {super.key,
      required this.text,
      required this.foreground,
      required this.accent,
      required this.size,
      required this.emphasize,
      this.delay = 0});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduced = MediaQuery.of(context).disableAnimations;
    final lines = text.split('\n');

    final bool isEveryDeviceHero =
        text.toLowerCase().contains('every device') ||
            text.toLowerCase().contains('zero trust') ||
            (emphasize && text.startsWith('Detect. Respond.'));
    if (emphasize && isEveryDeviceHero) {
      return CyberStencilHeroTitle(
        firstLine: lines.isNotEmpty ? lines[0] : 'EVERY DEVICE',
        secondLine: lines.length > 1 ? lines[1] : 'ZERO TRUST',
        primaryColor: foreground,
        accentColor: accent,
      );
    }

    final purpleColor =
        isDark ? const Color(0xFF9D8DF1) : const Color(0xFF7C3AED);

    return Semantics(
        label: text,
        child: ExcludeSemantics(
            child: TweenAnimationBuilder<double>(
          key: ValueKey(text),
          tween: Tween(begin: reduced ? 1 : 0, end: 1),
          duration: Duration(milliseconds: reduced ? 0 : delay + 820),
          builder: (context, value, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(lines.length, (i) {
              final elapsed = value * (delay + 820);
              final t = reduced
                  ? 1.0
                  : Curves.easeOutCubic.transform(
                      ((elapsed - delay - i * 160) / 580).clamp(0.0, 1.0));
              return ClipRect(
                  child: Opacity(
                      opacity: t,
                      child: Transform.translate(
                          offset: Offset(0, 24 * (1 - t)),
                          child: Text.rich(
                            TextSpan(
                              children: _buildHighlightedSpans(
                                line: lines[i],
                                baseColor: foreground,
                                purpleColor: purpleColor,
                                isDark: isDark,
                              ),
                            ),
                            style: TextStyle(
                              fontFamily: 'Oxanium',
                              fontWeight: FontWeight.w800,
                              fontSize: size,
                              height: 1.15,
                              letterSpacing: -0.4,
                            ),
                          ))));
            }),
          ),
        )));
  }

  static List<InlineSpan> _buildHighlightedSpans({
    required String line,
    required Color baseColor,
    required Color purpleColor,
    required bool isDark,
  }) {
    final words = line.split(' ');
    if (words.isEmpty)
      return [TextSpan(text: line, style: TextStyle(color: baseColor))];

    const targetKeywords = {
      'network',
      'behaves',
      'security',
      'intelligence',
      'abnormal',
      'relationships',
      'normally',
      'policy',
      'decision',
      'connection',
      'infrastructure',
      'devices',
      'emerges',
      'separate',
      'enforce',
      'protect',
      'protected',
      'zero',
      'trust',
      'telemetry',
      'detection',
      'layer',
      'observation',
      'extraction',
      'generation',
      'segmentation',
      'dashboard',
      'patterns',
      'external',
      'malicious',
      'infected',
      'exploration',
      'access'
    };

    final List<int> highlightIndices = [];
    for (int w = 0; w < words.length; w++) {
      final clean = words[w].toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      if (targetKeywords.contains(clean)) {
        highlightIndices.add(w);
        if (highlightIndices.length >= 2) break;
      }
    }

    if (highlightIndices.isEmpty && words.isNotEmpty) {
      highlightIndices.add(words.length - 1);
    }

    final List<InlineSpan> spans = [];
    for (int w = 0; w < words.length; w++) {
      final isHighlighted = highlightIndices.contains(w);
      final wordText = words[w] + (w < words.length - 1 ? ' ' : '');
      spans.add(
        TextSpan(
          text: wordText,
          style: TextStyle(
            color: isHighlighted ? purpleColor : baseColor,
          ),
        ),
      );
    }
    return spans;
  }
}
