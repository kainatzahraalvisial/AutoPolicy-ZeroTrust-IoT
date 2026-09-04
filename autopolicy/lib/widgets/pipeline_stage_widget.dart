import 'package:flutter/material.dart';
import 'pipeline_particle_canvas.dart';

// ─────────────────────────────────────────────────────────────
// PIPELINE PAGE  (page index 1)
// Exact structure of original HTML #page-1 with replay capability
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

  // Same data as the HTML
  static const leftSteps = [
    _Step('01', 'Capture',
        'Zeek monitors IoT flows in real time — extracting IPs, ports, protocols, and duration into structured buffers.'),
    _Step('03', 'Model',
        'GNN maps device relationships as a graph — exposing abnormal communication invisible to rule-based IDS.'),
    _Step('05', 'Enforce',
        'OPA deploys policies in real time. Role-based dashboard lets admins review, approve, and manage.'),
  ];

  static const rightSteps = [
    _Step('02', 'Detect',
        'Hybrid ML classifier identifies 33 attack categories including DDoS, lateral movement, and Mirai botnet.'),
    _Step('04', 'Generate',
        'Transformer model converts detected patterns into zero-trust JSON policies automatically.'),
  ];

  @override
  void initState() {
    super.initState();
    // Matches CSS: transition width 3.2s cubic-bezier(.22, 1, .36, 1)
    _shadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    if (widget.isActive) {
      _shadeCtrl.forward();
    }
  }

  @override
  void didUpdateWidget(covariant PipelinePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _shadeCtrl.reset();
      _shadeCtrl.forward();
    } else if (!widget.isActive && oldWidget.isActive) {
      _shadeCtrl.reset();
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
    final isNarrow = size.width < 960;

    // Final shade width = clamp(200px, 28vw, 340px)  ← exact CSS
    final shadeW = isNarrow ? 0.0 : (size.width * 0.28).clamp(200.0, 340.0);

    if (isNarrow) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
        child: Column(
          children: [
            const SizedBox(
              height: 200,
              child: PipelineParticles(),
            ),
            const SizedBox(height: 24),
            ...[...leftSteps, ...rightSteps].map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: PipelineItem(
                  step: s,
                  delayMs: 0,
                  alignRight: false,
                  isActive: widget.isActive,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // 1. Full-bleed particle field (pipeline-window)
        const Positioned.fill(child: PipelineParticles()),

        // 2. Black side panels that slowly close in
        AnimatedBuilder(
          animation: _shadeCtrl,
          builder: (_, __) {
            final t = Curves.easeOutCubic.transform(_shadeCtrl.value);
            final w = t * shadeW;
            return Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: w,
                  child: const ColoredBox(color: Colors.black),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: w,
                  child: const ColoredBox(color: Colors.black),
                ),
              ],
            );
          },
        ),

        // 3. Left text column (sits on the left shade)
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: shadeW,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 48, 28, 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // delays match original: 1.6s, 2.8s, 4.0s
                PipelineItem(
                  step: leftSteps[0],
                  delayMs: 1600,
                  alignRight: true,
                  isActive: widget.isActive,
                ),
                const SizedBox(height: 40),
                PipelineItem(
                  step: leftSteps[1],
                  delayMs: 2800,
                  alignRight: true,
                  isActive: widget.isActive,
                ),
                const SizedBox(height: 40),
                PipelineItem(
                  step: leftSteps[2],
                  delayMs: 4000,
                  alignRight: true,
                  isActive: widget.isActive,
                ),
              ],
            ),
          ),
        ),

        // 4. Right text column
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: shadeW,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 48, 20, 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // delays match original: 2.2s, 3.4s
                PipelineItem(
                  step: rightSteps[0],
                  delayMs: 2200,
                  alignRight: false,
                  isActive: widget.isActive,
                ),
                const SizedBox(height: 40),
                PipelineItem(
                  step: rightSteps[1],
                  delayMs: 3400,
                  alignRight: false,
                  isActive: widget.isActive,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Step data ───────────────────────────────────────────────
class _Step {
  final String num, title, desc;
  const _Step(this.num, this.title, this.desc);
}

// ─── Single pipeline item (matches .pipeline-item) ───────────
class PipelineItem extends StatefulWidget {
  final _Step step;
  final int delayMs;
  final bool alignRight;
  final bool isActive;

  const PipelineItem({
    super.key,
    required this.step,
    required this.delayMs,
    required this.alignRight,
    required this.isActive,
  });

  @override
  State<PipelineItem> createState() => _PipelineItemState();
}

class _PipelineItemState extends State<PipelineItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  bool hover = false;

  @override
  void initState() {
    super.initState();
    // CSS: transition opacity 1s ease, transform 1s cubic-bezier(.16,1,.3,1)
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.isActive) {
      _triggerDelay();
    }
  }

  @override
  void didUpdateWidget(covariant PipelineItem oldWidget) {
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
      if (mounted && widget.isActive) _c.forward();
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
          opacity: t * (hover ? 1.0 : 0.9),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 24),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => hover = true),
              onExit: (_) => setState(() => hover = false),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.step.num,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                        color: hover
                            ? const Color(0xFFBBF438)
                            : const Color(0xFFC5C764),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.step.title,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 17.6,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: hover
                            ? const Color(0xFFC5C764)
                            : const Color(0xFFEDF5EB),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.step.desc,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.75,
                        color: hover
                            ? const Color(0xFFEDF5EB)
                            : const Color(0xFF829A80),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
