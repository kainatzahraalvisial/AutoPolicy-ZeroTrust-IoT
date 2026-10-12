import 'package:flutter/material.dart';

enum LandingViewport {
  desktopWide,
  desktop,
  laptopCompact,
  tabletLandscape,
  tabletPortrait,
  mobileLarge,
  mobileSmall
}

/// Both axes determine layout; camera classes retain the existing bridge contract.
class LandingComposition {
  final LandingViewport kind;
  final double width, height;
  LandingComposition(this.width, this.height)
      : kind = width < 380
            ? LandingViewport.mobileSmall
            : width < 600
                ? LandingViewport.mobileLarge
                : width / height < 1.1
                    ? LandingViewport.tabletPortrait
                    : width < 1150
                        ? LandingViewport.tabletLandscape
                        : width < 1450
                            ? LandingViewport.laptopCompact
                            : width < 1800
                                ? LandingViewport.desktop
                                : LandingViewport.desktopWide;
  bool get stacked => phone || kind == LandingViewport.tabletPortrait;
  bool get phone => width < 600;
  bool get menu => width < 600;
  bool get compact => height < 740 || width < 1000;
  double get header => width < 900 ? 58 : 68;
  double get brandWidth => phone
      ? 30
      : width < 1150
          ? 46
          : 58;

  double get contentLeft {
    if (phone) return 24;
    if (width > 1800) return brandWidth + 72;
    if (width > 1400) return brandWidth + 52;
    return brandWidth + 32;
  }

  double get copyWidth {
    if (stacked) {
      return (width - contentLeft - 24).clamp(0.0, 760.0);
    }
    final double target = (width - contentLeft - 32) * (width > 1600 ? 0.44 : 0.40);
    final double maxW = width > 1800 ? 820.0 : width > 1450 ? 720.0 : 620.0;
    return target.clamp(280.0, maxW);
  }

  double get sceneTop => header + 12;

  Rect get sceneRect => stacked
      ? Rect.fromLTWH(brandWidth + 20, sceneTop, width - brandWidth - 32,
          ((height - sceneTop - 24) * (phone ? .46 : .57)).clamp(60.0, 720.0))
      : Rect.fromLTWH(contentLeft + copyWidth + 24, sceneTop,
          width - contentLeft - copyWidth - 36, height - sceneTop - 24);

  double get copyTop {
    if (stacked) return sceneRect.bottom + 16;
    final availableHeight = height - header - 40;
    final estimatedTextHeight = width > 1600 ? 440.0 : 380.0;
    if (availableHeight > estimatedTextHeight) {
      final verticalSlack = availableHeight - estimatedTextHeight;
      return header + (verticalSlack * 0.32).clamp(24.0, 140.0);
    }
    return header + 24;
  }

  Rect get copyRect => Rect.fromLTWH(
      contentLeft,
      copyTop,
      copyWidth,
      height - copyTop - 24);

  double get gap {
    if (compact) return 18;
    if (width > 1600 && height > 850) return 30;
    return 24;
  }

  double get headingSize {
    if (phone) return width < 380 ? 29 : 32;
    if (stacked) return 44;
    if (width > 1800) return 64.0;
    if (width > 1450) return 56.0;
    if (width > 1150) return 48.0;
    return (copyWidth * .105).clamp(32.0, height < 740 ? 43.0 : 48.0);
  }
}
