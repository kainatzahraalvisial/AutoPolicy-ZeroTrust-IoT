import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class AutopolicyLogo extends StatelessWidget {
  final double height;
  final Color? color;
  final bool animate;

  const AutopolicyLogo({
    super.key,
    this.height = 42.0,
    this.color,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final double brandMarkSize = height * 1.35;
    final double textFontSize = height * 0.45;
    final shieldColor = color ?? CyberColors.neonCyan;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Shield Brand Mark - identical to the navigation bar style
        Icon(
          Icons.shield_outlined,
          color: shieldColor,
          size: brandMarkSize,
        ),
        SizedBox(height: height * 0.28),
        // Brand Name Text matching display title style
        Text(
          'AUTOPOLICY',
          style: CyberTextStyles.displayTitle(
            fontSize: textFontSize,
            color: Colors.white,
          ).copyWith(
            letterSpacing: 4.0,
            shadows: [
              Shadow(
                color: Colors.white.withOpacity(0.15),
                blurRadius: 8.0,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
