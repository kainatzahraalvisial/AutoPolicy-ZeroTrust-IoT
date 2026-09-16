import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

class CyberFlowBarChart extends ConsumerStatefulWidget {
  final double height;
  const CyberFlowBarChart({super.key, this.height = 200});

  @override
  ConsumerState<CyberFlowBarChart> createState() => _CyberFlowBarChartState();
}

class _CyberFlowBarChartState extends ConsumerState<CyberFlowBarChart> with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  final List<double> _barHeights = [
    0.35, 0.48, 0.28, 0.65, 0.52, 0.40, 0.78, 0.45, 
    0.32, 0.60, 0.88, 0.64, 0.50, 0.94, 0.76, 0.62,
    0.42, 0.58, 0.90, 0.72, 0.96, 0.82, 0.69, 0.91
  ];
  
  // Protocol categories associated with bar clusters
  final List<String> _barProtocols = [
    'MQTT Ingress', 'CoAP DTLS', 'HTTP/2 REST', 'Modbus TCP', 'MQTT Ingress', 'CoAP DTLS',
    'HTTP/2 REST', 'Threat Spike', 'MQTT Ingress', 'CoAP DTLS', 'GNN Anomaly', 'HTTP/2 REST',
    'Modbus TCP', 'Threat Spike', 'MQTT Ingress', 'CoAP DTLS', 'HTTP/2 REST', 'Modbus TCP',
    'GNN Anomaly', 'CoAP DTLS', 'Threat Spike', 'MQTT Ingress', 'Modbus TCP', 'HTTP/2 REST'
  ];

  late final Timer _timer;
  int? _hoveredBarIndex;
  String? _activeLegendHover;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (mounted) {
        setState(() {
          for (int i = 0; i < _barHeights.length; i++) {
            _barHeights[i] = (_barHeights[i] + (math.Random().nextDouble() * 0.12 - 0.06)).clamp(0.2, 0.98);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider);

    return Container(
      height: widget.height,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0C0D10) : Colors.white,
        border: Border.all(
          color: isDarkMode 
              ? const Color(0xFF9D4EDD).withOpacity(0.60) 
              : const Color(0xFF80A416).withOpacity(0.30), 
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: isDarkMode
            ? const [
                BoxShadow(
                  color: Color(0x1A9D4EDD),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── TOP HEADER & INTERACTIVE PROTOCOL LEGEND ──────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.analytics_outlined, color: isDarkMode ? const Color(0xFF9D4EDD) : const Color(0xFF80A416), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'GLOBAL IoT PACKET INGRESS & THREAT SPECTRUM',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? const Color(0xFF9D4EDD) : const Color(0xFF0F172A),
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),

              // Interactive Legend Badges with Hover Explanations
              Row(
                children: [
                  _buildLegendItem(
                    label: 'MQTT',
                    color: const Color(0xFF5DD62C),
                    desc: 'MQTT Protocol: Telemetry data streams from IoT sensors (540 pkts/s)',
                  ),
                  const SizedBox(width: 8),
                  _buildLegendItem(
                    label: 'CoAP',
                    color: const Color(0xFF9D4EDD),
                    desc: 'CoAP DTLS: UDP constrained application protocol (420 pkts/s)',
                  ),
                  const SizedBox(width: 8),
                  _buildLegendItem(
                    label: 'HTTP/REST',
                    color: isDarkMode ? const Color(0xFFC4E326) : const Color(0xFF80A416),
                    desc: 'HTTP/2 REST: Gateway API communication (280 pkts/s)',
                  ),
                  const SizedBox(width: 8),
                  _buildLegendItem(
                    label: 'THREAT ANOMALY',
                    color: const Color(0xFFE95300),
                    desc: 'GNN Threat Anomaly: Isolated network spikes & scanning attempts',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── ACTIVE LEGEND HOVER TOOLTIP BANNER ─────────────────────────────
          if (_activeLegendHover != null)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF181A22) : const Color(0xFFF8FAFC),
                border: Border.all(color: isDarkMode ? const Color(0xFF9D4EDD) : const Color(0xFF80A416), width: 0.8),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: isDarkMode ? const Color(0xFF9D4EDD) : const Color(0xFF80A416), size: 13),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _activeLegendHover!,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: isDarkMode ? const Color(0xFFEBECEE) : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── METRIC READOUT ROW ─────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '1,420 pkts/s',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF08652C),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF9D4EDD).withOpacity(0.18) : const Color(0xFF9D4EDD).withOpacity(0.10),
                  border: Border.all(color: const Color(0xFF9D4EDD), width: 0.8),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Text(
                  '+27.8% SURGE | PURPLE SHADE WAVEFORM',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9D4EDD),
                  ),
                ),
              ),
              const Spacer(),
              if (_hoveredBarIndex != null)
                Text(
                  'HOVERED BAR #${_hoveredBarIndex! + 1}: ${_barProtocols[_hoveredBarIndex!]} [${(_barHeights[_hoveredBarIndex!] * 1500).toInt()} pkts/s]',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? const Color(0xFFC4E326) : const Color(0xFF80A416),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // ── ANIMATED BAR CHART CANVAS WITH HOVER DETECTOR ──────────────────
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return MouseRegion(
                  onHover: (event) {
                    final double chartWidth = constraints.maxWidth;
                    final int count = _barHeights.length;
                    final double barSlotWidth = chartWidth / count;
                    final int hoveredIndex = (event.localPosition.dx / barSlotWidth).floor().clamp(0, count - 1);
                    if (_hoveredBarIndex != hoveredIndex) {
                      setState(() {
                        _hoveredBarIndex = hoveredIndex;
                      });
                    }
                  },
                  onExit: (_) {
                    setState(() {
                      _hoveredBarIndex = null;
                    });
                  },
                  child: AnimatedBuilder(
                    animation: _animCtrl,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: _PurpleCyberBarGraphPainter(
                          barHeights: _barHeights,
                          pulse: _animCtrl.value,
                          hoveredIndex: _hoveredBarIndex,
                          isDarkMode: isDarkMode,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required String label,
    required Color color,
    required String desc,
  }) {
    return MouseRegion(
      onEnter: (_) => setState(() => _activeLegendHover = desc),
      onExit: (_) => setState(() => _activeLegendHover = null),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          border: Border.all(color: color.withOpacity(0.70), width: 0.8),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 6, height: 6, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurpleCyberBarGraphPainter extends CustomPainter {
  final List<double> barHeights;
  final double pulse;
  final int? hoveredIndex;
  final bool isDarkMode;

  _PurpleCyberBarGraphPainter({
    required this.barHeights,
    required this.pulse,
    this.hoveredIndex,
    this.isDarkMode = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final int count = barHeights.length;
    final double slotW = w / count;
    final double barWidth = slotW - 3.0;

    // Horizontal Grid Lines
    final gridPaint = Paint()
      ..color = isDarkMode ? const Color(0xFF9D4EDD).withOpacity(0.15) : const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, h), Offset(w, h), gridPaint);
    canvas.drawLine(Offset(0, h * 0.66), Offset(w, h * 0.66), gridPaint);
    canvas.drawLine(Offset(0, h * 0.33), Offset(w, h * 0.33), gridPaint);

    // Purple & Cyber Palette sequence
    final List<Color> paletteColors = const [
      Color(0xFF9D4EDD), // Deep Cyber Violet
      Color(0xFF8B5CF6), // Neon Purple
      Color(0xFF5DD62C), // Cyber Green
      Color(0xFFC4E326), // Lichen Green
      Color(0xFF7B2CBF), // Deep Purple
      Color(0xFFE95300), // Vibrant Orange
      Color(0xFFC5C764), // Muted Yellow
      Color(0xFFEBECEE), // Alpine Ice
    ];

    for (int i = 0; i < count; i++) {
      final double x = (i * slotW) + 1.5;
      final double barH = barHeights[i] * h;
      final double y = h - barH;
      final bool isHovered = hoveredIndex == i;
      final bool isThreatAnomaly = barHeights[i] > 0.88;

      final Color barColor = isThreatAnomaly
          ? const Color(0xFFE95300) // Vibrant Orange for Threat Spikes!
          : paletteColors[i % paletteColors.length];

      final Rect barRect = Rect.fromLTWH(x, y, barWidth, barH);
      
      // Vertical bar gradient with purple accent base
      final Paint fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            barColor.withOpacity(isHovered ? 0.40 : 0.20),
            barColor.withOpacity(isHovered ? 1.0 : (0.75 + (pulse * 0.15))),
          ],
        ).createShader(barRect);

      canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, const Radius.circular(1.0)),
        fillPaint,
      );

      // Top glowing tip cap
      final Paint capPaint = Paint()
        ..color = isHovered ? Colors.white : barColor
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(x, y, barWidth, isHovered ? 3.5 : 2.0), capPaint);

      // Hover aura highlight ring
      if (isHovered) {
        final Paint hoverStroke = Paint()
          ..color = Colors.white
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke;
        canvas.drawRect(barRect.inflate(1.0), hoverStroke);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PurpleCyberBarGraphPainter oldDelegate) => true;
}
