import 'package:flutter/material.dart';

/// Constantes de l'application BudgetBuddy
class AppConstants {
  // Informations de l'application
  static const String appName = 'BudgetBuddy';
  static const String appVersion = '1.0.0';

  // Clés de base de données
  static const String databaseName = 'budget_buddy.db';
  static const int databaseVersion = 1;

  // Noms des tables
  static const String tableTransactions = 'transactions';
  static const String tableCategories = 'categories';
  static const String tableBudgets = 'budgets';
  static const String tableSavingsGoals = 'savings_goals';
  static const String tableAccounts = 'accounts';
  static const String tableTransactionAccounts = 'transaction_accounts';
  static const String tableReports = 'reports';
  static const String tableUserSettings = 'user_settings';
  static const String tableAuditLog = 'audit_log';

  // Limites de performance
  static const int maxTransactions = 10000;
  static const int maxDatabaseSizeMB = 50;
  static const int queryTimeoutMs = 100;

  // Types de transactions
  static const String transactionTypeIncome = 'income';
  static const String transactionTypeExpense = 'expense';

  // Types de périodes
  static const String periodDaily = 'daily';
  static const String periodWeekly = 'weekly';
  static const String periodMonthly = 'monthly';
  static const String periodYearly = 'yearly';

  // Types de comptes
  static const String accountTypeCash = 'cash';
  static const String accountTypeBank = 'bank';
  static const String accountTypeCreditCard = 'credit_card';
  static const String accountTypeSavings = 'savings';
  static const String accountTypeInvestment = 'investment';

  // Couleurs par défaut des catégories
  static const Map<String, Color> categoryColors = {
    'Alimentation': Color(0xFFFF6B6B),
    'Transport': Color(0xFF4ECDC4),
    'Logement': Color(0xFF45B7D1),
    'Services': Color(0xFF96CEB4),
    'Shopping': Color(0xFFFFEAA7),
    'Loisirs': Color(0xFFDDA0DD),
    'Santé': Color(0xFFF7DC6F),
    'Éducation': Color(0xFFBB8FCE),
    'Autres dépenses': Color(0xFFAAB7B8),
    'Salaire': Color(0xFF2ECC71),
    'Freelance': Color(0xFF3498DB),
    'Investissements': Color(0xFF9B59B6),
    'Cadeaux': Color(0xFFE74C3C),
    'Remboursements': Color(0xFFF39C12),
    'Autres revenus': Color(0xFF95A5A6),
  };

  // Icônes des catégories
  static const Map<String, String> categoryIcons = {
    'Alimentation': '🍔',
    'Transport': '🚗',
    'Logement': '🏠',
    'Services': '💡',
    'Shopping': '🛍️',
    'Loisirs': '🎬',
    'Santé': '🏥',
    'Éducation': '📚',
    'Autres dépenses': '📦',
    'Salaire': '💰',
    'Freelance': '💼',
    'Investissements': '📈',
    'Cadeaux': '🎁',
    'Remboursements': '↪️',
    'Autres revenus': '📥',
  };

  // Paramètres par défaut
  static const String defaultCurrency = 'EUR';
  static const String defaultLanguage = 'fr';
  static const int defaultFirstDayOfWeek = 1; // Lundi
  static const String defaultTheme = 'light';
  static const int defaultBackupInterval = 7; // jours

  // Formats de date
  static const String dateFormatFull = 'dd/MM/yyyy HH:mm';
  static const String dateFormatShort = 'dd/MM/yyyy';
  static const String dateFormatMonth = 'MMMM yyyy';

  // Messages
  static const String msgTransactionAdded = 'Transaction ajoutée avec succès';
  static const String msgTransactionUpdated = 'Transaction mise à jour';
  static const String msgTransactionDeleted = 'Transaction supprimée';
  static const String msgBudgetExceeded = 'Budget dépassé !';
  static const String msgBudgetWarning = 'Attention : budget bientôt dépassé';
}

/// Thème de l'application
class AppTheme {
  // Couleurs principales
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF4ECDC4);
  static const Color accentColor = Color(0xFFFF6B6B);
  static const Color backgroundColor = Color(0xFFF7F8FA);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color successColor = Color(0xFF2ECC71);
  static const Color warningColor = Color(0xFFF39C12);

  // Couleurs de texte
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textLight = Color(0xFFBDC3C7);

  // Thème clair
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    ),
  );

  // Thème sombre
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF1A1A1A),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2C2C2C),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF2C2C2C),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
