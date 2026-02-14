import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../providers/dashboard_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import 'routes.dart';

/// Configuration principale de l'application BudgetBuddy
class BudgetBuddyApp extends StatelessWidget {
  const BudgetBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrapper avec tous les providers nécessaires
    return MultiProvider(
      providers: [
        // Provider pour les catégories - DOIT être en premier car les autres en dépendent
        ChangeNotifierProvider(
          create: (_) => CategoryProvider()..loadCategories(),
        ),

        // Provider pour le dashboard
        ChangeNotifierProvider(create: (_) => DashboardProvider()),

        // Provider pour les transactions
        ChangeNotifierProvider(create: (_) => TransactionProvider()),

        // Provider pour les budgets
        ChangeNotifierProvider(create: (_) => BudgetProvider()),

        // Provider pour les paramètres
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'BudgetBuddy',
            debugShowCheckedModeBanner: false,

            // Thèmes
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.darkMode
                ? ThemeMode.dark
                : ThemeMode.light,

            // Routes
            initialRoute: AppRoutes.splash,
            routes: AppRoutes.routes,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            onUnknownRoute: AppRoutes.onUnknownRoute,
          );
        },
      ),
    );
  }
}
