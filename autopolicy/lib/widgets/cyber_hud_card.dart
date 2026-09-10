import 'package:flutter/material.dart';

/// Reusable Cyber Futuristic HUD Card with chamfered/cut angled corners
/// and technical corner tags (e.g. H17, H18, SYS-01) matching the cyber hacking aesthetic.
class CyberHudCard extends StatelessWidget {
  final Widget? child;
  final String? tag; // e.g. 'H17', 'H18', 'SYS-01'
  final String? num;
  final String? title;
  final String? desc;
  final String? label;
  final int? delayMs;
  final bool? isActive;
  final Color borderColor;
  final double borderWidth;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final double chamferSize;
  final VoidCallback? onTap;

  const CyberHudCard({
    super.key,
    this.child,
    this.tag,
    this.num,
    this.title,
    this.desc,
    this.label,
    this.delayMs,
    this.isActive,
    this.borderColor = const Color(0xFF5DD62C),
    this.borderWidth = 1.2,
    this.backgroundColor = const Color(0xFF0F0F0F),
    this.padding = const EdgeInsets.all(16.0),
    this.chamferSize = 14.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (child != null) {
      content = child!;
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (num != null) ...[
            Text(
              num!,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF5DD62C),
                fontFamily: 'monospace',
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
          ],
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 6),
          ],
          if (desc != null) ...[
            Text(
              desc!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
                height: 1.4,
              ),
            ),
          ],
        ],
      );
    }

    Widget cardBody = CustomPaint(
      painter: _ChamferedCardPainter(
        borderColor: borderColor,
        borderWidth: borderWidth,
        backgroundColor: backgroundColor,
        chamferSize: chamferSize,
      ),
      child: Container(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            content,
            if (tag != null || label != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  tag ?? label ?? '',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9,
                    color: Color(0xFF80A416),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        hoverColor: borderColor.withOpacity(0.08),
        splashColor: borderColor.withOpacity(0.15),
        child: cardBody,
      );
    }

    return cardBody;
  }
}

class _ChamferedCardPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final Color backgroundColor;
  final double chamferSize;

  _ChamferedCardPainter({
    required this.borderColor,
    required this.borderWidth,
    required this.backgroundColor,
    required this.chamferSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final c = chamferSize;

    // Create chamfered path (cut top-left notch and cut bottom-right corner)
    final path = Path()
      ..moveTo(c, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h - c)
      ..lineTo(w - c, h)
      ..lineTo(0, h)
      ..lineTo(0, c)
      ..close();

    // Fill background
    final fillPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Subtle inner fill glow
    final glowPaint = Paint()
      ..color = borderColor.withOpacity(0.04)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, glowPaint);

    // Outer cyber border
    final borderPaint = Paint()
      ..color = borderColor.withOpacity(0.60)
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, borderPaint);

    // Glowing corner notches
    final cornerAccentPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth * 1.8
      ..style = PaintingStyle.stroke;

    // Top-left chamfer accent line
    canvas.drawLine(Offset(c, 0), Offset(0, c), cornerAccentPaint);
    // Bottom-right chamfer accent line
    canvas.drawLine(Offset(w, h - c), Offset(w - c, h), cornerAccentPaint);
  }

  @override
  bool shouldRepaint(covariant _ChamferedCardPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.chamferSize != chamferSize;
  }
}
