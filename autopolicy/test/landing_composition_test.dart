import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autopolicy/landing/landing_composition.dart';

void main() {
  const sizes = [
    Size(1920, 1080),
    Size(1600, 900),
    Size(1440, 900),
    Size(1366, 768),
    Size(1280, 720),
    Size(1024, 768),
    Size(1024, 1366),
    Size(834, 1194),
    Size(768, 1024),
    Size(430, 932),
    Size(390, 844),
    Size(360, 800)
  ];
  for (final size in sizes) {
    test(
        'Model and text have separate usable bounds at ${size.width} x ${size.height}',
        () {
      final c = LandingComposition(size.width, size.height),
          scene = c.sceneRect;
      expect(scene.width, greaterThan(250));
      expect(scene.height, greaterThan(250));
      expect(scene.left, greaterThanOrEqualTo(12 + c.brandWidth));
      expect(scene.top, greaterThanOrEqualTo(c.header));
      expect(scene.right, lessThanOrEqualTo(size.width));
      expect(scene.bottom, lessThan(size.height - 64));
      if (!c.stacked) expect(c.contentLeft + c.copyWidth, lessThan(scene.left));
      // Regression: a tall tablet brand rail must not cross the stacked text.
      if (c.stacked && !c.phone)
        expect(c.contentLeft, greaterThan(12 + c.brandWidth));
      expect(c.contentLeft + c.copyWidth, lessThanOrEqualTo(size.width));
    });
  }
}
