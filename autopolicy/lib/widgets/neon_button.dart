import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class NeonButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final IconData? icon;
  final bool isGlowing;

  const NeonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = CyberColors.neonGreen,
    this.icon,
    this.isGlowing = false,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isGlowing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant NeonButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isGlowing && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isGlowing && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _isHovered ? widget.color : widget.color.withOpacity(0.8);

    return MouseRegion(
      onEnter: (_) => Future.microtask(() {
        if (mounted) setState(() => _isHovered = true);
      }),
      onExit: (_) => Future.microtask(() {
        if (mounted) setState(() => _isHovered = false);
      }),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double glowFactor = widget.isGlowing ? _controller.value : 0.0;
            if (_isHovered) glowFactor = 1.0;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: activeColor.withOpacity(0.05 + (glowFactor * 0.05)),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: activeColor.withOpacity(0.3 + (glowFactor * 0.7)),
                  width: 1.5,
                ),
                boxShadow: glowFactor > 0.1
                    ? [
                        BoxShadow(
                          color: activeColor.withOpacity(0.1 + (glowFactor * 0.3)),
                          blurRadius: 8.0 + (glowFactor * 4.0),
                          spreadRadius: 0.5,
                        )
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 16, color: activeColor),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text.toUpperCase(),
                    style: CyberTextStyles.displayTitle(
                      fontSize: 12.0,
                      color: activeColor,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
