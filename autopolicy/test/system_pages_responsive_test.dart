import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autopolicy/screens/main_layout.dart';
import 'package:autopolicy/providers/navigation_provider.dart';

void main() {
  for (final width in [320.0, 390.0, 768.0, 1024.0, 1366.0, 1920.0]) {
    for (var page = 0; page < 12; page++) {
      testWidgets('Console page $page at $width px has no overflow',
          (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
        final errorHandler = FlutterError.onError;
        FlutterError.onError = (details) {
          debugPrint(details.toString());
          errorHandler?.call(details);
        };
        addTearDown(() => FlutterError.onError = errorHandler);
        await tester.pumpWidget(ProviderScope(
            overrides: [navigationTabProvider.overrideWith((ref) => page)],
            child: const MaterialApp(home: MainLayout())));
        await tester.pump();
        expect(tester.takeException(), isNull);
        final scrolls = find.byType(Scrollable);
        for (var i = 0; i < scrolls.evaluate().length; i++) {
          final state = tester.state<ScrollableState>(scrolls.at(i));
          if (state.position.axis == Axis.vertical &&
              state.position.hasContentDimensions) {
            state.position.jumpTo(state.position.maxScrollExtent);
          }
        }
        await tester.pump();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
