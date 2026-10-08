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

/// UI and camera share these classes, while the renderer gets its own viewport.
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
  bool get stacked =>
      kind == LandingViewport.tabletPortrait ||
      kind == LandingViewport.mobileLarge ||
      kind == LandingViewport.mobileSmall;
  bool get phone => width < 600;
  bool get menu => width < 1150;
  bool get verticalStages => !stacked && width >= 1150;
  double get header => phone ? 66 : 78;
  double get brandWidth => phone
      ? 30
      : stacked
          ? 46
          : width < 1150
              ? 46
              : 58;
  double get railWidth => verticalStages ? (width >= 1800 ? 152 : 124) : 0;
  double get copyWidth => stacked
      ? phone
          ? width - 48
          : (width - brandWidth - 56).clamp(0.0, 720.0)
      : kind == LandingViewport.desktopWide
          ? 500
          : kind == LandingViewport.desktop
              ? 460
              : kind == LandingViewport.laptopCompact
                  ? 370
                  : 300;
  double get contentLeft =>
      stacked ? (phone ? 24 : brandWidth + 32) : brandWidth + railWidth + 42;
  double get sceneTop => header + (verticalStages ? 10 : 54);
  Rect get sceneRect => stacked
      ? Rect.fromLTWH(brandWidth + 20, sceneTop, width - brandWidth - 28,
          ((height - sceneTop - 64) * (phone ? .47 : .64)).clamp(260.0, 720.0))
      : Rect.fromLTWH(contentLeft + copyWidth + 18, sceneTop,
          width - contentLeft - copyWidth - 30, height - sceneTop - 84);
  double get headingSize => phone
      ? (width < 380 ? 29 : 34)
      : stacked
          ? 44
          : kind == LandingViewport.desktopWide
              ? 60
              : kind == LandingViewport.desktop
                  ? 52
                  : kind == LandingViewport.laptopCompact
                      ? 42
                      : 35;
}
