import 'package:flutter/material.dart';
import '../views/splash_screen.dart';
import '../views/onboarding_screen.dart';
import '../views/dashboard/dashboard_page.dart';

/// Classe de gestion des routes de l'application
class AppRoutes {
  // Constantes de routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String home = '/home';

  // Transactions
  static const String transactions = '/transactions';
  static const String transactionAdd = '/transactions/add';
  static const String transactionEdit = '/transactions/edit';

  // Budgets
  static const String budgets = '/budgets';
  static const String budgetAdd = '/budgets/add';
  static const String budgetEdit = '/budgets/edit';

  // Statistiques
  static const String statistics = '/statistics';

  // Paramètres
  static const String settings = '/settings';
  static const String settingsCategories = '/settings/categories';
  static const String settingsAccounts = '/settings/accounts';
  static const String settingsBackup = '/settings/backup';

  /// Map des routes statiques
  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingScreen(),
    // Route vers le nouveau dashboard
    dashboard: (context) => const DashboardPage(),
    home: (context) =>
        const DashboardPage(), // home pointe aussi vers le dashboard
    // Les autres routes seront ajoutées au fur et à mesure
    // transactions: (context) => const TransactionList(),
    // transactionAdd: (context) => const TransactionFormPage(),
    // budgets: (context) => const BudgetList(),
    // budgetAdd: (context) => const BudgetFormPage(),
    // statistics: (context) => const StatisticsPage(),
    // settings: (context) => const SettingsPage(),
  };

  /// Génère une route dynamique avec arguments
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Routes avec paramètres
    switch (settings.name) {
      case transactionEdit:
        final args = settings.arguments as Map<String, dynamic>?;
        // return MaterialPageRoute(
        //   builder: (context) =>
        //       TransactionFormPage(transactionId: args?['id'] as int?),
        // );
        return null; // Temporaire jusqu'à la création de la page

      case budgetEdit:
        final args = settings.arguments as Map<String, dynamic>?;
        // return MaterialPageRoute(
        //   builder: (context) => BudgetFormPage(budgetId: args?['id'] as int?),
        // );
        return null; // Temporaire jusqu'à la création de la page

      default:
        return null;
    }
  }

  /// Route par défaut pour les routes inconnues
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) => const SplashScreen());
  }

  /// Navigation helper avec animation
  static Future<T?> navigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  /// Navigation avec remplacement
  static Future<T?> navigateAndReplace<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, Object>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Navigation avec suppression de toutes les routes précédentes
  static Future<T?> navigateAndRemoveUntil<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Retour en arrière
  static void goBack(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }

  /// Vérifie si on peut revenir en arrière
  static bool canGoBack(BuildContext context) {
    return Navigator.canPop(context);
  }
}
