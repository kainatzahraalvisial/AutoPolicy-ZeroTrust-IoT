import 'package:flutter/material.dart';

class CyberGrid extends StatelessWidget {
  final Widget? child;
  const CyberGrid({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return child ?? const SizedBox.shrink();
  }
}
