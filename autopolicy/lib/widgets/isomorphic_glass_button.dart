import 'package:flutter/material.dart';
import '../theme/text_styles.dart';

class IsomorphicGlassButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double height;
  final double? width;

  const IsomorphicGlassButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.height = 46.0,
    this.width,
  });

  @override
  State<IsomorphicGlassButton> createState() => _IsomorphicGlassButtonState();
}

class _IsomorphicGlassButtonState extends State<IsomorphicGlassButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Dynamic interactive colors to create high responsiveness
    final double opacityMultiplier = _isPressed ? 0.7 : (_isHovered ? 1.1 : 1.0);
    
    return MouseRegion(
      onEnter: (_) => Future.microtask(() {
        if (mounted) setState(() => _isHovered = true);
      }),
      onExit: (_) => Future.microtask(() {
        if (mounted) setState(() => _isHovered = false);
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.height / 2),
            // Sleek cyan glassmorphic gradient fill
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF00F5FF).withOpacity(0.80 * opacityMultiplier),
                const Color(0xFF00BFFF).withOpacity(0.60 * opacityMultiplier),
              ],
            ),
            // White-cyan translucent border
            border: Border.all(
              color: Colors.white.withOpacity(0.24 * (_isHovered ? 1.3 : 1.0)),
              width: 1.0,
            ),
            // Deep glowing cyan outer shadow
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00F5FF).withOpacity(_isHovered ? 0.45 : 0.30),
                blurRadius: _isHovered ? 20 : 14,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    widget.text,
                    style: CyberTextStyles.interface(
                      fontSize: 13.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ).copyWith(letterSpacing: 1.5),
                  ),
          ),
        ),
      ),
    );
  }
}
