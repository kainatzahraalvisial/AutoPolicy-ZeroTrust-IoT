import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_provider.dart';
import '../theme/text_styles.dart';

class CyberRadialDonutChart extends ConsumerWidget {
  final double height;
  const CyberRadialDonutChart({super.key, this.height = 190});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Map<String, dynamic>> categories = [
      {'name': 'DDoS SURGE', 'pct': 48, 'color': const Color(0xFF80A416)},
      {'name': 'PORT SCAN', 'pct': 22, 'color': const Color(0xFF08652C)},
      {'name': 'ANOMALY', 'pct': 12, 'color': const Color(0xFFAD9F3C)},
      {'name': 'REGO BLOCK', 'pct': 9, 'color': const Color(0xFFC5C764)},
      {'name': 'OTHER', 'pct': 9, 'color': const Color(0xFF5E7343)},
    ];

    return InkWell(
      onTap: () => ref.read(navigationTabProvider.notifier).state = 2, // Jump to Anomalies Feed
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: height,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF08120C),
          border: Border.all(color: const Color(0xFF80A416).withOpacity(0.40), width: 1.0),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'THREAT CLASSIFICATION (IDS / GNN)',
                  style: CyberTextStyles.technical(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFC5C764),
                  ),
                ),
                Text(
                  'DETAILS →',
                  style: CyberTextStyles.technical(
                    fontSize: 8.5,
                    color: const Color(0xFF80A416),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Row(
                children: [
                  // Donut Canvas with central badge
                  SizedBox(
                    width: 105,
                    height: 105,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(105, 105),
                          painter: _DonutChartPainter(categories: categories),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '24',
                              style: CyberTextStyles.displayTitle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFAD9F3C),
                              ),
                            ),
                            Text(
                              'ACTIVE',
                              style: CyberTextStyles.technical(
                                fontSize: 8,
                                color: const Color(0xFF5E7343),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Legend List
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: categories.map((cat) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.5),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: cat['color'] as Color,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(1.5),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  cat['name'] as String,
                                  style: CyberTextStyles.technical(
                                    fontSize: 9.5,
                                    color: const Color(0xFFC5C764),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${cat['pct']}%',
                                style: CyberTextStyles.technical(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFAD9F3C),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> categories;

  _DonutChartPainter({required this.categories});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;
    const double strokeWidth = 14.0;
    double startAngle = -math.pi / 2;

    final Paint bgPaint = Paint()
      ..color = const Color(0xFF032820).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius - (strokeWidth / 2), bgPaint);

    for (final cat in categories) {
      final double sweepAngle = ((cat['pct'] as int) / 100.0) * (2 * math.pi) - 0.05;
      final Paint segmentPaint = Paint()
        ..color = cat['color'] as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.square;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - (strokeWidth / 2)),
        startAngle,
        sweepAngle,
        false,
        segmentPaint,
      );
      startAngle += sweepAngle + 0.05;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => false;
}
