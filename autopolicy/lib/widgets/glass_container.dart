import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/colors.dart';
import '../providers/theme_provider.dart';

class GlassContainer extends ConsumerStatefulWidget {
  final Widget child;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final List<BoxShadow>? glow;
  final bool showHUDCorners;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const GlassContainer({
    key,
    required this.child,
    this.borderRadius = 18.0, // Soft curved corners matching the premium screenshot
    this.borderColor = CyberColors.borderNeonCyan,
    this.borderWidth = 1.2,
    this.glow,
    this.showHUDCorners = false, // Disabled by default for a pristine, clean isomorphic aesthetic!
    this.padding,
    this.width,
    this.height,
  });

  @override
  ConsumerState<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends ConsumerState<GlassContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    // Looping 12-second controller to drive the organic diagonal holographic sheen rhythm
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider);

    return MouseRegion(
      onEnter: (_) => Future.microtask(() {
        if (mounted) setState(() => _isHovered = true);
      }),
      onExit: (_) => Future.microtask(() {
        if (mounted) setState(() => _isHovered = false);
      }),
      child: AnimatedScale(
        scale: _isHovered ? 1.015 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -4.0 : 0.0, 0),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              // 1. Deep soft ambient occlusion shadow
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.70 : 0.06),
                blurRadius: _isHovered ? 36 : 24,
                spreadRadius: -4,
                offset: Offset(0, _isHovered ? 16 : 8),
              ),
              // 2. High-contrast glass casting shadow
              if (isDarkMode)
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(_isHovered ? 0.50 : 0.35),
                  blurRadius: _isHovered ? 24 : 16,
                  offset: Offset(0, _isHovered ? 8 : 4),
                ),
              if (!isDarkMode)
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(_isHovered ? 0.08 : 0.04),
                  blurRadius: _isHovered ? 24 : 16,
                  offset: Offset(0, _isHovered ? 8 : 4),
                ),
              // 3. Subtle ambient cyan/blue back-glow to blend card into background
              if (isDarkMode)
                BoxShadow(
                  color: const Color(0xFF00F5FF).withOpacity(_isHovered ? 0.08 : 0.04),
                  blurRadius: _isHovered ? 40 : 28,
                  spreadRadius: _isHovered ? 2 : 0,
                ),
              // 4. Secondary deep purple refraction back-glow
              if (isDarkMode)
                BoxShadow(
                  color: const Color(0xFF7000FF).withOpacity(_isHovered ? 0.12 : 0.06),
                  blurRadius: _isHovered ? 48 : 32,
                  spreadRadius: -2,
                  offset: const Offset(4, 4),
                ),
              // Light Mode specific neutral shadow layer (clean slate drop shadow)
              if (!isDarkMode)
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(_isHovered ? 0.08 : 0.04),
                  offset: Offset(_isHovered ? 4 : 2, _isHovered ? 4 : 2),
                  blurRadius: _isHovered ? 24 : 16,
                  spreadRadius: -2,
                ),
              if (!isDarkMode)
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(_isHovered ? 0.10 : 0.05),
                  blurRadius: _isHovered ? 32 : 20,
                  spreadRadius: -2,
                  offset: Offset(0, _isHovered ? 6 : 3),
                ),
              if (widget.glow != null) ...widget.glow!,
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: BackdropFilter(
              // Frosted glass refraction blur matching the premium screenshot
              filter: ImageFilter.blur(sigmaX: 26.0, sigmaY: 26.0),
              child: Stack(
                children: [
                  // 1. FROSTED BACKDROP & HOLOGRAPHIC WAVE LAYER (Background)
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) {
                          return CustomPaint(
                            painter: _IsomorphicGlassPainter(
                              animationProgress: _controller.value,
                              borderColor: widget.borderColor,
                              borderRadius: widget.borderRadius,
                              isDarkMode: isDarkMode,
                              isHovered: _isHovered,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // 2. UN-ANIMATED STATIC CONTENT LAYER (With optional breathing target brackets)
                  Container(
                    padding: widget.padding ?? const EdgeInsets.all(20), // Luxurious padding
                    child: widget.showHUDCorners
                        ? RepaintBoundary(
                            child: AnimatedBuilder(
                              animation: _controller,
                              child: widget.child,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: _HUDCornersPainter(
                                    widget.borderColor,
                                    _controller.value,
                                  ),
                                  child: child,
                                );
                              },
                            ),
                          )
                        : widget.child,
                  ),

                  // 3. GLOSSY 3D BEVEL BORDER (Foreground overlay)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: RepaintBoundary(
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: _IsomorphicBorderPainter(
                                borderColor: widget.borderColor,
                                borderRadius: widget.borderRadius,
                                borderWidth: widget.borderWidth,
                                isDarkMode: isDarkMode,
                                isHovered: _isHovered,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Paints the premium frosted glassmorphic backdrop with extremely subtle cosmic neon flows
class _IsomorphicGlassPainter extends CustomPainter {
  final double animationProgress;
  final Color borderColor;
  final double borderRadius;
  final bool isDarkMode;
  final bool isHovered;

  const _IsomorphicGlassPainter({
    required this.animationProgress,
    required this.borderColor,
    required this.borderRadius,
    required this.isDarkMode,
    required this.isHovered,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    canvas.clipRRect(rrect);

    // 1. Frosted slate-navy glassmorphism base gradient (Dark/Light specific)
    final baseGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        isDarkMode
            ? const Color(0xFF1E293B).withOpacity(0.48) // Frosted slate-blue top-left
            : const Color(0xFFF7F4FD).withOpacity(0.62),
        isDarkMode
            ? const Color(0xFF0F172A).withOpacity(0.38) // Deep slate-navy
            : const Color(0xFFEEE7FC).withOpacity(0.32),
        isDarkMode
            ? const Color(0xFF020617).withOpacity(0.48) // Bottom-right dark occlusion
            : const Color(0xFFE3D6FC).withOpacity(0.45),
      ],
      stops: const [0.0, 0.50, 1.0],
    );
    canvas.drawRRect(rrect, Paint()..shader = baseGradient.createShader(rect));

    // 2. Slow-flowing organic cosmic ambient currents (extremely faint)
    final waveProgress = animationProgress * 2 * math.pi;
    final speedFactor = isHovered ? 1.2 : 0.8;
    final cosmicGradient = LinearGradient(
      begin: Alignment(
        -1.0 + math.sin(waveProgress * speedFactor) * 0.2,
        -1.0 + math.cos(waveProgress * speedFactor) * 0.1,
      ),
      end: Alignment(
        1.0 + math.cos(waveProgress * speedFactor) * 0.2,
        1.0 + math.sin(waveProgress * speedFactor) * 0.1,
      ),
      colors: [
        isDarkMode
            ? const Color(0xFF7000FF).withOpacity(isHovered ? 0.04 : 0.02) // Faint purple current
            : Colors.white.withOpacity(isHovered ? 0.15 : 0.08),
        isDarkMode
            ? borderColor.withOpacity(isHovered ? 0.08 : 0.04)
            : const Color(0xFFF1F5F9).withOpacity(isHovered ? 0.12 : 0.06),
        isDarkMode
            ? const Color(0xFF00F5FF).withOpacity(isHovered ? 0.03 : 0.01)
            : Colors.white.withOpacity(isHovered ? 0.10 : 0.05),
        Colors.transparent,
      ],
      stops: const [0.0, 0.45, 0.75, 1.0],
    );
    canvas.drawRRect(rrect, Paint()..shader = cosmicGradient.createShader(rect));

    // 3. Elegant periodical diagonal holographic sheen sweep (3D sheen glide)
    final sweepProgress = (animationProgress * (isHovered ? 1.8 : 1.2)) % 1.0;
    final sweepGradient = LinearGradient(
      begin: Alignment(-3.0 + sweepProgress * 6.0, -1.0),
      end: Alignment(-2.0 + sweepProgress * 6.0, 1.0),
      colors: [
        Colors.transparent,
        Colors.white.withOpacity(0.01),
        Colors.white.withOpacity(isDarkMode ? (isHovered ? 0.07 : 0.03) : (isHovered ? 0.15 : 0.08)), // Slightly brighter sweep in Light Mode for contrast
        Colors.white.withOpacity(0.01),
        Colors.transparent,
      ],
      stops: const [0.0, 0.42, 0.50, 0.58, 1.0],
    );
    canvas.drawRRect(rrect, Paint()..shader = sweepGradient.createShader(rect));
  }

  @override
  bool shouldRepaint(covariant _IsomorphicGlassPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.isDarkMode != isDarkMode ||
        oldDelegate.isHovered != isHovered;
  }
}

// Paints an authentic 3D bevel stroke (bright glossy sheen top-left, dark shadow bottom-right)
class _IsomorphicBorderPainter extends CustomPainter {
  final Color borderColor;
  final double borderRadius;
  final double borderWidth;
  final bool isDarkMode;
  final bool isHovered;

  const _IsomorphicBorderPainter({
    required this.borderColor,
    required this.borderRadius,
    required this.borderWidth,
    required this.isDarkMode,
    required this.isHovered,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final paint = Paint()
      ..strokeWidth = isDarkMode ? borderWidth : borderWidth * 1.5
      ..style = PaintingStyle.stroke;

    if (isDarkMode) {
      // 3D Glass Bevel Gradient: high-gloss top-left, dark deep occlusion bottom-right
      paint.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(isHovered ? 0.45 : 0.30),               // 3D Bevel Top-Left Highlight
          borderColor.withOpacity(isHovered ? 0.22 : 0.12),                // Refracted neon bleed
          Colors.white.withOpacity(0.04),                                  // Faint middle outline
          Colors.black.withOpacity(isHovered ? 0.55 : 0.40),               // 3D Bottom-Right Occlusion Shadow
          Colors.black.withOpacity(isHovered ? 0.65 : 0.50),
        ],
        stops: const [0.0, 0.20, 0.45, 0.80, 1.0],
      ).createShader(rect);
    } else {
      // Crisp 3D bevel for Light Mode with a touch of the card's theme color
      paint.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.95), // Specular light highlight top-left
          borderColor.withOpacity(0.55),  // Stronger color refraction glow
          Colors.black.withOpacity(0.12), // Subtle occlusion definition
          Colors.black.withOpacity(0.32), // Deeper bevel shadow bottom-right
        ],
        stops: const [0.0, 0.35, 0.70, 1.0],
      ).createShader(rect);
    }

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _IsomorphicBorderPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.isDarkMode != isDarkMode ||
        oldDelegate.isHovered != isHovered;
  }
}

// Paints thin, delicate high-tech HUD breathing corner targeting brackets (turned off by default)
class _HUDCornersPainter extends CustomPainter {
  final Color glowColor;
  final double animationProgress;

  const _HUDCornersPainter(this.glowColor, this.animationProgress);

  @override
  void paint(Canvas canvas, Size size) {
    // Elegant desaturated slow breathing pulse
    final double pulse = 0.20 + 0.30 * math.sin(animationProgress * 2 * math.pi);
    final paint = Paint()
      ..color = glowColor.withOpacity(pulse)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const double cornerLen = 10.0;
    const double offset = 4.0;

    // Top-Left target
    canvas.drawLine(const Offset(offset, offset), const Offset(offset + cornerLen, offset), paint);
    canvas.drawLine(const Offset(offset, offset), const Offset(offset, offset + cornerLen), paint);

    // Top-Right target
    canvas.drawLine(Offset(size.width - offset, offset), Offset(size.width - offset - cornerLen, offset), paint);
    canvas.drawLine(Offset(size.width - offset, offset), Offset(size.width - offset, offset + cornerLen), paint);

    // Bottom-Left target
    canvas.drawLine(Offset(offset, size.height - offset), Offset(offset + cornerLen, size.height - offset), paint);
    canvas.drawLine(Offset(offset, size.height - offset), Offset(offset, size.height - offset - cornerLen), paint);

    // Bottom-Right target
    canvas.drawLine(Offset(size.width - offset, size.height - offset), Offset(size.width - offset - cornerLen, size.height - offset), paint);
    canvas.drawLine(Offset(size.width - offset, size.height - offset), Offset(size.width - offset, size.height - offset - cornerLen), paint);
  }

  @override
  bool shouldRepaint(covariant _HUDCornersPainter oldDelegate) {
    return oldDelegate.glowColor != glowColor ||
        oldDelegate.animationProgress != animationProgress;
  }
}
