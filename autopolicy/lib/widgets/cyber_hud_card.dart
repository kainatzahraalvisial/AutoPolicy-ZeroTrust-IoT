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

class _CyberHudCardState extends State<CyberHudCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _shouldShow = false;
  late final AnimationController _textCtrl;

  @override
  void initState() {
    super.initState();
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
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
      _textCtrl.reset();
    }
  }

  void _triggerDelay() {
    _textCtrl.reset();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted && widget.isActive) {
        setState(() => _shouldShow = true);
        _textCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const frameColor = Color(0xFFC5C764);
    // Use palette yellow #C5C764 on hover
    final numColor = _isHovered ? const Color(0xFFC5C764) : const Color(0xFF80A416);
    final titleColor = _isHovered ? const Color(0xFFC5C764) : const Color(0xFFAD9F3C);
    final descColor = _isHovered ? const Color(0xFFEDF5EB) : const Color(0xFFCBD5E1);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 750),
      curve: const Cubic(0.16, 1.0, 0.3, 1.0),
      opacity: _shouldShow ? 1.0 : 0.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        height: 270, // Increased height for enhanced visibility & prominent typography
        transform: _shouldShow
            ? (_isHovered
                ? (Matrix4.identity()..translate(0.0, -8.0, 0.0)..scale(1.02))
                : Matrix4.identity())
            : (Matrix4.identity()..translate(0.0, -36.0, 0.0)),
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
              padding: const EdgeInsets.fromLTRB(28, 30, 28, 26),
              child: AnimatedBuilder(
                animation: _textCtrl,
                builder: (context, _) {
                  final t = Curves.easeOutCubic.transform(_textCtrl.value);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Text Animation: Number slides & scales into place
                          Transform.translate(
                            offset: Offset(0, (1 - t) * 18),
                            child: Opacity(
                              opacity: t,
                              child: Text(
                                widget.num,
                                style: GoogleFonts.orbitron(
                                  fontSize: 44, // Prominently visible size
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: _isHovered ? 2.0 : 0.6,
                                  color: numColor,
                                  shadows: [
                                    Shadow(
                                      color: numColor.withOpacity(0.55),
                                      blurRadius: _isHovered ? 24 : 14,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // 2. Text Animation: Title slides into place
                          Transform.translate(
                            offset: Offset(0, (1 - t) * 14),
                            child: Opacity(
                              opacity: (t * 1.2).clamp(0.0, 1.0),
                              child: Text(
                                widget.title,
                                style: GoogleFonts.orbitron(
                                  fontSize: 13.5, // Crisp, legible size
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: _isHovered ? 2.2 : 1.5,
                                  color: titleColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 3. Text Animation: Description slides up with smooth opacity
                      Transform.translate(
                        offset: Offset(0, (1 - t) * 12),
                        child: Opacity(
                          opacity: (t * 1.4 - 0.2).clamp(0.0, 1.0),
                          child: Text(
                            widget.desc,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15.0, // Highly readable font size
                              fontWeight: FontWeight.w400,
                              height: 1.55,
                              color: descColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
