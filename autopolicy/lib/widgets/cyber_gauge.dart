import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class CyberGauge extends StatelessWidget {
  final double value; // 0.0 to 100.0
  final String label;
  final Color color;
  final double size;

  const CyberGauge({
    super.key,
    required this.value,
    required this.label,
    this.color = CyberColors.neonGreen,
    this.size = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _CyberGaugePainter(value, color),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${value.toStringAsFixed(0)}%',
                    style: CyberTextStyles.displayTitle(
                      fontSize: size * 0.22,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label.toUpperCase(),
                    style: CyberTextStyles.techMuted.copyWith(fontSize: size * 0.085, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CyberGaugePainter extends CustomPainter {
  final double percentage;
  final Color themeColor;

  const _CyberGaugePainter(this.percentage, this.themeColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 8.0;

    // 1. Draw outer tech tick marks
    final tickPaint = Paint()
      ..color = CyberColors.textMuted.withOpacity(0.2)
      ..strokeWidth = 1.0;

    const int tickCount = 40;
    for (int i = 0; i < tickCount; i++) {
      final double angle = (i * 2 * pi) / tickCount;
      final double innerRadius = radius + 2.0;
      final double outerRadius = radius + 6.0;

      final startOffset = Offset(
        center.dx + cos(angle) * innerRadius,
        center.dy + sin(angle) * innerRadius,
      );
      final endOffset = Offset(
        center.dx + cos(angle) * outerRadius,
        center.dy + sin(angle) * outerRadius,
      );

      // Highlight active ticks
      final tickPercent = (i / tickCount) * 100;
      if (tickPercent <= percentage) {
        tickPaint.color = themeColor.withOpacity(0.6);
      } else {
        tickPaint.color = CyberColors.textMuted.withOpacity(0.15);
      }

      canvas.drawLine(startOffset, endOffset, tickPaint);
    }

    // 2. Draw background track circle
    final trackPaint = Paint()
      ..color = CyberColors.panelBg.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;
    canvas.drawCircle(center, radius - 4, trackPaint);

    // 3. Draw active filled arc
    final progressPaint = Paint()
      ..color = themeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0)
      ..strokeWidth = 5.0;

    final double sweepAngle = (percentage / 100.0) * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      -pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CyberGaugePainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.themeColor != themeColor;
  }
}
