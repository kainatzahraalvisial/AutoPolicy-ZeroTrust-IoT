import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autopolicy/widgets/system_loader.dart';

void main() {
  testWidgets('Loader animates in code without media widgets', (tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SystemLoader(label: 'Loading...'))));
    expect(find.byType(Image), findsNothing);
    expect(find.text('LOADING...'), findsOneWidget);
    final paint = find.descendant(of: find.byType(SystemLoader), matching: find.byType(CustomPaint));
    final first = tester.widget<CustomPaint>(paint).painter;
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.widget<CustomPaint>(paint).painter, isNot(same(first)));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}

