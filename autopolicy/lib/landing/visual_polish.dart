import 'dart:math' as math;
import 'package:flutter/material.dart';

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
  const HeroHeading(
      {super.key,
      required this.text,
      required this.foreground,
      required this.accent,
      required this.size,
      required this.emphasize});
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
          duration: Duration(milliseconds: reduced ? 0 : 400),
          builder: (context, value, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(lines.length, (i) {
              final t = Curves.easeOutCubic.transform(
                  ((value - i * .18) / (1 - i * .18)).clamp(0.0, 1.0));
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
