import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autopolicy/main.dart';
import 'package:autopolicy/screens/main_layout.dart';

void main() {
  testWidgets('AutoPolicy boot smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: AutoPolicyApp(),
      ),
    );

    // Verify that the app boots without crashes
    expect(find.byType(AutoPolicyApp), findsOneWidget);
  });

  testWidgets('MainLayout theme toggle updates the palette',
      (WidgetTester tester) async {
    // Set desktop screen size to prevent layout overflows in the test environment
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;

    // Reset view settings after test completes
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Build MainLayout directly to test interactive controls
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MainLayout(),
        ),
      ),
    );

    // Verify MainLayout loaded successfully
    expect(find.byType(MainLayout), findsOneWidget);

    // The pill displays the currently selected theme.
    final toggleButtonFinder = find.byIcon(Icons.dark_mode_outlined);
    expect(toggleButtonFinder, findsOneWidget);

    // Activate the current-theme pill.
    await tester.tap(toggleButtonFinder);
    await tester.pump(); // Start transition

    // Allow the palette update without waiting for continuous dashboard animations.
    await tester.pump(const Duration(milliseconds: 700));

    // The pill now displays the light theme.
    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
  });
}
