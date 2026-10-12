import 'dart:math' as math;
import 'package:flutter/material.dart';

class ExploreEyebrow extends StatelessWidget {
  final bool dark;
  const ExploreEyebrow({super.key, required this.dark});
  @override
  Widget build(BuildContext context) => SizedBox(
      height: 16,
      child: Align(
          alignment: Alignment.centerLeft,
          child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text('ANOMALY DETECTION · ZERO TRUST · POLICY AUTOMATION',
                  style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w700,
                      fontSize: 8,
                      letterSpacing: 2,
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
      Canvas canvas, Offset center, double rx, double ry, List<Color> colors) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(rx, ry);
    canvas.drawCircle(
        Offset.zero,
        1,
        Paint()
          ..shader = RadialGradient(colors: colors, stops: const [0, .42, 1])
              .createShader(const Rect.fromLTWH(-1, -1, 2, 2)));
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center =
        glowCenter ?? Offset(scene.center.dx, scene.top + scene.height * .48);
    // Feathered light fields terminate inside the scene; stacked copy stays dark.
    field(canvas, center, scene.width * .64, scene.height * .49, [
      const Color(0xFF17452E).withOpacity(dark ? .95 : .12),
      const Color(0xFF0D2119).withOpacity(dark ? .8 : .04),
      Colors.transparent
    ]);
    field(canvas, center, scene.width * .47, scene.height * .43, [
      const Color(0xFFBCDA27).withOpacity(dark ? .68 : .28),
      const Color(0xFF80A416).withOpacity(dark ? .40 : .12),
      Colors.transparent
    ]);
    field(canvas, center, scene.width * .23, scene.height * .32, [
      const Color(0xFFC4E326).withOpacity(dark ? .46 : .16),
      const Color(0xFF80A416).withOpacity(dark ? .16 : .06),
      Colors.transparent
    ]);
    field(canvas, center.translate(scene.width * .24, -scene.height * .05),
        scene.width * .12, scene.height * .44, [
      const Color(0xFFB1A9DA).withOpacity(dark ? .15 : .08),
      const Color(0xFFCFE6F2).withOpacity(dark ? .04 : .025),
      Colors.transparent
    ]);
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

/// Vector shield and live typography: no raster background in either theme.
class AutoPolicyWordmark extends StatelessWidget {
  final bool dark;
  const AutoPolicyWordmark({super.key, required this.dark});
  @override
  Widget build(BuildContext context) => FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
        child: Row(children: [
          CustomPaint(size: const Size(48, 54), painter: _Shield(dark)),
          const SizedBox(width: 10),
          Text('AutoPolicy',
              style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: dark
                      ? const Color(0xFFD6DBD9)
                      : const Color(0xFF26321B))),
        ]),
      );
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
    final reduced = MediaQuery.of(context).disableAnimations;
    final lines = text.split('\n');
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
                          child: Text(lines[i],
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                fontWeight: FontWeight.w800,
                                fontSize: size,
                                height: 1.14,
                                letterSpacing: -1,
                                fontStyle: i > 0 && emphasize
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                                color: i > 0
                                    ? Color.lerp(foreground, accent, t)
                                    : foreground,
                                shadows: i > 0 &&
                                        emphasize &&
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                    ? [
                                        Shadow(
                                            color: accent
                                                .withOpacity(.16 * (1 - t)),
                                            blurRadius: 16)
                                      ]
                                    : null,
                              )))));
            }),
          ),
        )));
  }
}
