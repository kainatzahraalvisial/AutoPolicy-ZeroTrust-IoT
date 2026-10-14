import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autopolicy/widgets/dashboard_chrome.dart';
import 'package:autopolicy/theme/colors.dart';

void main() {
  testWidgets('dark navigation remains keyboard operable with visible focus',
      (tester) async {
    var activations = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Center(
                child: SizedBox(
                    width: 220,
                    child: DarkNavigationItem(
                        label: 'Traffic',
                        onTap: () => activations++,
                        builder: (fg) =>
                            Text('Traffic', style: TextStyle(color: fg))))))));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    final frame =
        tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
    final border = (frame.decoration as BoxDecoration).border! as Border;
    expect(border.top.color, DashboardDarkPalette.chartreuse);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(activations, 1);
  });
  testWidgets('hover brightens navigation and restores its muted default',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Center(
                child: SizedBox(
                    width: 220,
                    child: DarkNavigationItem(
                        label: 'Traffic',
                        onTap: () {},
                        builder: (fg) =>
                            Text('Traffic', style: TextStyle(color: fg))))))));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(DarkNavigationItem)));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.text('Traffic')).style!.color,
        DashboardDarkPalette.primary);
    await mouse.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.text('Traffic')).style!.color,
        DashboardDarkPalette.secondary);
    await mouse.removePointer();
  });
}
