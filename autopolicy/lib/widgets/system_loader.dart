import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A resolution-independent light ribbon, drawn entirely in code.
class SystemLoader extends StatefulWidget {
  final String label;
  const SystemLoader({super.key, this.label = 'Loading AutoPolicy…'});
  @override
  State<SystemLoader> createState() => _SystemLoaderState();
}

class _SystemLoaderState extends State<SystemLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion =
      AnimationController(vsync: this, duration: const Duration(seconds: 4));
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _motion.stop();
      _motion.value = .15;
    } else if (!_motion.isAnimating) {
      _motion.repeat();
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
      label: widget.label,
      liveRegion: true,
      child: ExcludeSemantics(
          child: Center(
              child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                  height: 170,
                  width: double.infinity,
                  child: AnimatedBuilder(
                      animation: _motion,
                      builder: (context, _) =>
                          CustomPaint(painter: _LightRibbon(_motion.value)))),
              const Text('Loading...',
                  style: TextStyle(color: Color(0xFFB1A9DA), fontSize: 13)),
            ])),
      ))));
}

class _LightRibbon extends CustomPainter {
  final double phase;
  const _LightRibbon(this.phase);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width * .38;
    final rotation = phase * math.pi * 2;
    final rect = Rect.fromCenter(center: center, width: width * 2, height: 100);
    final shader = const LinearGradient(colors: [
      Color(0xFF9D8DF1),
      Color(0xFFC4E326),
      Color(0xFFFFEDA8),
      Color(0xFFC4E326),
      Color(0xFF9D8DF1)
    ], stops: [
      0,
      .35,
      .5,
      .65,
      1
    ]).createShader(rect);
    canvas.drawOval(
        Rect.fromCenter(center: center, width: width * 1.6, height: 14),
        Paint()
          ..color = const Color(0xFF9D8DF1).withOpacity(.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25));
    for (var strand = 0; strand < 36; strand++) {
      final offset = (strand / 35 - .5) * 18;
      final path = Path();
      for (var step = 0; step <= 180; step++) {
        final angle = step / 180 * math.pi * 2;
        final x = math.cos(angle) * width;
        final y = math.sin(angle) *
                (42 * math.sin(rotation)) *
                (.12 + .88 * math.cos(angle).abs()) +
            offset * math.cos(angle + rotation);
        final point = center + Offset(x, y);
        if (step == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      final paint = Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = .65;
      canvas.drawPath(
          path, paint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      canvas.drawPath(path, paint..maskFilter = null);
    }
  }

  @override
  bool shouldRepaint(_LightRibbon old) => old.phase != phase;
}
