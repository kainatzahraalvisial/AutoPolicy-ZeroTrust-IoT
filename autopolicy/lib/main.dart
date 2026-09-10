import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_layout.dart';

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
      title: 'AutoPolicy — Zero Trust IoT Security',
      debugShowCheckedModeBanner: false,
      theme: CyberTheme.darkTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/landing':
            page = const LandingScreen();
            break;
          case '/login':
            page = const LoginPage();
            break;
          case '/signup':
            page = const SignupPage();
            break;
          case '/dashboard':
            page = const MainLayout();
            break;
          case '/':
          default:
            page = const SplashScreen();
            break;
        }
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        );
      },
    );
  }
}
