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

  testWidgets('MainLayout Theme Toggle & Circular Reveal Test', (WidgetTester tester) async {
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

    // In default dark mode, the toggle icon should be wb_sunny_outlined (to switch to light mode)
    final toggleButtonFinder = find.byIcon(Icons.wb_sunny_outlined);
    expect(toggleButtonFinder, findsOneWidget);

    // Tap the theme toggle button to trigger the circular reveal transition
    await tester.tap(toggleButtonFinder);
    await tester.pump(); // Start transition

    // Wait for the circular reveal transition animation to complete (duration is 650ms)
    // We use pump instead of pumpAndSettle since the infinite repeating glass card and globe animations keep the tree active
    await tester.pump(const Duration(milliseconds: 700));

    // Verify that the theme toggled to light mode, and the button now shows nightlight_round
    expect(find.byIcon(Icons.nightlight_round), findsOneWidget);
  });
}
