import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class IngressNode {
  final String id;
  final String name;
  final Offset posRatio; // Relative (0..1, 0..1) on map canvas
  final double ingressGbps;
  final int packetRate;
  final int latencyMs;
  final bool isUnderAttack;
  final String activeProtocol;
  final String nodeType; // 'core', 'hub', 'gateway', 'threat'

  const IngressNode({
    required this.id,
    required this.name,
    required this.posRatio,
    required this.ingressGbps,
    required this.packetRate,
    required this.latencyMs,
    required this.isUnderAttack,
    required this.activeProtocol,
    this.nodeType = 'gateway',
  });
}

class GlobalSocIngressMap extends StatefulWidget {
  final double height;
  const GlobalSocIngressMap({super.key, this.height = 380});

  @override
  State<GlobalSocIngressMap> createState() => _GlobalSocIngressMapState();
}

class _GlobalSocIngressMapState extends State<GlobalSocIngressMap> with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  String _selectedNodeId = 'eu-central';

  static const List<IngressNode> nodes = [
    IngressNode(
      id: 'us-west',
      name: 'US-WEST (OREGON EDGE)',
      posRatio: Offset(0.18, 0.28),
      ingressGbps: 14.2,
      packetRate: 32900,
      latencyMs: 22,
      isUnderAttack: false,
      activeProtocol: 'MQTT / TLS 1.3',
      nodeType: 'gateway',
    ),
    IngressNode(
      id: 'us-east',
      name: 'US-EAST (VIRGINIA HUB)',
      posRatio: Offset(0.34, 0.58),
      ingressGbps: 22.4,
      packetRate: 54200,
      latencyMs: 14,
      isUnderAttack: false,
      activeProtocol: 'MQTT / TLS 1.3',
      nodeType: 'hub',
    ),
    IngressNode(
      id: 'eu-central',
      name: 'EU-CENTRAL (FRANKFURT)',
      posRatio: Offset(0.64, 0.26),
      ingressGbps: 18.9,
      packetRate: 42100,
      latencyMs: 11,
      isUnderAttack: false,
      activeProtocol: 'CoAP / DTLS',
      nodeType: 'hub',
    ),
    IngressNode(
      id: 'apac-south',
      name: 'APAC-SOUTH (SINGAPORE)',
      posRatio: Offset(0.84, 0.65),
      ingressGbps: 12.8,
      packetRate: 31800,
      latencyMs: 48,
      isUnderAttack: true, // DDoS Surge Active
      activeProtocol: 'HTTP2 / OPA REGO',
      nodeType: 'threat',
    ),
    IngressNode(
      id: 'sa-east',
      name: 'SA-EAST (SAO PAULO)',
      posRatio: Offset(0.40, 0.82),
      ingressGbps: 6.5,
      packetRate: 14200,
      latencyMs: 78,
      isUnderAttack: false,
      activeProtocol: 'CoAP / DTLS',
      nodeType: 'gateway',
    ),
  ];

  static const Offset coreHubPos = Offset(0.50, 0.44);

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedNode = nodes.firstWhere((n) => n.id == _selectedNodeId, orElse: () => nodes[2]);

    return SizedBox(
      height: widget.height,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF050A07),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF5DD62C).withOpacity(0.55), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5DD62C).withOpacity(0.12),
              blurRadius: 16,
            ),
          ],
        ),
        child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Column(
          children: [
            // ── 1. MAP TITLE & TELEMETRY HEADER ──────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: const Color(0xFF0B140E),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF5DD62C),
                            boxShadow: [
                              BoxShadow(color: Color(0xFF5DD62C), blurRadius: 6),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'GLOBAL MARKET / SOC INGRESS MAP',
                            style: CyberTextStyles.technical(
                              color: const Color(0xFF5DD62C),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            'TOTAL INGRESS: 74.8 Gbps',
                            style: CyberTextStyles.technical(color: const Color(0xFFEDF5EB), fontSize: 10.5),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: CyberColors.alertRed.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: CyberColors.alertRed, width: 0.8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: CyberColors.alertRed, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'APAC DDOS SURGE: QUARANTINED',
                          style: CyberTextStyles.technical(color: CyberColors.alertRed, fontSize: 9.5, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFF1E3A1A)),

            // ── 2. MATRIX DOT MAP CANVAS WITH GLOWING NODES (NO ICONS) ────
            Expanded(
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _animCtrl,
                    builder: (context, _) {
                      return CustomPaint(
                        size: Size.infinite,
                        painter: _MatrixMapCanvasPainter(
                          progress: _animCtrl.value,
                          nodes: nodes,
                          selectedId: _selectedNodeId,
                          corePos: coreHubPos,
                        ),
                      );
                    },
                  ),

                  // Interactive Glowing Nodes Overlay
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final h = constraints.maxHeight;

                      return Stack(
                        children: [
                          // Central Zero-Trust Policy Core Hub
                          Positioned(
                            left: w * coreHubPos.dx - 18,
                            top: h * coreHubPos.dy - 18,
                            child: Tooltip(
                              message: 'CENTRAL ZERO-TRUST POLICY CORE HUB\nRole: OPA Rego Engine & GNN Evaluator\nStatus: Active Microsegmentation',
                              padding: const EdgeInsets.all(8),
                              textStyle: const TextStyle(color: Color(0xFFEDF5EB), fontSize: 10.5, fontWeight: FontWeight.bold),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F0F0F),
                                border: Border.all(color: const Color(0xFF5DD62C), width: 1.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: AnimatedBuilder(
                                animation: _animCtrl,
                                builder: (context, _) {
                                  final pulse = (math.sin(_animCtrl.value * math.pi * 2) + 1) / 2;
                                  return Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF5DD62C).withOpacity(0.25 + pulse * 0.2),
                                      border: Border.all(color: const Color(0xFF5DD62C), width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF5DD62C).withOpacity(0.8),
                                          blurRadius: 12 + pulse * 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // Render Glowing Node Overlay (No Icons)
                          ...nodes.map((node) {
                            final isSelected = node.id == _selectedNodeId;
                            final Color nodeColor = node.isUnderAttack
                                ? CyberColors.alertRed
                                : (isSelected ? const Color(0xFF5DD62C) : const Color(0xFFC5C764));

                            return Positioned(
                              left: w * node.posRatio.dx - 16,
                              top: h * node.posRatio.dy - 16,
                              child: Tooltip(
                                message: '${node.name}\nPROTOCOL: ${node.activeProtocol}\nINGRESS: ${node.ingressGbps} Gbps (${(node.packetRate / 1000).toStringAsFixed(1)}k pkts/s)\nLATENCY: ${node.latencyMs} ms',
                                padding: const EdgeInsets.all(8),
                                textStyle: const TextStyle(color: Color(0xFFEDF5EB), fontSize: 10.5, fontWeight: FontWeight.bold),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F0F0F),
                                  border: Border.all(color: nodeColor, width: 1.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedNodeId = node.id;
                                    });
                                  },
                                  child: AnimatedBuilder(
                                    animation: _animCtrl,
                                    builder: (context, _) {
                                      final pulse = (math.sin((_animCtrl.value + node.ingressGbps) * math.pi * 2) + 1) / 2;
                                      return Container(
                                        width: 32,
                                        height: 32,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: nodeColor.withOpacity(isSelected ? 0.35 : 0.15),
                                          border: Border.all(
                                            color: nodeColor,
                                            width: isSelected ? 2.2 : 1.2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: nodeColor.withOpacity(isSelected ? 0.9 : 0.5 + pulse * 0.3),
                                              blurRadius: isSelected ? 16 : 8,
                                              spreadRadius: isSelected ? 3 : 1,
                                            ),
                                          ],
                                        ),
                                        child: Container(
                                          width: isSelected ? 10 : 7,
                                          height: isSelected ? 10 : 7,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isSelected ? Colors.white : nodeColor,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white.withOpacity(0.8),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFF1E3A1A)),

            // ── 3. INTEGRATED BOTTOM TELEMETRY READOUT (INSIDE MAP CARD) ───
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: const Color(0xFF071109),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selectedNode.isUnderAttack ? CyberColors.alertRed : const Color(0xFF5DD62C),
                            boxShadow: [
                              BoxShadow(
                                color: selectedNode.isUnderAttack ? CyberColors.alertRed : const Color(0xFF5DD62C),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            selectedNode.name,
                            style: CyberTextStyles.technical(
                              color: selectedNode.isUnderAttack ? CyberColors.alertRed : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            'PROTOCOL: ${selectedNode.activeProtocol} | LATENCY: ${selectedNode.latencyMs}ms',
                            style: CyberTextStyles.techMuted.copyWith(fontSize: 9.5),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      Text(
                        '${selectedNode.ingressGbps} Gbps',
                        style: CyberTextStyles.technical(color: const Color(0xFF5DD62C), fontSize: 12, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(selectedNode.packetRate / 1000).toStringAsFixed(1)}k /s',
                        style: CyberTextStyles.technical(color: const Color(0xFFC5C764), fontSize: 12, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}

// ─────────────────────────────────────────────────────────────
// MATRIX GREEN GLOBAL MAP CANVAS PAINTER (Matching Image media_1789019558887.png)
// ─────────────────────────────────────────────────────────────
class _MatrixMapCanvasPainter extends CustomPainter {
  final double progress;
  final List<IngressNode> nodes;
  final String selectedId;
  final Offset corePos;

  _MatrixMapCanvasPainter({
    required this.progress,
    required this.nodes,
    required this.selectedId,
    required this.corePos,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Tactical Matrix Dot Grid Background
    final gridDotPaint = Paint()
      ..color = const Color(0xFF337418).withOpacity(0.20)
      ..style = PaintingStyle.fill;

    for (double x = 12; x < w; x += 18) {
      for (double y = 12; y < h; y += 14) {
        canvas.drawCircle(Offset(x, y), 0.8, gridDotPaint);
      }
    }

    // 2. Continents Dotted Matrix Outline (Matching Image 3)
    final mapDotPaint = Paint()
      ..color = const Color(0xFF5DD62C).withOpacity(0.45)
      ..style = PaintingStyle.fill;

    final brightMapDotPaint = Paint()
      ..color = const Color(0xFF5DD62C).withOpacity(0.75)
      ..style = PaintingStyle.fill;

    final List<Offset> continentDots = [
      // North America
      const Offset(0.12, 0.22), const Offset(0.14, 0.20), const Offset(0.16, 0.18), const Offset(0.18, 0.16),
      const Offset(0.20, 0.15), const Offset(0.22, 0.16), const Offset(0.24, 0.18), const Offset(0.26, 0.20),
      const Offset(0.15, 0.25), const Offset(0.17, 0.24), const Offset(0.19, 0.23), const Offset(0.21, 0.22),
      const Offset(0.23, 0.24), const Offset(0.25, 0.26), const Offset(0.27, 0.28), const Offset(0.29, 0.27),
      const Offset(0.18, 0.32), const Offset(0.20, 0.30), const Offset(0.22, 0.29), const Offset(0.24, 0.31),
      const Offset(0.26, 0.33), const Offset(0.28, 0.35), const Offset(0.30, 0.34), const Offset(0.32, 0.32),

      // South America
      const Offset(0.33, 0.52), const Offset(0.35, 0.50), const Offset(0.37, 0.52), const Offset(0.39, 0.54),
      const Offset(0.34, 0.58), const Offset(0.36, 0.56), const Offset(0.38, 0.58), const Offset(0.40, 0.60),
      const Offset(0.35, 0.64), const Offset(0.37, 0.62), const Offset(0.39, 0.65), const Offset(0.41, 0.67),
      const Offset(0.36, 0.70), const Offset(0.38, 0.69), const Offset(0.40, 0.72), const Offset(0.42, 0.75),

      // Europe
      const Offset(0.50, 0.20), const Offset(0.52, 0.18), const Offset(0.54, 0.17), const Offset(0.56, 0.19),
      const Offset(0.58, 0.18), const Offset(0.60, 0.20), const Offset(0.62, 0.22), const Offset(0.64, 0.21),
      const Offset(0.51, 0.25), const Offset(0.53, 0.24), const Offset(0.55, 0.23), const Offset(0.57, 0.25),
      const Offset(0.59, 0.26), const Offset(0.61, 0.28), const Offset(0.63, 0.27), const Offset(0.65, 0.25),

      // Africa
      const Offset(0.50, 0.42), const Offset(0.52, 0.40), const Offset(0.54, 0.39), const Offset(0.56, 0.41),
      const Offset(0.58, 0.40), const Offset(0.60, 0.42), const Offset(0.62, 0.44), const Offset(0.64, 0.43),
      const Offset(0.51, 0.48), const Offset(0.53, 0.46), const Offset(0.55, 0.47), const Offset(0.57, 0.49),
      const Offset(0.59, 0.51), const Offset(0.61, 0.53), const Offset(0.63, 0.52), const Offset(0.65, 0.50),

      // Asia & Oceania
      const Offset(0.68, 0.18), const Offset(0.70, 0.16), const Offset(0.72, 0.15), const Offset(0.74, 0.17),
      const Offset(0.76, 0.16), const Offset(0.78, 0.18), const Offset(0.80, 0.20), const Offset(0.82, 0.19),
      const Offset(0.84, 0.21), const Offset(0.86, 0.23), const Offset(0.88, 0.22), const Offset(0.90, 0.24),
      const Offset(0.67, 0.26), const Offset(0.69, 0.25), const Offset(0.71, 0.24), const Offset(0.73, 0.26),
      const Offset(0.75, 0.28), const Offset(0.77, 0.27), const Offset(0.79, 0.29), const Offset(0.81, 0.31),
      const Offset(0.82, 0.68), const Offset(0.84, 0.66), const Offset(0.86, 0.67), const Offset(0.88, 0.69),
      const Offset(0.83, 0.74), const Offset(0.85, 0.72), const Offset(0.87, 0.75), const Offset(0.89, 0.77),
    ];

    for (int i = 0; i < continentDots.length; i++) {
      final pt = continentDots[i];
      final dx = pt.dx * w;
      final dy = pt.dy * h;
      canvas.drawCircle(Offset(dx, dy), (i % 3 == 0) ? 1.8 : 1.2, (i % 4 == 0) ? brightMapDotPaint : mapDotPaint);
    }

    // 3. Curved Glowing Interconnecting Trajectory Arcs (Matching Image 3)
    final hubOffset = Offset(w * corePos.dx, h * corePos.dy);

    for (int i = 0; i < nodes.length; i++) {
      final n1 = nodes[i];
      final pt1 = Offset(w * n1.posRatio.dx, h * n1.posRatio.dy);

      final Color arcColor = n1.isUnderAttack
          ? CyberColors.alertRed
          : (n1.id == selectedId ? const Color(0xFF5DD62C) : const Color(0xFF5DD62C).withOpacity(0.65));

      final path = Path();
      path.moveTo(pt1.dx, pt1.dy);

      // Quadratic Bezier curve control point for graceful glowing arcs
      final midX = (pt1.dx + hubOffset.dx) / 2;
      final midY = (pt1.dy + hubOffset.dy) / 2 - 30;
      path.quadraticBezierTo(midX, midY, hubOffset.dx, hubOffset.dy);

      final arcPaint = Paint()
        ..color = arcColor
        ..strokeWidth = (n1.id == selectedId) ? 2.0 : 1.2
        ..style = PaintingStyle.stroke;

      canvas.drawPath(path, arcPaint);

      // Glow backdrop for arcs
      final glowArcPaint = Paint()
        ..color = arcColor.withOpacity(0.35)
        ..strokeWidth = (n1.id == selectedId) ? 5.0 : 3.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawPath(path, glowArcPaint);

      // Connect neighbor nodes with subtle secondary arcs
      for (int j = i + 1; j < nodes.length; j++) {
        final n2 = nodes[j];
        final pt2 = Offset(w * n2.posRatio.dx, h * n2.posRatio.dy);
        final secPath = Path();
        secPath.moveTo(pt1.dx, pt1.dy);
        final secMidX = (pt1.dx + pt2.dx) / 2;
        final secMidY = (pt1.dy + pt2.dy) / 2 - 20;
        secPath.quadraticBezierTo(secMidX, secMidY, pt2.dx, pt2.dy);

        canvas.drawPath(
          secPath,
          Paint()
            ..color = const Color(0xFF5DD62C).withOpacity(0.25)
            ..strokeWidth = 0.8
            ..style = PaintingStyle.stroke,
        );
      }

      // Animated glowing pulse particle traveling along Bezier trajectory
      final double t = (progress + (i * 0.20)) % 1.0;
      final double px = (1 - t) * (1 - t) * pt1.dx + 2 * (1 - t) * t * midX + t * t * hubOffset.dx;
      final double py = (1 - t) * (1 - t) * pt1.dy + 2 * (1 - t) * t * midY + t * t * hubOffset.dy;

      canvas.drawCircle(Offset(px, py), 3.0, Paint()..color = Colors.white..style = PaintingStyle.fill);
      canvas.drawCircle(
        Offset(px, py),
        6.0,
        Paint()
          ..color = arcColor
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MatrixMapCanvasPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.selectedId != selectedId;
  }
}
