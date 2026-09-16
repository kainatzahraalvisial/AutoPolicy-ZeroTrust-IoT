import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/colors.dart';
import '../providers/theme_provider.dart';

/// Cyber HUD Container matching the cyber hacking UI aesthetic.
/// Replaces legacy rounded blue glass containers with chamfered cut corners,
/// solid dark obsidian background (#0A0A0E), and sharp cyber borders.
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
    super.key,
    required this.child,
    this.borderRadius = 14.0,
    this.borderColor = CyberColors.borderNeonCyan,
    this.borderWidth = 1.2,
    this.glow,
    this.showHUDCorners = true,
    this.padding,
    this.width,
    this.height,
  });

  @override
  ConsumerState<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends ConsumerState<GlassContainer> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider);
    final effectiveBorderColor = isDarkMode
        ? widget.borderColor
        : (widget.borderColor == CyberColors.borderNeonCyan || widget.borderColor == CyberColors.neonGreen
            ? const Color(0xFFCDD4B2)
            : widget.borderColor);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width,
        height: widget.height,
        child: CustomPaint(
          painter: _ChamferedPanelPainter(
            borderColor: _isHovered ? effectiveBorderColor : effectiveBorderColor.withOpacity(isDarkMode ? 0.65 : 0.85),
            borderWidth: widget.borderWidth,
            backgroundColor: isDarkMode ? const Color(0xFF0A0A0E) : Colors.white,
            chamferSize: widget.borderRadius,
            showCorners: widget.showHUDCorners,
          ),
          child: Container(
            padding: widget.padding ?? const EdgeInsets.all(16),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _ChamferedPanelPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final Color backgroundColor;
  final double chamferSize;
  final bool showCorners;

  _ChamferedPanelPainter({
    required this.borderColor,
    required this.borderWidth,
    required this.backgroundColor,
    required this.chamferSize,
    required this.showCorners,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double c = chamferSize.clamp(8.0, 16.0);

    // Chamfered Path (cut top-left notch and bottom-right notch)
    final path = Path()
      ..moveTo(c, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h - c)
      ..lineTo(w - c, h)
      ..lineTo(0, h)
      ..lineTo(0, c)
      ..close();

    // 1. Solid Opaque Background Fill
    final fillPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // 2. Subtle Dark Inner Glow
    final glowPaint = Paint()
      ..color = borderColor.withOpacity(0.04)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, glowPaint);

    // 3. Cyber Outer Border Stroke
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, borderPaint);

    // 4. Chamfer Cut Corner Highlight Lines
    if (showCorners) {
      final cornerPaint = Paint()
        ..color = borderColor
        ..strokeWidth = borderWidth * 1.8
        ..style = PaintingStyle.stroke;

      // Top-Left Chamfer Line
      canvas.drawLine(Offset(c, 0), Offset(0, c), cornerPaint);
      // Bottom-Right Chamfer Line
      canvas.drawLine(Offset(w, h - c), Offset(w - c, h), cornerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ChamferedPanelPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.chamferSize != chamferSize ||
        oldDelegate.showCorners != showCorners;
  }
}
