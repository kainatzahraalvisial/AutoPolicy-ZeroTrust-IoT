import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autopolicy/screens/main_layout.dart';
import 'package:autopolicy/widgets/cyber_stat_card.dart';
import 'package:autopolicy/landing/visual_polish.dart';

void main() {
  for (final size in [
    const Size(768, 1024),
    const Size(1366, 768),
    const Size(1920, 1080),
    const Size(390, 844)
  ]) {
    testWidgets('Dashboard cards fit at ${size.width} x ${size.height}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: MainLayout())));
      await tester.pump();
      expect(tester.takeException(), isNull);
      final cards = find.byType(CyberStatCard);
      expect(cards, findsNWidgets(6));
      final rects = List.generate(6, (i) => tester.getRect(cards.at(i)));
      if (size.width >= 768) {
        for (final rect in rects) {
          expect(rect.top, closeTo(rects.first.top, .1));
          expect(rect.right, lessThanOrEqualTo(size.width));
        }
      } else {
        expect(rects[2].top, greaterThan(rects[0].bottom));
      }
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets('Sidebar hover and collapse stay within their layout bounds',
      (tester) async {
    tester.view.physicalSize = const Size(1366, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: MainLayout())));
    final sidebar = find.byType(AnimatedSize);
    expect(tester.getSize(sidebar).width, 200);
    expect(tester.getTopLeft(sidebar).dy, 0);
    expect(find.descendant(of: sidebar, matching: find.byType(AutoPolicyWordmark)), findsOneWidget);
    final highlight = find.descendant(of: find.byTooltip('Dashboard Overview'), matching: find.byType(AnimatedContainer));
    expect((tester.widget<AnimatedContainer>(highlight).decoration as BoxDecoration).color, isNotNull);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse
        .moveTo(tester.getCenter(find.byTooltip('Live Traffic & Alerts')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);
    await tester.tap(find.byIcon(Icons.menu).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 130));
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(milliseconds: 160));
    expect(tester.getSize(sidebar).width, 64);
    await tester.tap(find.byIcon(Icons.menu).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.getSize(sidebar).width, 200);
    expect(tester.takeException(), isNull);
    await mouse.removePointer();
    await tester.pumpWidget(const SizedBox());
  });
}
