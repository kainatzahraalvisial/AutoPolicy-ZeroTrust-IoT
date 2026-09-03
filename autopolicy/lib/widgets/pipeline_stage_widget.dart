import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pipeline_particle_canvas.dart';

class PipelineStageWidget extends StatefulWidget {
  final bool isActive;
  const PipelineStageWidget({super.key, required this.isActive});

  @override
  State<PipelineStageWidget> createState() => _PipelineStageWidgetState();
}

class _PipelineStageWidgetState extends State<PipelineStageWidget> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 960;

    final double shadeWidth = isDesktop
        ? min(340.0, max(200.0, size.width * 0.28))
        : size.width * 0.45;

    return Stack(
      children: [
        // 1. Center Window Particle Canvas
        const Positioned.fill(
          child: PipelineParticleCanvas(),
        ),

        // 2. Black Side Panels closing in from left and right
        AnimatedPositioned(
          duration: const Duration(milliseconds: 3200),
          curve: const Cubic(0.22, 1.0, 0.36, 1.0),
          left: 0,
          top: 0,
          bottom: 0,
          width: widget.isActive ? shadeWidth : 0,
          child: Container(
            color: Colors.black,
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 3200),
          curve: const Cubic(0.22, 1.0, 0.36, 1.0),
          right: 0,
          top: 0,
          bottom: 0,
          width: widget.isActive ? shadeWidth : 0,
          child: Container(
            color: Colors.black,
          ),
        ),

        // 3. Left Text Column (Sitting on Left Shade)
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: shadeWidth,
          child: Container(
            padding: EdgeInsets.fromLTRB(isDesktop ? 20 : 12, 48, isDesktop ? 28 : 16, 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _PipelineItemWidget(
                  stepNum: '01',
                  stepTitle: 'Capture',
                  stepDesc:
                      'Zeek monitors IoT flows in real time — extracting IPs, ports, protocols, and duration into structured buffers.',
                  delayMs: 1600,
                  isActive: widget.isActive,
                  isLeft: true,
                ),
                const SizedBox(height: 36),
                _PipelineItemWidget(
                  stepNum: '03',
                  stepTitle: 'Model',
                  stepDesc:
                      'GNN maps device relationships as a graph — exposing abnormal communication invisible to rule-based IDS.',
                  delayMs: 2800,
                  isActive: widget.isActive,
                  isLeft: true,
                ),
                const SizedBox(height: 36),
                _PipelineItemWidget(
                  stepNum: '05',
                  stepTitle: 'Enforce',
                  stepDesc:
                      'OPA deploys policies in real time. Role-based dashboard lets admins review, approve, and manage.',
                  delayMs: 4000,
                  isActive: widget.isActive,
                  isLeft: true,
                ),
              ],
            ),
          ),
        ),

        // 4. Right Text Column (Sitting on Right Shade)
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: shadeWidth,
          child: Container(
            padding: EdgeInsets.fromLTRB(isDesktop ? 28 : 16, 48, isDesktop ? 20 : 12, 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PipelineItemWidget(
                  stepNum: '02',
                  stepTitle: 'Detect',
                  stepDesc:
                      'Hybrid ML classifier identifies 33 attack categories including DDoS, lateral movement, and Mirai botnet.',
                  delayMs: 2200,
                  isActive: widget.isActive,
                  isLeft: false,
                ),
                const SizedBox(height: 36),
                _PipelineItemWidget(
                  stepNum: '04',
                  stepTitle: 'Generate',
                  stepDesc:
                      'Transformer model converts detected patterns into zero-trust JSON policies automatically.',
                  delayMs: 3400,
                  isActive: widget.isActive,
                  isLeft: false,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PipelineItemWidget extends StatefulWidget {
  final String stepNum;
  final String stepTitle;
  final String stepDesc;
  final int delayMs;
  final bool isActive;
  final bool isLeft;

  const _PipelineItemWidget({
    required this.stepNum,
    required this.stepTitle,
    required this.stepDesc,
    required this.delayMs,
    required this.isActive,
    required this.isLeft,
  });

  @override
  State<_PipelineItemWidget> createState() => _PipelineItemWidgetState();
}

class _PipelineItemWidgetState extends State<_PipelineItemWidget> {
  bool _isHovered = false;
  bool _shouldShow = false;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _triggerDelay();
    }
  }

  @override
  void didUpdateWidget(covariant _PipelineItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _triggerDelay();
    } else if (!widget.isActive) {
      setState(() => _shouldShow = false);
    }
  }

  void _triggerDelay() {
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted && widget.isActive) {
        setState(() => _shouldShow = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final numColor = _isHovered ? const Color(0xFFBBF438) : const Color(0xFFC5C764);
    final titleColor = _isHovered ? const Color(0xFFC5C764) : const Color(0xFFF5EDF8);
    final descColor = _isHovered ? Colors.white : const Color(0xFF829A80);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOut,
      opacity: _shouldShow ? (_isHovered ? 1.0 : 0.9) : 0.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        curve: const Cubic(0.16, 1.0, 0.3, 1.0),
        transform: _shouldShow
            ? Matrix4.identity()
            : (Matrix4.identity()..translate(0.0, 24.0, 0.0)),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 260),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.stepNum,
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: numColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  widget.stepTitle,
                  style: GoogleFonts.orbitron(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: titleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  widget.stepDesc,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w300,
                    height: 1.75,
                    color: descColor,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
