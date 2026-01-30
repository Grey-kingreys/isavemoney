import 'package:flutter/material.dart';
import '../providers/settings_provider.dart';
import '../models/user_settings_model.dart';

/// Controller pour la gestion des paramètres
class SettingsController {
  final SettingsProvider settingsProvider;

  SettingsController({required this.settingsProvider});

  // Liste des devises supportées
  static const List<Map<String, String>> availableCurrencies = [
    {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
    {'code': 'USD', 'name': 'Dollar américain', 'symbol': '\$'},
    {'code': 'GBP', 'name': 'Livre sterling', 'symbol': '£'},
    {'code': 'GNF', 'name': 'Franc Guinéen', 'symbol': 'FG'},
    {'code': 'XOF', 'name': 'Franc CFA (BCEAO)', 'symbol': 'CFA'},
    {'code': 'XAF', 'name': 'Franc CFA (BEAC)', 'symbol': 'FCFA'},
    {'code': 'MAD', 'name': 'Dirham marocain', 'symbol': 'DH'},
    {'code': 'TND', 'name': 'Dinar tunisien', 'symbol': 'DT'},
  ];

  // Liste des langues supportées
  static const List<Map<String, String>> availableLanguages = [
    {'code': 'fr', 'name': 'Français'},
    {'code': 'en', 'name': 'English'},
    {'code': 'ar', 'name': 'العربية'},
  ];

  // Liste des thèmes
  static const List<Map<String, String>> availableThemes = [
    {'code': 'light', 'name': 'Clair'},
    {'code': 'dark', 'name': 'Sombre'},
    {'code': 'auto', 'name': 'Automatique'},
  ];

  // Liste des jours de la semaine
  static const List<Map<String, dynamic>> weekDays = [
    {'value': 1, 'name': 'Lundi'},
    {'value': 2, 'name': 'Mardi'},
    {'value': 3, 'name': 'Mercredi'},
    {'value': 4, 'name': 'Jeudi'},
    {'value': 5, 'name': 'Vendredi'},
    {'value': 6, 'name': 'Samedi'},
    {'value': 7, 'name': 'Dimanche'},
  ];

  /// Initialise les paramètres
  Future<void> initialize() async {
    await settingsProvider.loadSettings();
  }

  /// Obtient les paramètres actuels
  AppSettings getSettings() {
    return settingsProvider.settings;
  }

  /// Obtient la devise actuelle
  String getCurrentCurrency() {
    return settingsProvider.settings.currency;
  }

  /// Obtient le symbole de la devise
  String getCurrencySymbol() {
    final currency = getCurrentCurrency();
    final currencyData = availableCurrencies.firstWhere(
      (c) => c['code'] == currency,
      orElse: () => {'symbol': currency},
    );
    return currencyData['symbol']!;
  }

  /// Obtient le nom de la devise
  String getCurrencyName() {
    final currency = getCurrentCurrency();
    final currencyData = availableCurrencies.firstWhere(
      (c) => c['code'] == currency,
      orElse: () => {'name': currency},
    );
    return currencyData['name']!;
  }

  /// Change la devise
  Future<bool> changeCurrency(String currencyCode) async {
    await settingsProvider.setCurrency(currencyCode);
    return true;
  }

  /// Obtient la langue actuelle
  String getCurrentLanguage() {
    return settingsProvider.settings.language;
  }

  /// Change la langue
  Future<bool> changeLanguage(String languageCode) async {
    await settingsProvider.setLanguage(languageCode);
    return true;
  }

  /// Obtient le thème actuel
  String getCurrentTheme() {
    return settingsProvider.settings.theme;
  }

  /// Change le thème
  Future<bool> changeTheme(String theme) async {
    await settingsProvider.setTheme(theme);
    return true;
  }

  /// Bascule le mode sombre
  Future<void> toggleDarkMode() async {
    await settingsProvider.toggleDarkMode();
  }

  /// Vérifie si le mode sombre est activé
  bool isDarkMode() {
    return settingsProvider.darkMode;
  }

  /// Obtient le premier jour de la semaine
  int getFirstDayOfWeek() {
    return settingsProvider.settings.firstDayOfWeek;
  }

  /// Change le premier jour de la semaine
  Future<bool> changeFirstDayOfWeek(int day) async {
    await settingsProvider.setFirstDayOfWeek(day);
    return true;
  }

  /// Obtient le type de transaction par défaut
  String getDefaultTransactionType() {
    return settingsProvider.settings.defaultTransactionType;
  }

  /// Change le type de transaction par défaut
  Future<bool> changeDefaultTransactionType(String type) async {
    await settingsProvider.setDefaultTransactionType(type);
    return true;
  }

  /// Obtient l'intervalle de sauvegarde
  int getBackupInterval() {
    return settingsProvider.settings.backupInterval;
  }

  /// Change l'intervalle de sauvegarde
  Future<bool> changeBackupInterval(int days) async {
    await settingsProvider.setBackupInterval(days);
    return true;
  }

  /// Vérifie si les notifications sont activées
  bool areNotificationsEnabled() {
    return settingsProvider.notificationsEnabled;
  }

  /// Bascule les notifications
  Future<void> toggleNotifications() async {
    await settingsProvider.toggleNotifications();
  }

  /// Vérifie si l'authentification biométrique est activée
  bool isBiometricAuthEnabled() {
    return settingsProvider.biometricAuth;
  }

  /// Bascule l'authentification biométrique
  Future<void> toggleBiometricAuth() async {
    await settingsProvider.toggleBiometricAuth();
  }

  /// Crée une sauvegarde
  Future<bool> createBackup() async {
    return await settingsProvider.createBackup();
  }

  /// Restaure une sauvegarde
  Future<bool> restoreBackup(String filePath) async {
    return await settingsProvider.restoreBackup(filePath);
  }

  /// Exporte en CSV
  Future<bool> exportToCSV() async {
    return await settingsProvider.exportToCSV();
  }

  /// Nettoie les anciennes sauvegardes
  Future<bool> cleanOldBackups() async {
    return await settingsProvider.cleanOldBackups();
  }

  /// Réinitialise l'application
  Future<bool> resetApp() async {
    return await settingsProvider.resetApp();
  }

  /// Obtient la version de l'application
  String getAppVersion() {
    return '1.0.0';
  }

  /// Obtient les informations de l'application
  Map<String, String> getAppInfo() {
    return {
      'name': 'BudgetBuddy',
      'version': getAppVersion(),
      'developer': 'Votre Nom',
      'website': 'https://budgetbuddy.app',
      'email': 'support@budgetbuddy.app',
    };
  }

  /// Vérifie si des mises à jour sont disponibles
  Future<bool> checkForUpdates() async {
    // TODO: Implémenter la vérification de mises à jour
    return false;
  }

  /// Obtient les statistiques de l'application
  Future<Map<String, dynamic>> getAppStatistics() async {
    // TODO: Implémenter les statistiques
    return {
      'total_transactions': 0,
      'total_categories': 0,
      'total_budgets': 0,
      'database_size': 0,
    };
  }

  /// Affiche la page À propos
  void showAboutPage(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'BudgetBuddy',
      applicationVersion: getAppVersion(),
      applicationIcon: const Icon(Icons.account_balance_wallet, size: 48),
      children: [
        const Text('Application de gestion budgétaire personnelle.'),
        const SizedBox(height: 16),
        const Text('Développé avec ❤️ par votre équipe.'),
      ],
    );
  }

  /// Obtient l'erreur actuelle
  String? getError() {
    return settingsProvider.error;
  }

  /// Efface l'erreur
  void clearError() {
    settingsProvider.clearError();
  }

  /// Vérifie si un chargement est en cours
  bool isLoading() {
    return settingsProvider.isLoading;
  }
}
