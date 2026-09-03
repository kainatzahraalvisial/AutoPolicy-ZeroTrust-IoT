import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChamferedClipper extends CustomClipper<Path> {
  final double chamfer;
  ChamferedClipper({this.chamfer = 14.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(chamfer, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - chamfer);
    path.lineTo(size.width - chamfer, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, chamfer);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant ChamferedClipper oldClipper) =>
      oldClipper.chamfer != chamfer;
}

class ChamferedCyberButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color hoverColor;
  final Color textColor;
  final double fontSize;
  final EdgeInsets padding;

  const ChamferedCyberButton({
    super.key,
    required this.text,
    required this.onTap,
    this.backgroundColor = const Color(0xFF80A416),
    this.hoverColor = const Color(0xFFBBF438),
    this.textColor = Colors.black,
    this.fontSize = 11.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
  });

  @override
  State<ChamferedCyberButton> createState() => _ChamferedCyberButtonState();
}

class _ChamferedCyberButtonState extends State<ChamferedCyberButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final currentColor = _isHovered ? widget.hoverColor : widget.backgroundColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: _isHovered
              ? (Matrix4.identity()..translate(0.0, -2.0, 0.0))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: currentColor.withOpacity(_isHovered ? 0.7 : 0.45),
                blurRadius: _isHovered ? 32 : 22,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipPath(
            clipper: ChamferedClipper(chamfer: 14),
            child: Container(
              color: currentColor,
              padding: widget.padding,
              child: Text(
                widget.text,
                style: GoogleFonts.orbitron(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: widget.textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
