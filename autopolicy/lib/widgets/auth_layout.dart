import 'package:flutter/material.dart';
import '../landing/visual_polish.dart';

class AuthFieldPair extends StatelessWidget {
  final List<Widget> children;
  const AuthFieldPair({super.key, required this.children});
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, bounds) {
        if (bounds.maxWidth >= 360) return Row(children: children);
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children
                .map((child) =>
                    child is Expanded ? child.child : const SizedBox(height: 8))
                .toList());
      });
}

class AuthHeader extends StatelessWidget {
  final bool dark;
  final VoidCallback? onTheme;
  const AuthHeader({super.key, required this.dark, this.onTheme});
  @override
  Widget build(BuildContext context) => SafeArea(
      bottom: false,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(children: [
            SizedBox(
                width: 170, height: 44, child: AutoPolicyWordmark(dark: dark)),
            const Spacer(),
            TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/landing'),
                child: const Text('‹ EXPLORE',
                    style: TextStyle(fontFamily: 'Orbitron', fontSize: 9))),
          ])));
}

/// The ordinary form fits its viewport. Scrolling remains a safety fallback
/// when a keyboard, validation messages, or enlarged text need extra space.
class AuthViewport extends StatelessWidget {
  final Widget child;
  const AuthViewport({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Positioned.fill(
      top: 58,
      child: SafeArea(
          top: false,
          child: LayoutBuilder(
              builder: (context, bounds) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                  child: ConstrainedBox(
                      constraints: BoxConstraints(
                          minHeight: (bounds.maxHeight - 28)
                              .clamp(0, double.infinity)),
                      child: Center(child: child))))));
}
