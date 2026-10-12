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
  bool get compact => height < 800 || width < 1150;
  double get header => width < 900 ? 58 : 64;
  double get brandWidth => phone
      ? 30
      : width < 1150
          ? 46
          : 58;
  double get contentLeft => phone ? 24 : brandWidth + 32;
  double get copyWidth => stacked
      ? (width - contentLeft - 24).clamp(0.0, 720.0)
      : ((width - contentLeft - 24) * .39).clamp(260.0, 600.0);
  double get sceneTop => header + 12;
  Rect get sceneRect => stacked
      ? Rect.fromLTWH(brandWidth + 20, sceneTop, width - brandWidth - 32,
          ((height - sceneTop - 24) * (phone ? .46 : .57)).clamp(60.0, 720.0))
      : Rect.fromLTWH(contentLeft + copyWidth + 22, sceneTop,
          width - contentLeft - copyWidth - 34, height - sceneTop - 24);
  Rect get copyRect => Rect.fromLTWH(
      contentLeft,
      stacked ? sceneRect.bottom + 16 : header + 24,
      copyWidth,
      height - (stacked ? sceneRect.bottom + 16 : header + 24) - 24);
  double get gap => compact ? 18 : 28;
  double get headingSize => phone
      ? (width < 380 ? 29 : 32)
      : stacked
          ? 44
          : (copyWidth * .105).clamp(30.0, height < 740 ? 43.0 : 60.0);
}
