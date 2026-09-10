import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pipeline_particle_canvas.dart';
import 'cyber_hud_frame.dart';

// ─────────────────────────────────────────────────────────────
// PIPELINE PAGE (Landing Screen Page 2)
// Full-screen graph -> side panels close in -> central cluster -> sequential reveal
// ─────────────────────────────────────────────────────────────

class PipelinePage extends StatefulWidget {
  final bool isActive;
  const PipelinePage({super.key, required this.isActive});

  @override
  State<PipelinePage> createState() => _PipelinePageState();
}

class _PipelinePageState extends State<PipelinePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shadeCtrl;

  // Pipeline steps (01 to 05)
  static const leftSteps = [
    _Step('01', 'Capture',
        'Zeek monitors IoT network flows in real time — extracting IPs, ports, protocols, and durations into structured buffers.'),
    _Step('03', 'Model',
        'GNN maps device relationships as a live graph — exposing abnormal communication invisible to rule-based IDS.'),
    _Step('05', 'Enforce',
        'OPA engine deploys policies dynamically. Role-based dashboard lets administrators review, approve, and manage in real time.'),
  ];

  static const rightSteps = [
    _Step('02', 'Detect',
        'Hybrid ML classifier identifies 33 attack categories including DDoS, lateral movement, and Mirai botnet telemetry.'),
    _Step('04', 'Generate',
        'Transformer model automatically converts detected abnormal traffic into zero-trust JSON authorization policies.'),
  ];

  @override
  void initState() {
    super.initState();
    // Fast & smooth panel closing animation over 1.3s
    _shadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    if (widget.isActive) {
      _startSequence();
    }
  }

  void _startSequence() {
    _shadeCtrl.reset();
    // Decreased time: network graph shows full screen for just 140ms before panels close in
    Future.delayed(const Duration(milliseconds: 140), () {
      if (mounted && widget.isActive) {
        _shadeCtrl.forward();
      }
    });
  }

  @override
  void didUpdateWidget(covariant PipelinePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startSequence();
    } else if (!widget.isActive && oldWidget.isActive) {
      // Exit animation: smoothly slide panels back out when leaving page two
      _shadeCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _shadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isMobile = size.width < 680;

    // Mobile fallback layout
    if (isMobile) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 90, 24, 40),
        child: Column(
          children: [
            SizedBox(
              height: 220,
              child: PipelineParticles(isActive: widget.isActive),
            ),
            const SizedBox(height: 28),
            ...[...leftSteps, ...rightSteps].asMap().entries.map((entry) {
              final idx = entry.key;
              final s = entry.value;
              final design = switch (idx) {
                0 => CyberFrameDesign.topTabWedge,
                1 => CyberFrameDesign.hazardStripes,
                2 => CyberFrameDesign.techDots,
                3 => CyberFrameDesign.ladderFins,
                _ => CyberFrameDesign.tacticalBrackets,
              };
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _PipelineItem(
                  step: s,
                  delayMs: 200 + (idx * 350),
                  alignRight: false,
                  isActive: widget.isActive,
                  design: design,
                ),
              );
            }),
          ],
        ),
      );
    }

    // Decreased central graph boundary: Panels take 33% width clamped between 300px and 440px
    final shadeW = (size.width * 0.33).clamp(300.0, 440.0);
    final fullBoundsX = size.width * 0.52;
    // Central graph boundary fits exact inner edges of side panels (marked by red lines)
    final centerHalfW = (size.width * 0.5) - shadeW;

    return AnimatedBuilder(
      animation: _shadeCtrl,
      builder: (context, _) {
        final t = Curves.easeInOutCubic.transform(_shadeCtrl.value);
        final currentPanelW = t * shadeW;
        // Bound shrinks smoothly from full-screen to the tighter central rectangle
        final currentBoundsX = lerpDouble(fullBoundsX, centerHalfW, t)!;

        return Stack(
          children: [
            // 1. Interactive network graph — spans full screen briefly, then clusters into central rectangle
            Positioned.fill(
              child: PipelineParticles(
                isActive: widget.isActive,
                currentBoundsX: currentBoundsX,
              ),
            ),

            // 2. Left square block panel (slides in smoothly; reverses on page exit)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: currentPanelW,
              child: const _CyberSquareBlockPanel(isLeft: true),
            ),

            // 3. Right square block panel (slides in smoothly; reverses on page exit)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: currentPanelW,
              child: const _CyberSquareBlockPanel(isLeft: false),
            ),

            // 4. Left content column (Steps 01, 03, 05) - Each with distinct HUD frame design
            if (_shadeCtrl.value > 0.05)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: shadeW,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    size.width > 1100 ? 44 : 24,
                    80,
                    24,
                    60,
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Sequential reveal: 01 Capture starts at 1100ms
                          _PipelineItem(
                            step: leftSteps[0],
                            delayMs: 1100,
                            alignRight: true,
                            isActive: widget.isActive,
                            design: CyberFrameDesign.topTabWedge,
                          ),
                          const SizedBox(height: 38),
                          // 03 Model starts at 2100ms
                          _PipelineItem(
                            step: leftSteps[1],
                            delayMs: 2100,
                            alignRight: true,
                            isActive: widget.isActive,
                            design: CyberFrameDesign.techDots,
                          ),
                          const SizedBox(height: 38),
                          // 05 Enforce starts at 3100ms
                          _PipelineItem(
                            step: leftSteps[2],
                            delayMs: 3100,
                            alignRight: true,
                            isActive: widget.isActive,
                            design: CyberFrameDesign.tacticalBrackets,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // 5. Right content column (Steps 02, 04) - Staggered vertically between left items
            if (_shadeCtrl.value > 0.05)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: shadeW,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    80,
                    size.width > 1100 ? 44 : 24,
                    60,
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Vertical offset so 02 sits between 01 and 03
                          const SizedBox(height: 56),
                          // 02 Detect starts at 1600ms
                          _PipelineItem(
                            step: rightSteps[0],
                            delayMs: 1600,
                            alignRight: false,
                            isActive: widget.isActive,
                            design: CyberFrameDesign.hazardStripes,
                          ),
                          const SizedBox(height: 48),
                          // 04 Generate starts at 2600ms
                          _PipelineItem(
                            step: rightSteps[1],
                            delayMs: 2600,
                            alignRight: false,
                            isActive: widget.isActive,
                            design: CyberFrameDesign.ladderFins,
                          ),
                          const SizedBox(height: 56),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─── Step data ───────────────────────────────────────────────
class _Step {
  final String num, title, desc;
  const _Step(this.num, this.title, this.desc);
}

// ─── Single pipeline item with CyberHudFrame and yellow hover ─────
class _PipelineItem extends StatefulWidget {
  final _Step step;
  final int delayMs;
  final bool alignRight;
  final bool isActive;
  final CyberFrameDesign design;

  const _PipelineItem({
    required this.step,
    required this.delayMs,
    required this.alignRight,
    required this.isActive,
    this.design = CyberFrameDesign.hazardStripes,
  });

  @override
  State<_PipelineItem> createState() => _PipelineItemState();
}

class _PipelineItemState extends State<_PipelineItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  bool hover = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    if (widget.isActive) {
      _triggerDelay();
    }
  }

  @override
  void didUpdateWidget(covariant _PipelineItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _c.reset();
      _triggerDelay();
    } else if (!widget.isActive) {
      _c.reset();
    }
  }

  void _triggerDelay() {
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted && widget.isActive) {
        _c.forward();
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = Curves.easeOutCubic.transform(_c.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 20),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => hover = true),
              onExit: (_) => setState(() => hover = false),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: CyberHudFrame(
                  design: widget.design,
                  baseBorderColor: const Color(0xFF80A416).withOpacity( 0.38),
                  hoverBorderColor: const Color(0xFFC5C764), // Yellow hover color!
                  surfaceColor: const Color(0xFF0F0F0F).withOpacity( 0.88), // Black tactical background
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  child: Column(
                    crossAxisAlignment: widget.alignRight
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      // Step Number badge & Title
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (widget.alignRight) ...[
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 220),
                              style: GoogleFonts.orbitron(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: hover
                                    ? const Color(0xFFC5C764) // Yellow on hover!
                                    : const Color(0xFFEDF5EB), // Crisp heading white by default
                                shadows: hover
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFFC5C764).withOpacity( 0.8),
                                          blurRadius: 16,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Text(widget.step.title),
                            ),
                            const SizedBox(width: 10),
                            _buildNumTag(),
                          ] else ...[
                            _buildNumTag(),
                            const SizedBox(width: 10),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 220),
                              style: GoogleFonts.orbitron(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: hover
                                    ? const Color(0xFFC5C764) // Yellow on hover!
                                    : const Color(0xFFEDF5EB), // Crisp heading white by default
                                shadows: hover
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFFC5C764).withOpacity( 0.8),
                                          blurRadius: 16,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Text(widget.step.title),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Paragraph Description (Clean silver-white by default, illuminates to crisp white)
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 220),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14.5,
                          height: 1.55,
                          fontWeight: FontWeight.w400,
                          color: hover
                              ? const Color(0xFFF8F8F8) // Pure crisp white on hover
                              : const Color(0xFFCBD5E1), // Clean high-contrast silver-white by default
                        ),
                        child: Text(
                          widget.step.desc,
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNumTag() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: hover
            ? const Color(0xFFC5C764).withOpacity( 0.25)
            : const Color(0xFF80A416).withOpacity( 0.18),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: hover
              ? const Color(0xFFC5C764)
              : const Color(0xFF80A416).withOpacity( 0.55),
          width: 1,
        ),
      ),
      child: Text(
        widget.step.num,
        style: GoogleFonts.shareTechMono(
          fontSize: 12.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.8,
          color: hover
              ? const Color(0xFFC5C764) // Yellow on hover!
              : const Color(0xFF80A416), // Olive green by default
        ),
      ),
    );
  }
}

// ─── Square Block Panel for Page 2 ───────────────────────────
class _CyberSquareBlockPanel extends StatelessWidget {
  final bool isLeft;
  const _CyberSquareBlockPanel({required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF090A0C),
      child: CustomPaint(
        painter: _SquareGridPainter(),
      ),
    );
  }
}

class _SquareGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF80A416).withOpacity(0.14)
      ..strokeWidth = 1.0;

    const double spacing = 52.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

