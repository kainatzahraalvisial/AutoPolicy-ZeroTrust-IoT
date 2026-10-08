import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autopolicy/landing/cinematic_button.dart';

void main() {
  testWidgets(
      'CTA hover lifts and glows, resets on exit, and activates its action',
      (tester) async {
    var actions = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Center(
                child: CinematicButton(
                    label: 'Explore',
                    filled: true,
                    onPressed: () => actions++)))));
    final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await pointer.addPointer(location: Offset.zero);
    await pointer.moveTo(tester.getCenter(find.byType(TextButton)));
    await tester.pumpAndSettle();
    var decorated =
        tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
    expect(decorated.transform!.storage[13], -2);
    expect((decorated.decoration as BoxDecoration).boxShadow, isNotEmpty);
    await tester.tap(find.byType(TextButton));
    expect(actions, 1);
    await pointer.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    decorated =
        tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
    expect(decorated.transform!.storage[13], 0);
    expect((decorated.decoration as BoxDecoration).boxShadow, isEmpty);
    await pointer.removePointer();
  });
  testWidgets('navigation hover uses the lime accent and restores muted text',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Center(
                child: CinematicNavLink(
                    label: 'Explore',
                    active: false,
                    foreground: Colors.white,
                    onPressed: () {})))));
    final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await pointer.addPointer(location: Offset.zero);
    await pointer.moveTo(tester.getCenter(find.byType(TextButton)));
    await tester.pumpAndSettle();
    final label = find.byWidgetPredicate((w) =>
        w is AnimatedDefaultTextStyle &&
        w.child is Text &&
        (w.child as Text).data == 'EXPLORE');
    expect(tester.widget<AnimatedDefaultTextStyle>(label).style.color,
        const Color(0xFFBCDA27));
    await pointer.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    expect(tester.widget<AnimatedDefaultTextStyle>(label).style.color,
        Colors.white.withOpacity(.7));
    await pointer.removePointer();
  });
}
