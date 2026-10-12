import 'package:flutter/material.dart';

class CinematicButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool filled, compact, angular, navbar;
  const CinematicButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.filled = false,
      this.compact = false,
      this.angular = false,
      this.navbar = false});
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
        duration: Duration(milliseconds: reduced ? 0 : 240),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, active ? -2 : 0, 0),
        decoration: BoxDecoration(
            boxShadow: active && widget.filled
                ? [
                    BoxShadow(
                        color: lime.withOpacity(widget.filled ? .30 : .13),
                        blurRadius: 32,
                        spreadRadius: 1),
                    BoxShadow(
                        color: const Color(0xFFC4E326)
                            .withOpacity(widget.filled ? .17 : .09),
                        blurRadius: 14,
                        spreadRadius: 0)
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
              overlayColor:
                  widget.angular && !widget.filled ? Colors.transparent : null,
              backgroundColor: widget.angular || widget.filled
                  ? Colors.transparent
                  : lime.withOpacity(active ? .15 : .04),
              foregroundColor: widget.filled
                  ? const Color(0xFF111507)
                  : Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFFBFD46D)
                      : const Color(0xFF607810),
              minimumSize: Size(0, widget.compact ? 44 : 52),
              padding: EdgeInsets.symmetric(
                  horizontal: widget.navbar
                      ? 18
                      : widget.compact
                          ? 24
                          : 32,
                  vertical: widget.navbar
                      ? 10
                      : widget.compact
                          ? 14
                          : 18),
              shape: const _CutCornerBorder(),
              side: widget.angular || widget.filled
                  ? BorderSide.none
                  : BorderSide(color: lime.withOpacity(.45)),
            ),
            child: Text(widget.label.toUpperCase(),
                style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontWeight: FontWeight.w600,
                    fontSize: widget.navbar ? 11 : (widget.compact ? 11 : 12.5),
                    letterSpacing: widget.navbar ? .8 : 1.3)),
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
    ..moveTo(r.left + 11, r.top)
    ..lineTo(r.right, r.top)
    ..lineTo(r.right, r.bottom - 11)
    ..lineTo(r.right - 11, r.bottom)
    ..lineTo(r.left, r.bottom)
    ..lineTo(r.left, r.top + 11)
    ..close();
  @override
  void paint(Canvas canvas, Size size) {
    final face = Rect.fromLTWH(1, 1, size.width - 2, size.height - 4);
    const lime = Color(0xFFBADC29);
    if (!filled) {
      final outline = shape(face);
      final gradient = LinearGradient(
          colors: dark
              ? const [
                  Color(0xFFC4E326),
                  Color(0xFFFFEDA8),
                  Color(0xFFB1A9DA),
                  Color(0xFF9D8DF1)
                ]
              : const [
                  Color(0xFF526B0E),
                  Color(0xFF796326),
                  Color(0xFF72608A)
                ]);
      if (active) {
        canvas.save();
        // Exclude the button face: the halo can only fall outside the boundary.
        canvas.clipPath(Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(face.inflate(40))
          ..addPath(outline, Offset.zero));
        canvas.drawPath(
            outline,
            Paint()
              ..shader = gradient.createShader(face)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 5
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9));
        canvas.restore();
      }
      canvas.drawPath(
          outline,
          Paint()
            ..shader = gradient.createShader(face)
            ..style = PaintingStyle.stroke
            ..strokeWidth = active ? 1.6 : 1);
      return;
    }
    canvas.drawPath(
        Path.combine(PathOperation.difference,
            shape(face.shift(const Offset(0, 2))), shape(face)),
        Paint()..color = const Color(0xFF344207).withOpacity(filled ? 1 : .2));
    canvas.drawPath(
        shape(face),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: filled
                ? [
                    active ? const Color(0xFFFFF9D2) : const Color(0xFFFFEDA8),
                    const Color(0xFFC4E326),
                    const Color(0xFF80A416)
                  ]
                : [
                    lime.withOpacity(active ? .14 : .025),
                    lime.withOpacity(active ? .05 : .01)
                  ],
          ).createShader(face));
    canvas.drawPath(
        shape(face),
        Paint()
          ..color = filled
              ? const Color(0xFFD9EA89).withOpacity(.7)
              : (dark ? lime : const Color(0xFF526B0E))
                  .withOpacity(active ? .9 : .55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = .9);
    // A fine lit upper bevel adds depth without decorative end-cap clutter.
    canvas.drawLine(
        const Offset(13, 2),
        Offset(size.width - 16, 2),
        Paint()
          ..color =
              (filled ? Colors.white : lime).withOpacity(active ? .45 : .20)
          ..strokeWidth = .6);
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
  final bool compact;
  final Color foreground;
  final VoidCallback onPressed;
  const CinematicNavLink(
      {super.key,
      required this.label,
      required this.active,
      this.compact = false,
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
              minimumSize: const Size(0, 44),
              padding:
                  EdgeInsets.symmetric(horizontal: widget.compact ? 8 : 12),
              overlayColor: const Color(0xFF94B51A).withOpacity(.1)),
          child: AnimatedDefaultTextStyle(
              duration: Duration(
                  milliseconds:
                      MediaQuery.of(context).disableAnimations ? 0 : 180),
              style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.w600,
                  fontSize: widget.compact ? 9 : 10,
                  letterSpacing: widget.compact ? .7 : 1,
                  color: widget.active || hovered || focused
                      ? Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFFBCDA27)
                          : const Color(0xFF526B0E)
                      : widget.foreground.withOpacity(.7)),
              child: Text(widget.label.toUpperCase(),
                  semanticsLabel: widget.label))));
}
