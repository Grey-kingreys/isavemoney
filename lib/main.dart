import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:isavemoney/providers/transaction_provider.dart';
import 'package:isavemoney/providers/category_provider.dart';
import 'package:isavemoney/providers/budget_provider.dart';
import 'package:isavemoney/providers/dashboard_provider.dart';
import 'package:isavemoney/providers/settings_provider.dart';
import 'package:isavemoney/services/database_service.dart';
import 'package:isavemoney/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser la base de données
  final dbService = DatabaseService();
  await dbService.database;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const BudgetBuddyApp(),
    ),
  );
}
