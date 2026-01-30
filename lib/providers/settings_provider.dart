import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_settings_model.dart';
import '../services/backup_service.dart';
import '../services/database_service.dart';

/// Provider pour la gestion des paramètres
class SettingsProvider with ChangeNotifier {
  final BackupService _backupService = BackupService();
  final DatabaseService _dbService = DatabaseService();

  bool _isLoading = false;
  String? _error;

  // Paramètres de l'application
  AppSettings _settings = AppSettings();
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  bool _biometricAuth = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  AppSettings get settings => _settings;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkMode => _darkMode;
  bool get biometricAuth => _biometricAuth;

  /// Charge les paramètres
  Future<void> loadSettings() async {
    _setLoading(true);
    _error = null;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Charge les paramètres basiques
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _biometricAuth = prefs.getBool('biometric_auth') ?? false;

      // Charge les paramètres de l'application
      _settings = AppSettings(
        currency: prefs.getString('currency') ?? 'EUR',
        language: prefs.getString('language') ?? 'fr',
        firstDayOfWeek: prefs.getInt('first_day_of_week') ?? 1,
        theme: prefs.getString('theme') ?? 'light',
        defaultTransactionType:
            prefs.getString('default_transaction_type') ?? 'expense',
        backupInterval: prefs.getInt('backup_interval') ?? 7,
        notificationsEnabled: _notificationsEnabled,
        biometricAuth: _biometricAuth,
        dataEncryption: prefs.getBool('data_encryption') ?? false,
      );
    } catch (e) {
      _error = 'Erreur lors du chargement des paramètres: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  /// Sauvegarde les paramètres
  Future<bool> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('currency', _settings.currency);
      await prefs.setString('language', _settings.language);
      await prefs.setInt('first_day_of_week', _settings.firstDayOfWeek);
      await prefs.setString('theme', _settings.theme);
      await prefs.setString(
        'default_transaction_type',
        _settings.defaultTransactionType,
      );
      await prefs.setInt('backup_interval', _settings.backupInterval);
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
      await prefs.setBool('dark_mode', _darkMode);
      await prefs.setBool('biometric_auth', _biometricAuth);
      await prefs.setBool('data_encryption', _settings.dataEncryption);

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la sauvegarde: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Change la devise
  Future<void> setCurrency(String currency) async {
    _settings.currency = currency;
    await saveSettings();
  }

  /// Change la langue
  Future<void> setLanguage(String language) async {
    _settings.language = language;
    await saveSettings();
  }

  /// Change le premier jour de la semaine
  Future<void> setFirstDayOfWeek(int day) async {
    _settings.firstDayOfWeek = day;
    await saveSettings();
  }

  /// Change le thème
  Future<void> setTheme(String theme) async {
    _settings.theme = theme;
    _darkMode = theme == 'dark';
    await saveSettings();
  }

  /// Active/désactive le mode sombre
  Future<void> toggleDarkMode() async {
    _darkMode = !_darkMode;
    _settings.theme = _darkMode ? 'dark' : 'light';
    await saveSettings();
  }

  /// Active/désactive les notifications
  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    _settings.notificationsEnabled = _notificationsEnabled;
    await saveSettings();
  }

  /// Active/désactive l'authentification biométrique
  Future<void> toggleBiometricAuth() async {
    _biometricAuth = !_biometricAuth;
    _settings.biometricAuth = _biometricAuth;
    await saveSettings();
  }

  /// Change le type de transaction par défaut
  Future<void> setDefaultTransactionType(String type) async {
    _settings.defaultTransactionType = type;
    await saveSettings();
  }

  /// Change l'intervalle de sauvegarde
  Future<void> setBackupInterval(int days) async {
    _settings.backupInterval = days;
    await saveSettings();
  }

  /// Crée une sauvegarde
  Future<bool> createBackup() async {
    _setLoading(true);
    _error = null;

    try {
      final file = await _backupService.createJSONBackup();
      await _backupService.shareBackup(file);
      return true;
    } catch (e) {
      _error = 'Erreur lors de la sauvegarde: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Restaure une sauvegarde
  Future<bool> restoreBackup(String filePath) async {
    _setLoading(true);
    _error = null;

    try {
      await _backupService.restoreFromJSONBackup(
        await _backupService.listBackups().then((files) => files.first),
      );
      return true;
    } catch (e) {
      _error = 'Erreur lors de la restauration: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Exporte les données en CSV
  Future<bool> exportToCSV() async {
    _setLoading(true);
    _error = null;

    try {
      final file = await _backupService.exportToCSV();
      await _backupService.shareBackup(file);
      return true;
    } catch (e) {
      _error = 'Erreur lors de l\'export: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Nettoie les anciennes sauvegardes
  Future<bool> cleanOldBackups() async {
    try {
      await _backupService.cleanOldBackups(keepCount: 5);
      return true;
    } catch (e) {
      _error = 'Erreur lors du nettoyage: $e';
      debugPrint(_error);
      return false;
    }
  }

  /// Réinitialise l'application
  Future<bool> resetApp() async {
    _setLoading(true);
    _error = null;

    try {
      // Réinitialise la base de données
      await _dbService.reset();

      // Réinitialise les préférences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Recharge les paramètres par défaut
      await loadSettings();

      return true;
    } catch (e) {
      _error = 'Erreur lors de la réinitialisation: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Définit l'état de chargement
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Efface l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
