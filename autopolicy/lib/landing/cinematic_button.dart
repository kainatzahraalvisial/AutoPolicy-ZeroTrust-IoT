import 'package:flutter/material.dart';

class CinematicButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool filled, compact, angular;
  const CinematicButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.filled = false,
      this.compact = false,
      this.angular = false});
  @override
  State<CinematicButton> createState() => _CinematicButtonState();
}

class _CinematicButtonState extends State<CinematicButton> {
  bool hover = false, focus = false;
  @override
  Widget build(BuildContext context) {
    const lime = Color(0xFF94B51A);
    final active = hover || focus;
    final reduced = MediaQuery.of(context).disableAnimations;
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: reduced ? 0 : 180),
        transform: Matrix4.translationValues(0, active ? -2 : 0, 0),
        decoration: BoxDecoration(
            boxShadow: active && widget.filled
                ? [
                    BoxShadow(
                        color: lime.withOpacity(widget.filled ? .52 : .28),
                        blurRadius: 48,
                        spreadRadius: 6),
                    BoxShadow(
                        color: const Color(0xFFC4E326).withOpacity(.24),
                        blurRadius: 20,
                        spreadRadius: 1)
                  ]
                : []),
        child: CustomPaint(
          painter: widget.angular
              ? _AngularHeroPainter(widget.filled, active,
                  Theme.of(context).brightness == Brightness.dark)
              : widget.filled
                  ? _RaisedButtonPainter(active)
                  : null,
          child: TextButton(
            onPressed: widget.onPressed,
            onFocusChange: (value) => setState(() => focus = value),
            style: TextButton.styleFrom(
              backgroundColor: widget.angular || widget.filled
                  ? Colors.transparent
                  : lime.withOpacity(active ? .15 : .04),
              foregroundColor: widget.filled
                  ? const Color(0xFF111507)
                  : Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFFBFD46D)
                      : const Color(0xFF607810),
              minimumSize: Size(0, widget.compact ? 40 : 48),
              padding: EdgeInsets.fromLTRB(widget.compact ? 22 : 38, 18,
                  widget.compact ? 22 : 38, widget.filled ? 26 : 18),
              shape: const _CutCornerBorder(),
              side: widget.angular || widget.filled
                  ? BorderSide.none
                  : BorderSide(color: lime.withOpacity(.45)),
            ),
            child: Text(widget.label.toUpperCase(),
                style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontWeight: FontWeight.w600,
                    fontSize: widget.compact ? 9 : 10,
                    letterSpacing: 1.2)),
          ),
        ),
      ),
    );
  }
}

class _AngularHeroPainter extends CustomPainter {
  final bool filled, active, dark;
  const _AngularHeroPainter(this.filled, this.active, this.dark);
  Path shape(Rect r) => Path()
    ..moveTo(r.left + 19, r.top)
    ..lineTo(r.right, r.top)
    ..lineTo(r.right - 19, r.bottom)
    ..lineTo(r.left, r.bottom)
    ..close();
  @override
  void paint(Canvas canvas, Size size) {
    final face = Rect.fromLTWH(7, 8, size.width - 14, size.height - 18);
    const lime = Color(0xFFBADC29);
    final accent = dark ? const Color(0xFFEDF3E8) : const Color(0xFF5E7343);
    canvas.drawPath(shape(face.shift(const Offset(0, 4))),
        Paint()..color = const Color(0xFF344207).withOpacity(filled ? 1 : .3));
    canvas.drawPath(
        shape(face),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: filled
                ? [
                    active ? const Color(0xFFE0F979) : const Color(0xFFD5F368),
                    lime
                  ]
                : [
                    lime.withOpacity(active ? .10 : .025),
                    lime.withOpacity(.015)
                  ],
          ).createShader(face));
    canvas.drawPath(
        shape(face),
        Paint()
          ..color = lime
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2);
    // Offset end caps echo the reference without changing the existing palette.
    canvas.drawPath(
        Path()
          ..moveTo(0, face.bottom + 2)
          ..lineTo(21, 3)
          ..lineTo(40, 3)
          ..lineTo(35, 7)
          ..lineTo(24, 7)
          ..lineTo(5, face.bottom + 2)
          ..close(),
        Paint()..color = accent);
    canvas.drawPath(
        Path()
          ..moveTo(size.width - 36, size.height - 5)
          ..lineTo(size.width - 17, size.height - 5)
          ..lineTo(size.width - 2, face.top + 12)
          ..lineTo(size.width - 7, face.top + 12)
          ..lineTo(size.width - 20, size.height - 9)
          ..lineTo(size.width - 33, size.height - 9)
          ..close(),
        Paint()..color = accent);
  }

  @override
  bool shouldRepaint(_AngularHeroPainter old) =>
      old.active != active || old.filled != filled || old.dark != dark;
}

// A solid lower rim, sloped face and thin lit edge give the CTA real depth.
class _RaisedButtonPainter extends CustomPainter {
  final bool active;
  const _RaisedButtonPainter(this.active);

  Path outline(Rect r) => Path()
    ..moveTo(r.left + 17, r.top)
    ..lineTo(r.right - 2, r.top)
    ..lineTo(r.right, r.bottom - 10)
    ..lineTo(r.right - 15, r.bottom)
    ..lineTo(r.left + 1, r.bottom)
    ..lineTo(r.left, r.top + 10)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    final face = Rect.fromLTWH(1, 1, size.width - 3, size.height - 6);
    canvas.drawPath(outline(face.shift(const Offset(1, 4))),
        Paint()..color = const Color(0xFF344207));
    canvas.drawPath(
        outline(face),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: active
                ? const [Color(0xFFE0F979), Color(0xFFBADC29)]
                : const [Color(0xFFD5F368), Color(0xFFA6C626)],
          ).createShader(face));
    canvas.drawPath(
        outline(face),
        Paint()
          ..color = const Color(0xFFEAFF9A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = .8);
    canvas.drawPath(
        Path()
          ..moveTo(face.left + 2, face.bottom + 3)
          ..lineTo(face.right - 14, face.bottom + 3)
          ..lineTo(face.right + 1, face.bottom - 7),
        Paint()
          ..color = const Color(0xFF738A29)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(_RaisedButtonPainter oldDelegate) =>
      oldDelegate.active != active;
}

class _CutCornerBorder extends OutlinedBorder {
  const _CutCornerBorder({super.side});
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);
  @override
  ShapeBorder scale(double t) => _CutCornerBorder(side: side.scale(t));
  @override
  OutlinedBorder copyWith({BorderSide? side}) =>
      _CutCornerBorder(side: side ?? this.side);
  @override
  Path getOuterPath(Rect r, {TextDirection? textDirection}) => Path()
    ..moveTo(r.left + 11, r.top)
    ..lineTo(r.right, r.top)
    ..lineTo(r.right, r.bottom - 11)
    ..lineTo(r.right - 11, r.bottom)
    ..lineTo(r.left, r.bottom)
    ..lineTo(r.left, r.top + 11)
    ..close();
  @override
  Path getInnerPath(Rect r, {TextDirection? textDirection}) =>
      getOuterPath(r.deflate(side.width));
  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style != BorderStyle.none) {
      canvas.drawPath(
          getOuterPath(rect),
          Paint()
            ..color = side.color
            ..strokeWidth = side.width
            ..style = PaintingStyle.stroke);
    }
  }
}

class CinematicNavLink extends StatefulWidget {
  final String label;
  final bool active;
  final Color foreground;
  final VoidCallback onPressed;
  const CinematicNavLink(
      {super.key,
      required this.label,
      required this.active,
      required this.foreground,
      required this.onPressed});
  @override
  State<CinematicNavLink> createState() => _CinematicNavLinkState();
}

class _CinematicNavLinkState extends State<CinematicNavLink> {
  bool hovered = false, focused = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: TextButton(
          onPressed: widget.onPressed,
          onFocusChange: (v) => setState(() => focused = v),
          style: TextButton.styleFrom(
              overlayColor: const Color(0xFF94B51A).withOpacity(.1)),
          child: AnimatedDefaultTextStyle(
              duration: Duration(
                  milliseconds:
                      MediaQuery.of(context).disableAnimations ? 0 : 180),
              style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  letterSpacing: 1.5,
                  color: widget.active || hovered || focused
                      ? const Color(0xFFBCDA27)
                      : widget.foreground.withOpacity(.7)),
              child: Text(widget.label.toUpperCase(),
                  semanticsLabel: widget.label))));
}
