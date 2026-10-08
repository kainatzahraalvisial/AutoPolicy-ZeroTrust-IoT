import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autopolicy/screens/splash_screen.dart';

void main() {
  testWidgets('background splash cannot replace a directly opened application route', (tester) async {
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(navigatorKey: navigator, home: const SplashScreen(), routes: {
      '/landing': (_) => const Scaffold(body: Text('landing')),
      '/direct': (_) => const Scaffold(body: Text('direct chapter')),
    }));
    navigator.currentState!.pushNamed('/direct');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 4500));
    expect(find.text('direct chapter'), findsOneWidget);
    expect(find.text('landing'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
