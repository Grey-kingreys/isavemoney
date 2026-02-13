import 'package:flutter/material.dart';
import '../views/splash_screen.dart';
import '../views/onboarding_screen.dart';
import '../views/dashboard_screen.dart';
import '../utils/app_theme.dart';

/// Configuration principale de l'application BudgetBuddy
class BudgetBuddyApp extends StatelessWidget {
  const BudgetBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BudgetBuddy',
      debugShowCheckedModeBanner: false,

      // Thèmes
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Routes
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },

      // Route par défaut pour les routes inconnues
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      },
    );
  }
}
