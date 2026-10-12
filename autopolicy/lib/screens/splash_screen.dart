import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/system_loader.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timer ??= Timer(
        Duration(
            milliseconds: MediaQuery.of(context).disableAnimations ? 0 : 1600),
        () {
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        Navigator.of(context).pushReplacementNamed('/landing');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF050A08)
          : const Color(0xFFFAF9F6),
      body: const SystemLoader());
}
