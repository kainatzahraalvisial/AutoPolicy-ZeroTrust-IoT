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
  const VrFrame({super.key, required this.child, this.maxWidth = 400, this.padding});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth + 28),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AP.bg,
                border: Border.all(color: AP.lime, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AP.lime.withOpacity(0.2),
                    blurRadius: 20,
                  ),
                  BoxShadow(
                    color: AP.olive.withOpacity(0.08),
                    blurRadius: 50,
                  ),
                ],
              ),
              child: ClipPath(
                clipper: VrFrameClipper(cut: 16),
                child: Container(
                  color: AP.bg,
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
                    Container(width: 18, height: 1.5, color: AP.lime.withOpacity(0.6)),
                    const SizedBox(width: 4),
                    ClipPath(
                      clipper: _NotchClipper(),
                      child: Container(width: 56, height: 8, color: AP.olive),
                    ),
                    const SizedBox(width: 4),
                    Container(width: 18, height: 1.5, color: AP.lime.withOpacity(0.6)),
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
                        color: AP.olive,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(width: 1.5, height: 36, color: AP.lime),
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
                              color: AP.lime.withOpacity(0.75),
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
                        color: AP.olive,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(width: 1.5, height: 36, color: AP.lime),
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
                              color: AP.lime.withOpacity(0.75),
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
  const FieldShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: FieldClipper(),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xE608120C),
          border: Border.all(color: AP.olive.withOpacity(0.35)),
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

  const CyberButton({
    super.key,
    required this.label,
    this.onTap,
    this.primary = true,
    this.leading,
  });

  @override
  State<CyberButton> createState() => _CyberButtonState();
}

class _CyberButtonState extends State<CyberButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
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
                color: widget.primary
                    ? (hover ? AP.bright : AP.olive)
                    : (hover
                        ? AP.olive.withOpacity(0.12)
                        : const Color(0xE608120C)),
                border: widget.primary
                    ? null
                    : Border.all(
                        color: hover ? AP.lime : AP.olive.withOpacity(0.35),
                      ),
                boxShadow: widget.primary
                    ? [
                        BoxShadow(
                          color: (hover ? AP.bright : AP.olive)
                              .withOpacity(hover ? 0.65 : 0.4),
                          blurRadius: hover ? 28 : 18,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.leading != null) ...[
                    widget.leading!,
                    const SizedBox(width: 9),
                  ],
                  Text(
                    widget.label.toUpperCase(),
                    style: GoogleFonts.orbitron(
                      fontSize: widget.primary ? 11 : 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                      color: widget.primary
                          ? Colors.black
                          : (hover ? AP.bright : AP.lime),
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
