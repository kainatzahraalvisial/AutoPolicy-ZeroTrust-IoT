import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CyberHudCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const double cornerTopLeft = 14.0;
    const double cornerTopRight = 22.0;
    const double cornerBottomRight = 14.0;
    const double cornerBottomLeft = 22.0;

    path.moveTo(0, cornerTopLeft);
    path.lineTo(cornerTopLeft, 0);
    path.lineTo(size.width - cornerTopRight, 0);
    path.lineTo(size.width, cornerTopRight);
    path.lineTo(size.width, size.height - cornerBottomRight);
    path.lineTo(size.width - cornerBottomRight, size.height);
    path.lineTo(cornerBottomLeft, size.height);
    path.lineTo(0, size.height - cornerBottomLeft);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class CyberHudFramePainter extends CustomPainter {
  final Color frameColor;
  final bool isHovered;

  CyberHudFramePainter({
    required this.frameColor,
    required this.isHovered,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double cornerTL = 14.0;
    const double cornerTR = 22.0;
    const double cornerBR = 14.0;
    const double cornerBL = 22.0;

    final path = Path();
    path.moveTo(0, cornerTL);
    path.lineTo(cornerTL, 0);
    path.lineTo(size.width - cornerTR, 0);
    path.lineTo(size.width, cornerTR);
    path.lineTo(size.width, size.height - cornerBR);
    path.lineTo(size.width - cornerBR, size.height);
    path.lineTo(cornerBL, size.height);
    path.lineTo(0, size.height - cornerBL);
    path.close();

    // 1. Fill background with sleek dark cyber black (#08120C)
    final fillPaint = Paint()
      ..color = isHovered
          ? const Color(0xFF0D1D13)
          : const Color(0xFF08120C)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // 2. Outer border stroke (#C5C764 Lime Gold)
    final borderPaint = Paint()
      ..color = isHovered ? const Color(0xFFBBF438) : frameColor
      ..strokeWidth = isHovered ? 2.0 : 1.4
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, borderPaint);

    // 3. Top Centered Trapezoid Cap Notch
    const double capWidth = 52.0;
    const double capHeight = 7.0;
    final capPath = Path();
    final double capLeft = (size.width - capWidth) / 2;
    capPath.moveTo(capLeft + 6, 0);
    capPath.lineTo(capLeft + capWidth - 6, 0);
    capPath.lineTo(capLeft + capWidth, capHeight);
    capPath.lineTo(capLeft, capHeight);
    capPath.close();

    final capPaint = Paint()
      ..color = isHovered ? const Color(0xFFBBF438) : const Color(0xFF80A416)
      ..style = PaintingStyle.fill;
    canvas.drawPath(capPath, capPaint);

    // 4. Top-Left Corner L-Bracket (┌)
    final tlBracketPaint = Paint()
      ..color = isHovered ? const Color(0xFFBBF438) : frameColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const double tlX = 14.0;
    const double tlY = 16.0;
    const double bracketLen = 14.0;
    canvas.drawLine(const Offset(tlX, tlY), const Offset(tlX + bracketLen, tlY), tlBracketPaint);
    canvas.drawLine(const Offset(tlX, tlY), const Offset(tlX, tlY + bracketLen), tlBracketPaint);

    // 5. Bottom-Right Corner L-Bracket (┘)
    final brBracketPaint = Paint()
      ..color = isHovered ? const Color(0xFFBBF438) : frameColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final double brX = size.width - 14.0;
    final double brY = size.height - 16.0;
    canvas.drawLine(Offset(brX, brY), Offset(brX - bracketLen, brY), brBracketPaint);
    canvas.drawLine(Offset(brX, brY), Offset(brX, brY - bracketLen), brBracketPaint);

    // 6. Top-Right 3 Square Dots (...)
    final dotPaint = Paint()
      ..color = isHovered ? const Color(0xFFBBF438) : frameColor
      ..style = PaintingStyle.fill;

    final double trX = size.width - 28.0;
    const double trY = 14.0;
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(trX + (i * 6), trY, 3, 3),
        dotPaint,
      );
    }

    // 7. Bottom-Left Diagonal Zebra Hatch Stripes (/////)
    final stripePaint = Paint()
      ..color = isHovered ? const Color(0xFFBBF438) : frameColor.withOpacity(0.5)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    const double blX = 16.0;
    final double blY = size.height - 14.0;
    for (int i = 0; i < 5; i++) {
      final double xOffset = blX + (i * 5);
      canvas.drawLine(
        Offset(xOffset, blY),
        Offset(xOffset + 4, blY - 6),
        stripePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CyberHudFramePainter oldDelegate) {
    return oldDelegate.frameColor != frameColor || oldDelegate.isHovered != isHovered;
  }
}

class CyberHudCard extends StatefulWidget {
  final String num;
  final String title;
  final String desc;
  final int delayMs;
  final bool isActive;

  const CyberHudCard({
    super.key,
    required this.num,
    required this.title,
    required this.desc,
    required this.delayMs,
    required this.isActive,
  });

  @override
  State<CyberHudCard> createState() => _CyberHudCardState();
}

class _CyberHudCardState extends State<CyberHudCard> {
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
  void didUpdateWidget(covariant CyberHudCard oldWidget) {
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
    const frameColor = Color(0xFFC5C764);
    final numColor = _isHovered ? const Color(0xFFBBF438) : const Color(0xFF80A416);
    final titleColor = _isHovered ? const Color(0xFFBBF438) : const Color(0xFFAD9F3C);
    final descColor = _isHovered ? const Color(0xFFEDF5EB) : const Color(0xFF829A80);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 950),
      curve: const Cubic(0.16, 1.0, 0.3, 1.0),
      opacity: _shouldShow ? 1.0 : 0.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        height: 220, // Equal height for all cards
        transform: _shouldShow
            ? (_isHovered
                ? (Matrix4.identity()..translate(0.0, -8.0, 0.0)..scale(1.02))
                : Matrix4.identity())
            : (Matrix4.identity()..translate(0.0, -40.0, 0.0)),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: CustomPaint(
            painter: CyberHudFramePainter(
              frameColor: frameColor,
              isHovered: _isHovered,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.num,
                        style: GoogleFonts.orbitron(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: _isHovered ? 1.8 : 0.5,
                          color: numColor,
                          shadows: [
                            Shadow(
                              color: numColor.withOpacity(0.45),
                              blurRadius: _isHovered ? 24 : 12,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.title,
                        style: GoogleFonts.orbitron(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: _isHovered ? 2.0 : 1.4,
                          color: titleColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    widget.desc,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w300,
                      height: 1.65,
                      color: descColor,
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
