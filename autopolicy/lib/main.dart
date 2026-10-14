import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'landing/landing_route_observer.dart';
import 'screens/splash_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_layout.dart';
import 'providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final dark = prefs.getBool('autopolicy.darkTheme') ?? true;
  runApp(
    ProviderScope(
      overrides: [themeModeProvider.overrideWith((ref) => dark)],
      child: const AutoPolicyApp(),
    ),
  );
}

class AutoPolicyApp extends ConsumerWidget {
  const AutoPolicyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'AutoPolicy — Zero Trust IoT Security',
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? CyberTheme.darkTheme : CyberTheme.lightTheme,
      initialRoute: '/',
      navigatorObservers: [landingRouteObserver],
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/landing/arch':
            page = const LandingScreen(initialChapter: 'arch');
            break;
          case '/landing/sec':
            page = const LandingScreen(initialChapter: 'sec');
            break;
          case '/landing/explore':
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
