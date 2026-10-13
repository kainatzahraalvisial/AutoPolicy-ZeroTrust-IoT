import 'package:flutter/material.dart';

class SidebarBrand extends StatelessWidget {
  final bool dark;
  final bool lightSurface;
  const SidebarBrand(
      {super.key, required this.dark, this.lightSurface = false});
  @override
  Widget build(BuildContext context) => FittedBox(
      fit: BoxFit.contain,
      alignment: Alignment.centerLeft,
      child: Row(children: [
        SidebarShield(dark: dark, size: 46),
        const SizedBox(width: 9),
        Text('AutoPolicy',
            style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: dark && !lightSurface
                    ? const Color(0xFFEDF3E8)
                    : const Color(0xFF263129))),
      ]));
}

class SidebarShield extends StatelessWidget {
  final bool dark;
  final double size;
  const SidebarShield({super.key, required this.dark, required this.size});
  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
        dark
            ? 'assets/images/logo_icon_dark.png'
            : 'assets/images/logo_icon_light.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        isAntiAlias: true);
    if (dark) return image;
    // Green chroma becomes purple; neutral silver becomes charcoal grey.
    // Every RGB row has the same sum, so white/grey stays neutral. Alpha is intact.
    return ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          .06378,
          .66456,
          -.42834,
          0,
          0,
          .06378,
          .43456,
          -.19834,
          0,
          0,
          .06378,
          1.11456,
          -.87834,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: image);
  }
}

/// Panel toggle silhouette from the supplied reference: split rounded rectangle.
class SidebarToggleIcon extends StatelessWidget {
  final Color color;
  final double size;
  const SidebarToggleIcon({super.key, required this.color, this.size = 17});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _PanelPainter(color));
}

class _PanelPainter extends CustomPainter {
  final Color color;
  const _PanelPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(size.width * .12, size.height * .18,
        size.width * .76, size.height * .64);
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawRRect(
        RRect.fromRectAndRadius(r, Radius.circular(size.width * .13)), p);
    final x = r.left + r.width * .36;
    canvas.drawLine(Offset(x, r.top), Offset(x, r.bottom), p);
  }

  @override
  bool shouldRepaint(_PanelPainter oldDelegate) => oldDelegate.color != color;
}
