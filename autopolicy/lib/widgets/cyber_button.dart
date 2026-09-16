import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── AP Palette (Dark Cyber Base) ──────────────────────────────
class AP {
  static const olive = Color(0xFF80A416);
  static const lime = Color(0xFFC5C764);
  static const bright = Color(0xFFBBF438);
  static const white = Color(0xFFEDF5EB);
  static const muted = Color(0xFF829A80);
  static const frame = Color(0xFFC5C764);
  static const bg = Color(0xFF050A07); // Pure dark cyber black
}

// ── Shared VR frame clippers ──────────────────────────────────
class VrFrameClipper extends CustomClipper<Path> {
  final double cut;
  VrFrameClipper({this.cut = 18});

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - cut)
      ..lineTo(size.width - cut, size.height)
      ..lineTo(cut, size.height)
      ..lineTo(0, size.height - cut)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class FieldClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const c = 8.0;
    return Path()
      ..moveTo(c, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - c)
      ..lineTo(size.width - c, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, c)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class BtnClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const c = 10.0;
    return Path()
      ..moveTo(c, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - c)
      ..lineTo(size.width - c, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, c)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _NotchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(6, 0)
      ..lineTo(size.width - 6, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AP.olive.withOpacity(0.55)
      ..strokeWidth = 2;
    for (double x = -size.height; x < size.width + size.height; x += 5) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── VR Frame container (side tabs + protruding lines) ─────────
class VrFrame extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool isDarkMode;

  const VrFrame({
    super.key,
    required this.child,
    this.maxWidth = 400,
    this.padding,
    this.isDarkMode = true,
  });

  @override
  Widget build(BuildContext context) {
    final frameBg = isDarkMode ? AP.bg : Colors.white;
    final frameBorder = isDarkMode ? AP.lime : const Color(0xFFCDD4B2);
    final tabColor = isDarkMode ? AP.olive : const Color(0xFFD4C9D8);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth + 28),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: frameBg,
                border: Border.all(color: frameBorder, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? AP.lime.withOpacity(0.2) : const Color(0xFFCDD4B2).withOpacity(0.25),
                    blurRadius: 20,
                  ),
                  BoxShadow(
                    color: isDarkMode ? AP.olive.withOpacity(0.08) : const Color(0xFFD4C9D8).withOpacity(0.15),
                    blurRadius: 50,
                  ),
                ],
              ),
              child: ClipPath(
                clipper: VrFrameClipper(cut: 16),
                child: Container(
                  color: frameBg,
                  padding: padding ?? const EdgeInsets.fromLTRB(26, 28, 26, 20),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: CustomPaint(
                          size: const Size(32, 7),
                          painter: _StripePainter(),
                        ),
                      ),
                      child,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -1,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 18, height: 1.5, color: frameBorder.withOpacity(0.6)),
                    const SizedBox(width: 4),
                    ClipPath(
                      clipper: _NotchClipper(),
                      child: Container(width: 56, height: 8, color: tabColor),
                    ),
                    const SizedBox(width: 4),
                    Container(width: 18, height: 1.5, color: frameBorder.withOpacity(0.6)),
                  ],
                ),
              ),
            ),
            Positioned(
              left: -11,
              top: 0,
              bottom: 0,
              child: Center(
                child: SizedBox(
                  width: 11,
                  height: 36,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 11,
                        height: 36,
                        color: tabColor,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(width: 1.5, height: 36, color: frameBorder),
                        ),
                      ),
                      Positioned(
                        left: -10,
                        top: 6,
                        child: Column(
                          children: List.generate(
                            3,
                            (i) => Container(
                              margin: EdgeInsets.only(bottom: i < 2 ? 6 : 0),
                              width: 10,
                              height: 2,
                              color: frameBorder.withOpacity(0.75),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -11,
              top: 0,
              bottom: 0,
              child: Center(
                child: SizedBox(
                  width: 11,
                  height: 36,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 11,
                        height: 36,
                        color: tabColor,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(width: 1.5, height: 36, color: frameBorder),
                        ),
                      ),
                      Positioned(
                        right: -10,
                        top: 6,
                        child: Column(
                          children: List.generate(
                            3,
                            (i) => Container(
                              margin: EdgeInsets.only(bottom: i < 2 ? 6 : 0),
                              width: 10,
                              height: 2,
                              color: frameBorder.withOpacity(0.75),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Field shell ──────────────────────────────────────────────
class FieldShell extends StatelessWidget {
  final Widget child;
  final bool isDarkMode;
  const FieldShell({super.key, required this.child, this.isDarkMode = true});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: FieldClipper(),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xE608120C) : const Color(0xFFFAF9F6), // Feather White box fill
          border: Border.all(
            color: isDarkMode ? AP.olive.withOpacity(0.35) : const Color(0xFFCDD4B2), // Sage outline from new palette
            width: 1.2,
          ),
        ),
        child: child,
      ),
    );
  }
}

// ── Cyber button ─────────────────────────────────────────────
class CyberButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool primary;
  final Widget? leading;
  final bool isDarkMode;

  const CyberButton({
    super.key,
    required this.label,
    this.onTap,
    this.primary = true,
    this.leading,
    this.isDarkMode = true,
  });

  @override
  State<CyberButton> createState() => _CyberButtonState();
}

class _CyberButtonState extends State<CyberButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    // Darker lavender from user's new palette for authentication button
    final primaryColor = widget.isDarkMode
        ? (hover ? const Color(0xFFC4E320) : const Color(0xFF80A416))
        : (hover ? const Color(0xFFA695B0) : const Color(0xFFB8A9C1));
    final primaryTextColor = widget.isDarkMode
        ? Colors.black
        : const Color(0xFF0F172A); // Black text
    final secondaryBg = widget.isDarkMode
        ? (hover ? AP.olive.withOpacity(0.12) : const Color(0xE608120C))
        : (hover ? const Color(0xFFD4C9D8).withOpacity(0.35) : const Color(0xFFFAF9F6)); // Feather white
    final secondaryTextColor = widget.isDarkMode
        ? (hover ? AP.bright : AP.lime)
        : const Color(0xFF0F172A); // Black text

    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          transform: Matrix4.translationValues(0, hover ? -1 : 0, 0),
          child: ClipPath(
            clipper: BtnClipper(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
              decoration: BoxDecoration(
                color: widget.primary ? primaryColor : secondaryBg,
                border: widget.primary
                    ? (widget.isDarkMode ? null : Border.all(color: const Color(0xFF9E8DA7), width: 1.2))
                    : Border.all(
                        color: hover 
                            ? const Color(0xFFB8A9C1) 
                            : (widget.isDarkMode ? AP.olive.withOpacity(0.35) : const Color(0xFFCDD4B2)),
                        width: 1.2,
                      ),
                boxShadow: widget.primary
                    ? [
                        BoxShadow(
                          color: primaryColor.withOpacity(hover ? 0.50 : 0.30),
                          blurRadius: hover ? 24 : 14,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.leading != null) ...[
                    widget.leading!,
                    const SizedBox(width: 10),
                  ],
                  Text(
                    widget.label.toUpperCase(),
                    style: GoogleFonts.orbitron(
                      color: widget.primary ? primaryTextColor : secondaryTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
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
