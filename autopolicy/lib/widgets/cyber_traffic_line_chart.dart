import 'package:flutter/material.dart';
import '../theme/text_styles.dart';

class CyberTrafficLineChart extends StatelessWidget {
  final double height;
  final VoidCallback? onViewDetails;

  const CyberTrafficLineChart({
    super.key,
    this.height = 240,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        border: Border.all(color: const Color(0xFF5DD62C).withOpacity(0.35), width: 1.0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF5DD62C),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Color(0xFF5DD62C), blurRadius: 6),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'REAL-TIME TRAFFIC (LAST 1 HOUR)',
                    style: CyberTextStyles.technical(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5DD62C),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5DD62C).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      'LIVE · 1,420 PKTS/S',
                      style: CyberTextStyles.technical(
                        fontSize: 9,
                        color: const Color(0xFF5DD62C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildLegendPill('NORMAL INGRESS', const Color(0xFF5DD62C)),
                  const SizedBox(width: 8),
                  _buildLegendPill('ANOMALY SPIKES', const Color(0xFFDF2531)),
                  if (onViewDetails != null) ...[
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: onViewDetails,
                      child: Text(
                        'FULL IDS →',
                        style: CyberTextStyles.technical(
                          fontSize: 9,
                          color: const Color(0xFF8B5CF6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Chart Canvas
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _TrafficLineChartPainter(),
            ),
          ),
          const SizedBox(height: 6),

          // X-Axis Time Ticks
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('-60 min', style: CyberTextStyles.techMuted.copyWith(fontSize: 8.5)),
              Text('-45 min', style: CyberTextStyles.techMuted.copyWith(fontSize: 8.5)),
              Text('-30 min', style: CyberTextStyles.techMuted.copyWith(fontSize: 8.5)),
              Text('-15 min', style: CyberTextStyles.techMuted.copyWith(fontSize: 8.5)),
              Text('NOW', style: CyberTextStyles.technical(fontSize: 8.5, color: const Color(0xFF5DD62C), fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendPill(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: CyberTextStyles.techMuted.copyWith(fontSize: 8.5, color: color),
        ),
      ],
    );
  }
}

class _TrafficLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Background horizontal grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFF252525)
      ..strokeWidth = 1.0;

    const int gridRows = 4;
    for (int i = 0; i <= gridRows; i++) {
      final y = h * (i / gridRows);
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Normalized sample points over 1 hour (0.0 to 1.0)
    final normalPoints = <Offset>[
      Offset(0.00 * w, 0.65 * h),
      Offset(0.10 * w, 0.60 * h),
      Offset(0.20 * w, 0.68 * h),
      Offset(0.30 * w, 0.55 * h),
      Offset(0.40 * w, 0.58 * h),
      Offset(0.50 * w, 0.45 * h),
      Offset(0.60 * w, 0.52 * h),
      Offset(0.70 * w, 0.40 * h),
      Offset(0.80 * w, 0.48 * h),
      Offset(0.90 * w, 0.35 * h),
      Offset(1.00 * w, 0.38 * h),
    ];

    final anomalyPoints = <Offset>[
      Offset(0.00 * w, 0.95 * h),
      Offset(0.15 * w, 0.95 * h),
      Offset(0.25 * w, 0.92 * h),
      Offset(0.32 * w, 0.42 * h), // spike 1
      Offset(0.38 * w, 0.90 * h),
      Offset(0.55 * w, 0.88 * h),
      Offset(0.68 * w, 0.30 * h), // spike 2 (DDoS)
      Offset(0.75 * w, 0.85 * h),
      Offset(0.88 * w, 0.88 * h),
      Offset(1.00 * w, 0.85 * h),
    ];

    // 1. Draw Normal Ingress Area Gradient
    final normalPath = Path()..moveTo(normalPoints.first.dx, normalPoints.first.dy);
    for (int i = 1; i < normalPoints.length; i++) {
      final p0 = normalPoints[i - 1];
      final p1 = normalPoints[i];
      final cx = (p0.dx + p1.dx) / 2;
      normalPath.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    final fillPath = Path.from(normalPath)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF5DD62C).withOpacity(0.25),
          const Color(0xFF5DD62C).withOpacity(0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Normal Line Stroke
    final normalLinePaint = Paint()
      ..color = const Color(0xFF5DD62C)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(normalPath, normalLinePaint);

    // 2. Draw Anomaly Spike Line
    final anomalyPath = Path()..moveTo(anomalyPoints.first.dx, anomalyPoints.first.dy);
    for (int i = 1; i < anomalyPoints.length; i++) {
      final p0 = anomalyPoints[i - 1];
      final p1 = anomalyPoints[i];
      final cx = (p0.dx + p1.dx) / 2;
      anomalyPath.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    final anomalyLinePaint = Paint()
      ..color = const Color(0xFFDF2531)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(anomalyPath, anomalyLinePaint);

    // Anomaly dots on spikes
    final dotPaint = Paint()..color = const Color(0xFFDF2531);
    final glowPaint = Paint()
      ..color = const Color(0xFFDF2531).withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(Offset(0.32 * w, 0.42 * h), 5, glowPaint);
    canvas.drawCircle(Offset(0.32 * w, 0.42 * h), 3, dotPaint);

    canvas.drawCircle(Offset(0.68 * w, 0.30 * h), 6, glowPaint);
    canvas.drawCircle(Offset(0.68 * w, 0.30 * h), 3.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
