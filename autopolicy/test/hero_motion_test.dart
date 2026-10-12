import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autopolicy/landing/visual_polish.dart';

void main() {
  const paragraph = 'Every connected device deserves intelligent protection.';
  Widget host({bool reduced = false}) => MaterialApp(
      home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: const Scaffold(
              body: SizedBox(
                  width: 220,
                  child: TypingParagraph(
                      text: paragraph,
                      delay: 200,
                      style: TextStyle(fontSize: 16, height: 1.65))))));

  String visibleText(WidgetTester tester) {
    final text = tester.widget<Text>(find.byType(Text).first);
    return ((text.textSpan! as TextSpan).children!.first as TextSpan).text!;
  }

  testWidgets(
      'Typing preserves final layout and finishes without replay on rebuild',
      (tester) async {
    await tester.pumpWidget(host());
    final initialSize = tester.getSize(find.byType(Text));
    expect(visibleText(tester), isEmpty);
    await tester.pump(const Duration(milliseconds: 500));
    expect(visibleText(tester).length, greaterThan(0));
    expect(visibleText(tester).length, lessThan(paragraph.length));
    expect(tester.getSize(find.byType(Text)), initialSize);
    await tester.pump(const Duration(seconds: 2));
    expect(visibleText(tester), paragraph);
    await tester.pumpWidget(host());
    expect(visibleText(tester), paragraph);
  });

  testWidgets('Reduced motion immediately shows complete paragraph',
      (tester) async {
    await tester.pumpWidget(host(reduced: true));
    expect(visibleText(tester), paragraph);
  });

  testWidgets('Reduced motion shows entrance content without delay',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: HeroEntrance(delay: 3000, child: Text('Explore system')))));
    final opacity = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacity.opacity, 1);
    expect(
        tester.widget<IgnorePointer>(find.byType(IgnorePointer).last).ignoring,
        isFalse);
  });
}
