import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: AutoPolicyApp(),
    ),
  );
}

class AutoPolicyApp extends StatelessWidget {
  const AutoPolicyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoPolicy Cyber SOC',
      debugShowCheckedModeBanner: false,
      theme: CyberTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
