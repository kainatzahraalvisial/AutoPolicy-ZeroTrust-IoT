import 'package:flutter/material.dart';

/// Keeps controls on one row when they fit; wraps them within narrow panels.
class ConsoleRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final bool compact;
  final double minimumWidth;
  final double spacing;
  const ConsoleRow(
      {super.key,
      required this.children,
      this.mainAxisAlignment = MainAxisAlignment.start,
      this.crossAxisAlignment = CrossAxisAlignment.center,
      this.mainAxisSize = MainAxisSize.max,
      this.compact = false,
      this.minimumWidth = double.infinity,
      this.spacing = 0});
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, bounds) {
        if (!bounds.hasBoundedWidth || bounds.maxWidth >= minimumWidth) {
          return Row(
              mainAxisAlignment: mainAxisAlignment,
              crossAxisAlignment: crossAxisAlignment,
              mainAxisSize: mainAxisSize,
              children: children);
        }
        final items = children.where((child) => child is! Spacer).map((child) {
          if (child is Flexible) {
            return child.child;
          }
          return child;
        }).toList();
        if (compact) {
          return FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0 && spacing > 0) SizedBox(width: spacing),
                  items[i]
                ]
              ]));
        }
        return Wrap(
            spacing: 4,
            runSpacing: 8,
            alignment: mainAxisAlignment == MainAxisAlignment.spaceBetween
                ? WrapAlignment.spaceBetween
                : WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: items
                .map((child) => ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: bounds.maxWidth),
                    child: child))
                .toList());
      });
}
