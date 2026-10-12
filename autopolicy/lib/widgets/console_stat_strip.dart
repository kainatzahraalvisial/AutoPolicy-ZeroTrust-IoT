import 'package:flutter/material.dart';

/// Preserves each card and its action while giving phone cards usable widths.
class ConsoleStatStrip extends StatelessWidget {
  final List<Widget> children;
  const ConsoleStatStrip({super.key, required this.children});
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, bounds) {
        final cards =
            children.whereType<Expanded>().map((item) => item.child).toList();
        return GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: bounds.maxWidth < 560 ? 2 : cards.length,
                mainAxisExtent: 120,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8),
            children: cards);
      });
}
