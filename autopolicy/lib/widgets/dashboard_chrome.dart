import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Static environmental illumination. Painted beneath the opaque hardware
/// surfaces; it never traces a border around the dashboard shell.
class DashboardAmbientBackground extends StatelessWidget {
  const DashboardAmbientBackground({super.key});
  @override
  Widget build(BuildContext context) => const IgnorePointer(
      child: RepaintBoundary(
          child: CustomPaint(
              painter: _DashboardEnvironment(), size: Size.infinite)));
}

class _DashboardEnvironment extends CustomPainter {
  const _DashboardEnvironment();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = DashboardDarkPalette.carbon);
    final compact = size.width < 700;
    void field(Offset center, double rx, double ry, List<Color> colors,
        List<double> stops) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.scale(rx, ry);
      canvas.drawCircle(
          Offset.zero,
          1,
          Paint()
            ..shader = RadialGradient(colors: colors, stops: stops)
                .createShader(const Rect.fromLTWH(-1, -1, 2, 2)));
      canvas.restore();
    }

    field(Offset(0, size.height * .02), size.width * (compact ? 1.0 : .88),
        size.height * .9, [
      DashboardDarkPalette.chartreuse.withOpacity(compact ? 0.22 : 0.34),
      DashboardDarkPalette.olive.withOpacity(.19),
      Colors.transparent
    ], [
      0,
      .30,
      1
    ]);
    field(Offset(0, size.height), size.width * .46, size.height * .62, [
      DashboardDarkPalette.lime.withOpacity(compact ? 0.05 : 0.10),
      Colors.transparent
    ], [
      0,
      1
    ]);
  }

  @override
  bool shouldRepaint(_DashboardEnvironment old) => false;
}

/// One hover/focus/active treatment for dark navigation in the tree and rail.
class DarkNavigationItem extends StatefulWidget {
  final bool selected;
  final String label;
  final VoidCallback? onTap;
  final Widget Function(Color foreground) builder;
  final EdgeInsetsGeometry padding;
  const DarkNavigationItem(
      {super.key,
      required this.label,
      required this.builder,
      this.selected = false,
      this.onTap,
      this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 10)});
  @override
  State<DarkNavigationItem> createState() => _DarkNavigationItemState();
}

class _DarkNavigationItemState extends State<DarkNavigationItem> {
  bool hover = false, focus = false;
  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final foreground = !enabled
        ? DashboardDarkPalette.icon.withOpacity(.45)
        : widget.selected
            ? DashboardDarkPalette.chartreuse
            : hover || focus
                ? DashboardDarkPalette.primary
                : DashboardDarkPalette.secondary;
    return Semantics(
      button: true,
      selected: widget.selected,
      enabled: enabled,
      label: widget.label,
      excludeSemantics: true,
      onTap: widget.onTap,
      child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onHover: (value) => setState(() => hover = value),
            onFocusChange: (value) => setState(() => focus = value),
            borderRadius: BorderRadius.circular(8),
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            child: AnimatedContainer(
              duration: Duration(
                  milliseconds:
                      MediaQuery.of(context).disableAnimations ? 0 : 180),
              decoration: BoxDecoration(
                  color: widget.selected
                      ? DashboardDarkPalette.selected
                      : hover || focus
                          ? DashboardDarkPalette.elevated
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: focus
                          ? DashboardDarkPalette.chartreuse
                          : Colors.transparent,
                      width: 1)),
              child: Stack(children: [
                Padding(
                    padding: widget.padding, child: widget.builder(foreground)),
                if (widget.selected)
                  Positioned(
                      right: 0,
                      top: 9,
                      bottom: 9,
                      child: Container(
                          width: 2,
                          decoration: BoxDecoration(
                              color: DashboardDarkPalette.chartreuse,
                              borderRadius: BorderRadius.circular(2)))),
              ]),
            ),
          )),
    );
  }
}
