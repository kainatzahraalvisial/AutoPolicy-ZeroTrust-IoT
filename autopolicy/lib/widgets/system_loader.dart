import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Retro-futuristic sci-fi circuit HUD loading animation inspired by
/// retro cyber system boot sequences (dual neon circuit rails, traveling photon pulse,
/// glowing terminal status and telemetry readouts).
class SystemLoader extends StatefulWidget {
  final String label;
  final bool compact;
  const SystemLoader({
    super.key,
    this.label = 'INITIATING SYSTEM 1...',
    this.compact = false,
  });

  @override
  State<SystemLoader> createState() => _SystemLoaderState();
}

class _SystemLoaderState extends State<SystemLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller.stop();
      _controller.value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  void disposeValidate() {
    _controller.dispose();
  }

  @override
  void dispose() {
    disposeValidate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final purpleColor = isDark ? const Color(0xFF9D8DF1) : const Color(0xFF7C3AED);
    final greenColor = isDark ? const Color(0xFFDCFF33) : const Color(0xFF5B7808);
    final coreWhite = isDark ? const Color(0xFFFAF9FF) : const Color(0xFF141020);

    return Semantics(
      label: widget.label,
      liveRegion: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: widget.compact ? 420 : 580),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value;
                final bool showCursor = (t * 6).floor() % 2 == 0;
                final int percent = ((t * 100).clamp(12, 99)).toInt();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Main Circuit HUD Graphic with glowing circuit traces
                    SizedBox(
                      height: widget.compact ? 120 : 160,
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _CircuitHudPainter(
                                progress: t,
                                primaryColor: purpleColor,
                                secondaryColor: greenColor,
                                isDark: isDark,
                              ),
                            ),
                          ),

                          // Center HUD Text Bay
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Main status line with glowing block cursor
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        widget.label.toUpperCase(),
                                        style: TextStyle(
                                          fontFamily: 'Orbitron',
                                          fontWeight: FontWeight.w700,
                                          fontSize: widget.compact ? 13 : 16,
                                          letterSpacing: 1.4,
                                          color: coreWhite,
                                          shadows: isDark
                                              ? [
                                                  Shadow(
                                                    color: purpleColor.withOpacity(0.8),
                                                    blurRadius: 14,
                                                  ),
                                                  Shadow(
                                                    color: greenColor.withOpacity(0.4),
                                                    blurRadius: 24,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Glowing block cursor in neon green
                                    Opacity(
                                      opacity: showCursor ? 1.0 : 0.1,
                                      child: Container(
                                        width: widget.compact ? 10 : 14,
                                        height: widget.compact ? 14 : 18,
                                        decoration: BoxDecoration(
                                          color: greenColor,
                                          borderRadius: BorderRadius.circular(1.5),
                                          boxShadow: isDark
                                              ? [
                                                  BoxShadow(
                                                    color: greenColor,
                                                    blurRadius: 10,
                                                    spreadRadius: 1,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                // Secondary telemetry lines in purple and green
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'EXTEND SYSTEM MEMORY: NO, REMOVE',
                                      style: TextStyle(
                                        fontFamily: 'SpaceGrotesk',
                                        fontSize: widget.compact ? 8.5 : 10,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.8,
                                        color: purpleColor.withOpacity(0.9),
                                      ),
                                    ),
                                    Text(
                                      'CHECKSUM: OK',
                                      style: TextStyle(
                                        fontFamily: 'SpaceGrotesk',
                                        fontSize: widget.compact ? 8.5 : 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                        color: greenColor,
                                        shadows: isDark
                                            ? [
                                                Shadow(
                                                  color: greenColor.withOpacity(0.7),
                                                  blurRadius: 6,
                                                )
                                              ]
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Technical footer telemetry bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: greenColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: greenColor,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'ZERO-TRUST ENCLAVE · READY',
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: isDark
                                      ? const Color(0xFFC4BBE5)
                                      : const Color(0xFF5A4F72),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'SYNC [$percent%]',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: purpleColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// CustomPainter drawing the exact dual-stepped neon circuit traces, 45-degree chamfers,
/// node pads, and traveling energy pulse from the Pinterest reference.
class _CircuitHudPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDark;

  const _CircuitHudPainter({
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final midY = h / 2.0;

    // Dimensions for the central stepped window bay
    final leftX = 0.0;
    final rightX = w;
    final bayStart = (w * 0.16).clamp(36.0, 90.0);
    final bayEnd = w - bayStart;
    final chamfer = 24.0;

    final topBaseY = midY - 30.0;
    final topBayY = midY - 48.0;

    final botBaseY = midY + 28.0;
    final botBayY = midY + 46.0;

    // 1. Top Circuit Path (runs flat, steps up 45°, runs across, steps down 45°, flat)
    final topPath = Path()
      ..moveTo(leftX, topBaseY)
      ..lineTo(bayStart - chamfer, topBaseY)
      ..lineTo(bayStart, topBayY)
      ..lineTo(bayEnd, topBayY)
      ..lineTo(bayEnd + chamfer, topBaseY)
      ..lineTo(rightX, topBaseY);

    // 2. Bottom Circuit Path (runs flat, steps down 45°, runs across, steps up 45°, flat)
    final botPath = Path()
      ..moveTo(leftX, botBaseY)
      ..lineTo(bayStart - chamfer, botBaseY)
      ..lineTo(bayStart, botBayY)
      ..lineTo(bayEnd, botBayY)
      ..lineTo(bayEnd + chamfer, botBaseY)
      ..lineTo(rightX, botBaseY);

    // 3. Center horizontal divider rail (subtle tech track)
    final centerDivider = Path()
      ..moveTo(leftX + 16, midY + 6.0)
      ..lineTo(rightX - 16, midY + 6.0);

    // Base Trace Paint (ambient track)
    final baseTracePaint = Paint()
      ..color = primaryColor.withOpacity(isDark ? 0.35 : 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.square;

    // Center divider paint
    final centerPaint = Paint()
      ..color = primaryColor.withOpacity(isDark ? 0.20 : 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawPath(topPath, baseTracePaint);
    canvas.drawPath(botPath, baseTracePaint);
    canvas.drawPath(centerDivider, centerPaint);

    // Glowing Neon Bloom Pass (outer diffusion for dark mode)
    if (isDark) {
      final glowPaint = Paint()
        ..color = primaryColor.withOpacity(0.40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

      canvas.drawPath(topPath, glowPaint);
      canvas.drawPath(botPath, glowPaint);
    }

    // 4. Circuit Node Pads (solder circles at vertex corners)
    final nodePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final nodeOuterPaint = Paint()
      ..color = primaryColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final nodes = [
      Offset(bayStart - chamfer, topBaseY),
      Offset(bayStart, topBayY),
      Offset(bayEnd, topBayY),
      Offset(bayEnd + chamfer, topBaseY),
      Offset(bayStart - chamfer, botBaseY),
      Offset(bayStart, botBayY),
      Offset(bayEnd, botBayY),
      Offset(bayEnd + chamfer, botBaseY),
    ];

    for (final node in nodes) {
      canvas.drawCircle(node, 2.2, nodePaint);
      canvas.drawCircle(node, 4.5, nodeOuterPaint);
    }

    // 5. Traveling Photon Pulse Beam along circuit rails
    // Compute total path length approximation to position traveling beam head
    _drawTravelingPulse(canvas, topPath, progress, primaryColor, isDark);
    _drawTravelingPulse(canvas, botPath, (progress + 0.5) % 1.0, secondaryColor, isDark);
  }

  void _drawTravelingPulse(Canvas canvas, Path path, double t, Color color, bool isDark) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    for (final metric in metrics) {
      final length = metric.length;
      final head = (t * length) % length;
      final tail = math.max(0.0, head - length * 0.28);

      final pulsePath = metric.extractPath(tail, head);

      // Core photon stroke
      final corePaint = Paint()
        ..color = isDark ? Colors.white : color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;

      // Glow envelope
      if (isDark) {
        final haloPaint = Paint()
          ..color = color.withOpacity(0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6.0
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

        canvas.drawPath(pulsePath, haloPaint);
      }

      canvas.drawPath(pulsePath, corePaint);

      // Bright leading spark
      final tangent = metric.getTangentForOffset(head);
      if (tangent != null) {
        final sparkCenter = tangent.position;
        final sparkPaint = Paint()
          ..color = isDark ? Colors.white : color
          ..style = PaintingStyle.fill;

        canvas.drawCircle(sparkCenter, 3.2, sparkPaint);
        if (isDark) {
          final sparkHalo = Paint()
            ..color = color.withOpacity(0.9)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
          canvas.drawCircle(sparkCenter, 7.0, sparkHalo);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_CircuitHudPainter old) =>
      old.progress != progress || old.primaryColor != primaryColor;
}
