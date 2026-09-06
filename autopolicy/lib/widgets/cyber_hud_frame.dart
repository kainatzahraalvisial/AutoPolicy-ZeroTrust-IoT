import 'package:flutter/material.dart';

enum CyberFrameDesign {
  hazardStripes,   // Bottom-right chamfer with diagonal hazard warning stripes (///)
  topTabWedge,     // Glowing top tab + chamfered bottom-left corner with accent wedge
  ladderFins,      // Side barcode / ventilation ladder fins + angled top-right cut
  techDots,        // Vertical tech dot matrix + dual chamfers and outer brackets
  tacticalBrackets,// Corner HUD targeting brackets (┌ ┐ └ ┘) + top header notch
  stealthHex,      // Asymmetric dual chamfers + technical corner crosshairs
  reticleCut,      // Inverse chamfer (top-right & bottom-left) + HUD reticle targeting marks
  cornerPlate,     // Double chamfered right side + heavy armored corner plates & segmented baseline
}

class CyberHudFrame extends StatefulWidget {
  final Widget child;
  final CyberFrameDesign design;
  final Color baseBorderColor;
  final Color hoverBorderColor;
  final Color surfaceColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool isInteractive;
  final double? width;
  final double? height;
  final bool showGrid;

  const CyberHudFrame({
    super.key,
    required this.child,
    this.design = CyberFrameDesign.hazardStripes,
    this.baseBorderColor = const Color(0xFF80A416),
    this.hoverBorderColor = const Color(0xFFC5C764), // Palette yellow on hover!
    this.surfaceColor = const Color(0xFF0F0F0F),     // Deep tactical black from palette
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.isInteractive = true,
    this.width,
    this.height,
    this.showGrid = false,
  });

  @override
  State<CyberHudFrame> createState() => _CyberHudFrameState();
}

class _CyberHudFrameState extends State<CyberHudFrame> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activeBorderColor = _isHovered ? widget.hoverBorderColor : widget.baseBorderColor;

    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (widget.isInteractive) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (widget.isInteractive) setState(() => _isHovered = false);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -5.0 : 0.0, 0),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.hoverBorderColor.withValues(alpha: 0.22),
                      blurRadius: 22,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.85),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.50),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: CustomPaint(
            painter: _CyberHudFramePainter(
              design: widget.design,
              borderColor: activeBorderColor,
              surfaceColor: widget.surfaceColor,
              isHovered: _isHovered,
              showGrid: widget.showGrid,
            ),
            child: ClipPath(
              clipper: _CyberHudClipper(widget.design),
              child: Container(
                color: Colors.transparent,
                padding: widget.padding,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CLIPPER: Matches inner content bounds to frame cuts
// ─────────────────────────────────────────────────────────────
class _CyberHudClipper extends CustomClipper<Path> {
  final CyberFrameDesign design;
  _CyberHudClipper(this.design);

  @override
  Path getClip(Size size) {
    final path = Path();
    const chamfer = 20.0;
    final w = size.width;
    final h = size.height;

    switch (design) {
      case CyberFrameDesign.hazardStripes:
        // Cut bottom-right
        path.moveTo(0, 0);
        path.lineTo(w, 0);
        path.lineTo(w, h - chamfer);
        path.lineTo(w - chamfer, h);
        path.lineTo(0, h);
        path.close();
        break;

      case CyberFrameDesign.topTabWedge:
        // Cut bottom-left
        path.moveTo(0, 0);
        path.lineTo(w, 0);
        path.lineTo(w, h);
        path.lineTo(chamfer, h);
        path.lineTo(0, h - chamfer);
        path.close();
        break;

      case CyberFrameDesign.ladderFins:
        // Cut top-right and slight bottom-left
        path.moveTo(0, 0);
        path.lineTo(w - chamfer, 0);
        path.lineTo(w, chamfer);
        path.lineTo(w, h);
        path.lineTo(12, h);
        path.lineTo(0, h - 12);
        path.close();
        break;

      case CyberFrameDesign.techDots:
        // Cut top-left and bottom-right
        path.moveTo(chamfer, 0);
        path.lineTo(w, 0);
        path.lineTo(w, h - chamfer);
        path.lineTo(w - chamfer, h);
        path.lineTo(0, h);
        path.lineTo(0, chamfer);
        path.close();
        break;

      case CyberFrameDesign.tacticalBrackets:
        // Cut all 4 corners slightly (10px)
        const c = 10.0;
        path.moveTo(c, 0);
        path.lineTo(w - c, 0);
        path.lineTo(w, c);
        path.lineTo(w, h - c);
        path.lineTo(w - c, h);
        path.lineTo(c, h);
        path.lineTo(0, h - c);
        path.lineTo(0, c);
        path.close();
        break;

      case CyberFrameDesign.stealthHex:
        // Hexagonal cuts on top-left (14px) and bottom-right (26px)
        path.moveTo(14, 0);
        path.lineTo(w, 0);
        path.lineTo(w, h - 26);
        path.lineTo(w - 26, h);
        path.lineTo(0, h);
        path.lineTo(0, 14);
        path.close();
        break;

      case CyberFrameDesign.reticleCut:
        // Inverse chamfers: top-right (22px) and bottom-left (22px)
        path.moveTo(0, 0);
        path.lineTo(w - 22, 0);
        path.lineTo(w, 22);
        path.lineTo(w, h);
        path.lineTo(22, h);
        path.lineTo(0, h - 22);
        path.close();
        break;

      case CyberFrameDesign.cornerPlate:
        // Chamfers on top-right (16px) and bottom-right (16px)
        path.moveTo(0, 0);
        path.lineTo(w - 16, 0);
        path.lineTo(w, 16);
        path.lineTo(w, h - 16);
        path.lineTo(w - 16, h);
        path.lineTo(0, h);
        path.close();
        break;
    }
    return path;
  }

  @override
  bool shouldReclip(covariant _CyberHudClipper oldClipper) =>
      oldClipper.design != design;
}

// ─────────────────────────────────────────────────────────────
// PAINTER: Renders the custom tactical frame graphics
// ─────────────────────────────────────────────────────────────
class _CyberHudFramePainter extends CustomPainter {
  final CyberFrameDesign design;
  final Color borderColor;
  final Color surfaceColor;
  final bool isHovered;
  final bool showGrid;

  _CyberHudFramePainter({
    required this.design,
    required this.borderColor,
    required this.surfaceColor,
    required this.isHovered,
    required this.showGrid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final fillPaint = Paint()
      ..color = surfaceColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = borderColor
      ..strokeWidth = isHovered ? 1.6 : 1.2
      ..style = PaintingStyle.stroke;

    final accentPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;

    final dimPaint = Paint()
      ..color = borderColor.withValues(alpha: isHovered ? 0.35 : 0.18)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Optional interior grid lines
    if (showGrid) {
      const spacing = 28.0;
      final gridPaint = Paint()
        ..color = borderColor.withValues(alpha: 0.05)
        ..strokeWidth = 0.8;
      for (double x = spacing; x < w; x += spacing) {
        canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
      }
      for (double y = spacing; y < h; y += spacing) {
        canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
      }
    }

    switch (design) {
      case CyberFrameDesign.hazardStripes:
        _paintHazardStripes(canvas, w, h, fillPaint, strokePaint, accentPaint, dimPaint);
        break;
      case CyberFrameDesign.topTabWedge:
        _paintTopTabWedge(canvas, w, h, fillPaint, strokePaint, accentPaint, dimPaint);
        break;
      case CyberFrameDesign.ladderFins:
        _paintLadderFins(canvas, w, h, fillPaint, strokePaint, accentPaint, dimPaint);
        break;
      case CyberFrameDesign.techDots:
        _paintTechDots(canvas, w, h, fillPaint, strokePaint, accentPaint, dimPaint);
        break;
      case CyberFrameDesign.tacticalBrackets:
        _paintTacticalBrackets(canvas, w, h, fillPaint, strokePaint, accentPaint, dimPaint);
        break;
      case CyberFrameDesign.stealthHex:
        _paintStealthHex(canvas, w, h, fillPaint, strokePaint, accentPaint, dimPaint);
        break;
      case CyberFrameDesign.reticleCut:
        _paintReticleCut(canvas, w, h, fillPaint, strokePaint, accentPaint, dimPaint);
        break;
      case CyberFrameDesign.cornerPlate:
        _paintCornerPlate(canvas, w, h, fillPaint, strokePaint, accentPaint, dimPaint);
        break;
    }
  }

  // 1. Hazard Stripes: Chamfer bottom-right with diagonal stripes (///)
  void _paintHazardStripes(Canvas canvas, double w, double h, Paint fillPaint, Paint strokePaint, Paint accentPaint, Paint dimPaint) {
    const chamfer = 22.0;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h - chamfer)
      ..lineTo(w - chamfer, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Diagonal hazard warning stripes along bottom-right cut
    const stripeCount = 5;
    final stripePaint = Paint()
      ..color = borderColor.withValues(alpha: isHovered ? 0.95 : 0.60)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.square;

    for (int i = 0; i < stripeCount; i++) {
      final double offset = (i * 4.5);
      final p1 = Offset(w - chamfer + offset - 4, h - 2);
      final p2 = Offset(w - chamfer + offset + 2, h - 8);
      canvas.drawLine(p1, p2, stripePaint);
    }

    // Top-left technical tick
    canvas.drawLine(const Offset(0, 0), const Offset(14, 0), Paint()..color = borderColor..strokeWidth = 3.0);
    canvas.drawLine(const Offset(0, 0), const Offset(0, 14), Paint()..color = borderColor..strokeWidth = 3.0);
  }

  // 2. Top Tab Wedge: Glowing top tab + bottom-left accent wedge
  void _paintTopTabWedge(Canvas canvas, double w, double h, Paint fillPaint, Paint strokePaint, Paint accentPaint, Paint dimPaint) {
    const chamfer = 22.0;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h)
      ..lineTo(chamfer, h)
      ..lineTo(0, h - chamfer)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Glowing top center protruding tab
    const tabW = 64.0;
    const tabH = 5.0;
    final tabX = (w - tabW) / 2;
    final tabPath = Path()
      ..moveTo(tabX, 0)
      ..lineTo(tabX + 6, -tabH)
      ..lineTo(tabX + tabW - 6, -tabH)
      ..lineTo(tabX + tabW, 0)
      ..close();

    final glowTabPaint = Paint()
      ..color = borderColor.withValues(alpha: isHovered ? 0.90 : 0.45)
      ..style = PaintingStyle.fill;
    canvas.drawPath(tabPath, glowTabPaint);

    if (isHovered) {
      final blurPaint = Paint()
        ..color = borderColor.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(tabPath, blurPaint);
    }

    // Bottom-left solid accent wedge
    final wedgePath = Path()
      ..moveTo(0, h - chamfer)
      ..lineTo(chamfer, h)
      ..lineTo(chamfer - 8, h)
      ..lineTo(0, h - chamfer + 8)
      ..close();
    canvas.drawPath(wedgePath, Paint()..color = borderColor..style = PaintingStyle.fill);
  }

  // 3. Ladder Fins: Side barcode ladder fins + top-right cut
  void _paintLadderFins(Canvas canvas, double w, double h, Paint fillPaint, Paint strokePaint, Paint accentPaint, Paint dimPaint) {
    const chamfer = 20.0;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w - chamfer, 0)
      ..lineTo(w, chamfer)
      ..lineTo(w, h)
      ..lineTo(12, h)
      ..lineTo(0, h - 12)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Right-side barcode / heat fin lines
    const finCount = 6;
    final finPaint = Paint()
      ..color = borderColor.withValues(alpha: isHovered ? 0.90 : 0.55)
      ..strokeWidth = 2.0;

    const startY = 32.0;
    for (int i = 0; i < finCount; i++) {
      final y = startY + (i * 7.0);
      canvas.drawLine(Offset(w - 7, y), Offset(w - 2, y), finPaint);
    }

    // Top-right cut accent highlight
    canvas.drawLine(Offset(w - chamfer, 0), Offset(w, chamfer), Paint()..color = borderColor..strokeWidth = 2.5);
  }

  // 4. Tech Dots: Vertical micro-dot array + dual chamfers
  void _paintTechDots(Canvas canvas, double w, double h, Paint fillPaint, Paint strokePaint, Paint accentPaint, Paint dimPaint) {
    const chamfer = 18.0;
    final path = Path()
      ..moveTo(chamfer, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h - chamfer)
      ..lineTo(w - chamfer, h)
      ..lineTo(0, h)
      ..lineTo(0, chamfer)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Vertical dot array along left edge
    const dotCount = 7;
    final dotPaint = Paint()
      ..color = borderColor.withValues(alpha: isHovered ? 0.95 : 0.50)
      ..style = PaintingStyle.fill;

    final double startY = (h - (dotCount * 7.0)) / 2;
    for (int i = 0; i < dotCount; i++) {
      canvas.drawCircle(Offset(6.5, startY + (i * 7.0)), 1.4, dotPaint);
    }

    // Top-left double bracket mark
    canvas.drawLine(const Offset(chamfer + 2, 3), const Offset(chamfer + 14, 3), Paint()..color = borderColor..strokeWidth = 1.8);
  }

  // 5. Tactical Brackets: Corner HUD brackets (┌ ┐ └ ┘) + top notch plate
  void _paintTacticalBrackets(Canvas canvas, double w, double h, Paint fillPaint, Paint strokePaint, Paint accentPaint, Paint dimPaint) {
    const c = 10.0;
    final path = Path()
      ..moveTo(c, 0)
      ..lineTo(w - c, 0)
      ..lineTo(w, c)
      ..lineTo(w, h - c)
      ..lineTo(w - c, h)
      ..lineTo(c, h)
      ..lineTo(0, h - c)
      ..lineTo(0, c)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Corner targeting brackets
    const bLen = 14.0;
    final bracketPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 2.4;

    // Top-Left
    canvas.drawLine(const Offset(0, 0), const Offset(bLen, 0), bracketPaint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, bLen), bracketPaint);

    // Top-Right
    canvas.drawLine(Offset(w, 0), Offset(w - bLen, 0), bracketPaint);
    canvas.drawLine(Offset(w, 0), Offset(w, bLen), bracketPaint);

    // Bottom-Left
    canvas.drawLine(Offset(0, h), Offset(bLen, h), bracketPaint);
    canvas.drawLine(Offset(0, h), Offset(0, h - bLen), bracketPaint);

    // Bottom-Right
    canvas.drawLine(Offset(w, h), Offset(w - bLen, h), bracketPaint);
    canvas.drawLine(Offset(w, h), Offset(w, h - bLen), bracketPaint);
  }

  // 6. Stealth Hex: Hex cuts + corner crosshairs
  void _paintStealthHex(Canvas canvas, double w, double h, Paint fillPaint, Paint strokePaint, Paint accentPaint, Paint dimPaint) {
    final path = Path()
      ..moveTo(14, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h - 26)
      ..lineTo(w - 26, h)
      ..lineTo(0, h)
      ..lineTo(0, 14)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Corner crosshairs on top-right
    final crossPaint = Paint()
      ..color = borderColor.withValues(alpha: isHovered ? 0.90 : 0.50)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(w - 18, 8), Offset(w - 8, 8), crossPaint);
    canvas.drawLine(Offset(w - 13, 3), Offset(w - 13, 13), crossPaint);

    // Bottom-right double chamfer border
    final subPath = Path()
      ..moveTo(w, h - 22)
      ..lineTo(w - 22, h);
    canvas.drawPath(subPath, Paint()..color = borderColor.withValues(alpha: 0.5)..strokeWidth = 1.0..style = PaintingStyle.stroke);
  }

  // 7. Reticle Cut: Inverse chamfers + HUD reticle targeting marks
  void _paintReticleCut(Canvas canvas, double w, double h, Paint fillPaint, Paint strokePaint, Paint accentPaint, Paint dimPaint) {
    const chamfer = 22.0;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w - chamfer, 0)
      ..lineTo(w, chamfer)
      ..lineTo(w, h)
      ..lineTo(chamfer, h)
      ..lineTo(0, h - chamfer)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Diagonal cut highlights
    canvas.drawLine(Offset(w - chamfer, 0), Offset(w, chamfer), Paint()..color = borderColor..strokeWidth = 2.5);
    canvas.drawLine(Offset(0, h - chamfer), Offset(chamfer, h), Paint()..color = borderColor..strokeWidth = 2.5);

    // Top-left HUD reticle targeting crosshair
    final reticlePaint = Paint()
      ..color = borderColor.withValues(alpha: isHovered ? 0.95 : 0.55)
      ..strokeWidth = 1.2;
    canvas.drawLine(const Offset(8, 14), const Offset(20, 14), reticlePaint);
    canvas.drawLine(const Offset(14, 8), const Offset(14, 20), reticlePaint);
    canvas.drawCircle(const Offset(14, 14), 3.0, Paint()..color = borderColor.withValues(alpha: isHovered ? 0.95 : 0.55)..style = PaintingStyle.stroke..strokeWidth = 1.0);

    // Right edge telemetry tick marks
    for (int i = 0; i < 4; i++) {
      final y = (h / 2) - 12 + (i * 8.0);
      canvas.drawLine(Offset(w - 6, y), Offset(w - 1, y), Paint()..color = borderColor.withValues(alpha: 0.60)..strokeWidth = 1.5);
    }
  }

  // 8. Corner Plate: Double chamfered right side + armored plates & segmented baseline
  void _paintCornerPlate(Canvas canvas, double w, double h, Paint fillPaint, Paint strokePaint, Paint accentPaint, Paint dimPaint) {
    const chamfer = 16.0;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w - chamfer, 0)
      ..lineTo(w, chamfer)
      ..lineTo(w, h - chamfer)
      ..lineTo(w - chamfer, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Heavy armored plates on left corners
    final platePaint = Paint()..color = borderColor..strokeWidth = 3.0;
    canvas.drawLine(const Offset(0, 0), const Offset(18, 0), platePaint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, 18), platePaint);
    canvas.drawLine(Offset(0, h), Offset(18, h), platePaint);
    canvas.drawLine(Offset(0, h), Offset(0, h - 18), platePaint);

    // Top status micro tabs
    canvas.drawRect(const Rect.fromLTWH(26, 0, 22, 3), Paint()..color = borderColor);
    canvas.drawRect(const Rect.fromLTWH(52, 0, 10, 3), Paint()..color = borderColor.withValues(alpha: 0.5));

    // Segmented baseline along bottom
    final basePaint = Paint()..color = borderColor.withValues(alpha: isHovered ? 0.80 : 0.35)..strokeWidth = 1.5;
    for (double bx = 28; bx < w - 30; bx += 14) {
      canvas.drawLine(Offset(bx, h), Offset(bx + 8, h), basePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CyberHudFramePainter oldDelegate) {
    return oldDelegate.design != design ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.surfaceColor != surfaceColor ||
        oldDelegate.isHovered != isHovered ||
        oldDelegate.showGrid != showGrid;
  }
}
