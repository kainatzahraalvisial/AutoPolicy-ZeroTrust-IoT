import 'dart:ui';
import 'package:flutter/material.dart';

class IsomorphicGlassPanel extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const IsomorphicGlassPanel({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 32.0,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          // Premium soft glass drop shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 30,
            spreadRadius: -5,
            offset: const Offset(0, 12),
          ),
          // Subtle, ambient back-glow in a very soft neon cyan to blend card into background
          BoxShadow(
            color: const Color(0xFF00F5FF).withOpacity(0.08),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          // Ultra-high premium blur for authentic frosted glass refraction
          filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
          child: Container(
            padding: padding ?? const EdgeInsets.all(28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              // Frosted dark semi-translucent glassmorphism gradient
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black.withOpacity(0.45),
                  Colors.black.withOpacity(0.20),
                  Colors.black.withOpacity(0.35),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              // Elegant neon cyan border mirroring the cyber outline glow
              border: Border.all(
                color: const Color(0xFF00F5FF).withOpacity(0.65),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
