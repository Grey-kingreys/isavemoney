import 'package:sqflite/sqflite.dart';
import '../models/user_settings_model.dart';
import '../utils/constants.dart';
import 'database_service.dart';

/// Service de gestion des paramètres utilisateur en base de données
class SettingsService {
  final DatabaseService _dbService = DatabaseService();

  /// Récupère tous les paramètres
  Future<List<UserSettingsModel>> getAllSettings() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableUserSettings,
      orderBy: 'category ASC, setting_key ASC',
    );

    return maps.map((map) => UserSettingsModel.fromMap(map)).toList();
  }

  /// Récupère un paramètre par sa clé
  Future<UserSettingsModel?> getSettingByKey(String key) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableUserSettings,
      where: 'setting_key = ?',
      whereArgs: [key],
    );

    if (maps.isEmpty) return null;
    return UserSettingsModel.fromMap(maps.first);
  }

  /// Récupère les paramètres par catégorie
  Future<List<UserSettingsModel>> getSettingsByCategory(String category) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableUserSettings,
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'setting_key ASC',
    );

    return maps.map((map) => UserSettingsModel.fromMap(map)).toList();
  }

  /// Crée ou met à jour un paramètre
  Future<int> setSetting(UserSettingsModel setting) async {
    final db = await _dbService.database;

    // Vérifie si le paramètre existe déjà
    final existing = await getSettingByKey(setting.settingKey);

    if (existing != null) {
      // Mise à jour
      return await db.update(
        AppConstants.tableUserSettings,
        setting.copyWith(updatedAt: DateTime.now()).toMap(),
        where: 'setting_key = ?',
        whereArgs: [setting.settingKey],
      );
    } else {
      // Insertion
      return await db.insert(
        AppConstants.tableUserSettings,
        setting.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Met à jour la valeur d'un paramètre par sa clé
  Future<bool> updateSettingValue(String key, String value) async {
    final db = await _dbService.database;

    final result = await db.update(
      AppConstants.tableUserSettings,
      {'setting_value': value, 'updated_at': DateTime.now().toIso8601String()},
      where: 'setting_key = ?',
      whereArgs: [key],
    );

    return result > 0;
  }

  /// Supprime un paramètre
  Future<int> deleteSetting(String key) async {
    final db = await _dbService.database;
    return await db.delete(
      AppConstants.tableUserSettings,
      where: 'setting_key = ?',
      whereArgs: [key],
    );
  }

  /// Récupère la valeur d'un paramètre (String)
  Future<String?> getStringValue(String key, {String? defaultValue}) async {
    final setting = await getSettingByKey(key);
    return setting?.stringValue ?? defaultValue;
  }

  /// Récupère la valeur d'un paramètre (int)
  Future<int?> getIntValue(String key, {int? defaultValue}) async {
    final setting = await getSettingByKey(key);
    return setting?.intValue ?? defaultValue;
  }

  /// Récupère la valeur d'un paramètre (double)
  Future<double?> getDoubleValue(String key, {double? defaultValue}) async {
    final setting = await getSettingByKey(key);
    return setting?.doubleValue ?? defaultValue;
  }

  /// Récupère la valeur d'un paramètre (bool)
  Future<bool?> getBoolValue(String key, {bool? defaultValue}) async {
    final setting = await getSettingByKey(key);
    return setting?.boolValue ?? defaultValue;
  }

  /// Définit une valeur String
  Future<bool> setStringValue(
    String key,
    String value, {
    String? category,
    String? description,
  }) async {
    final setting = UserSettingsModel(
      settingKey: key,
      settingValue: value,
      settingType: 'string',
      category: category,
      description: description,
    );

    final result = await setSetting(setting);
    return result > 0;
  }

  /// Définit une valeur int
  Future<bool> setIntValue(
    String key,
    int value, {
    String? category,
    String? description,
  }) async {
    final setting = UserSettingsModel(
      settingKey: key,
      settingValue: value.toString(),
      settingType: 'integer',
      category: category,
      description: description,
    );

    final result = await setSetting(setting);
    return result > 0;
  }

  /// Définit une valeur double
  Future<bool> setDoubleValue(
    String key,
    double value, {
    String? category,
    String? description,
  }) async {
    final setting = UserSettingsModel(
      settingKey: key,
      settingValue: value.toString(),
      settingType: 'real',
      category: category,
      description: description,
    );

    final result = await setSetting(setting);
    return result > 0;
  }

  /// Définit une valeur bool
  Future<bool> setBoolValue(
    String key,
    bool value, {
    String? category,
    String? description,
  }) async {
    final setting = UserSettingsModel(
      settingKey: key,
      settingValue: value ? '1' : '0',
      settingType: 'boolean',
      category: category,
      description: description,
    );

    final result = await setSetting(setting);
    return result > 0;
  }

  /// Bascule une valeur booléenne
  Future<bool> toggleBoolValue(String key) async {
    final currentValue = await getBoolValue(key, defaultValue: false);
    return await setBoolValue(key, !currentValue!);
  }

  /// Récupère les paramètres de l'application sous forme d'objet AppSettings
  Future<AppSettings> getAppSettings() async {
    final settings = await getAllSettings();
    return AppSettings.fromList(settings);
  }

  /// Sauvegarde les paramètres de l'application
  Future<bool> saveAppSettings(AppSettings appSettings) async {
    final db = await _dbService.database;

    try {
      await db.transaction((txn) async {
        final settingsList = appSettings.toList();

        for (final setting in settingsList) {
          final existing = await txn.query(
            AppConstants.tableUserSettings,
            where: 'setting_key = ?',
            whereArgs: [setting.settingKey],
          );

          if (existing.isNotEmpty) {
            await txn.update(
              AppConstants.tableUserSettings,
              {
                'setting_value': setting.settingValue,
                'updated_at': DateTime.now().toIso8601String(),
              },
              where: 'setting_key = ?',
              whereArgs: [setting.settingKey],
            );
          } else {
            await txn.insert(AppConstants.tableUserSettings, setting.toMap());
          }
        }
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Réinitialise tous les paramètres aux valeurs par défaut
  Future<bool> resetToDefaults() async {
    final db = await _dbService.database;

    try {
      // Supprime tous les paramètres existants
      await db.delete(AppConstants.tableUserSettings);

      // Réinsère les paramètres par défaut
      final defaultSettings = [
        {
          'key': 'currency',
          'value': 'EUR',
          'type': 'string',
          'category': 'general',
        },
        {
          'key': 'language',
          'value': 'fr',
          'type': 'string',
          'category': 'general',
        },
        {
          'key': 'first_day_of_week',
          'value': '1',
          'type': 'integer',
          'category': 'general',
        },
        {
          'key': 'theme',
          'value': 'light',
          'type': 'string',
          'category': 'appearance',
        },
        {
          'key': 'default_transaction_type',
          'value': 'expense',
          'type': 'string',
          'category': 'transactions',
        },
        {
          'key': 'backup_interval',
          'value': '7',
          'type': 'integer',
          'category': 'backup',
        },
        {
          'key': 'notifications_enabled',
          'value': '1',
          'type': 'boolean',
          'category': 'notifications',
        },
        {
          'key': 'biometric_auth',
          'value': '0',
          'type': 'boolean',
          'category': 'security',
        },
        {
          'key': 'data_encryption',
          'value': '0',
          'type': 'boolean',
          'category': 'security',
        },
      ];

      for (final setting in defaultSettings) {
        await db.insert(AppConstants.tableUserSettings, {
          'setting_key': setting['key'],
          'setting_value': setting['value'],
          'setting_type': setting['type'],
          'category': setting['category'],
        });
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Exporte tous les paramètres
  Future<Map<String, dynamic>> exportSettings() async {
    final settings = await getAllSettings();
    final Map<String, dynamic> export = {};

    for (final setting in settings) {
      export[setting.settingKey] = {
        'value': setting.settingValue,
        'type': setting.settingType,
        'category': setting.category,
      };
    }

    return export;
  }

  /// Importe des paramètres
  Future<bool> importSettings(Map<String, dynamic> settingsMap) async {
    try {
      for (final entry in settingsMap.entries) {
        final key = entry.key;
        final data = entry.value as Map<String, dynamic>;

        final setting = UserSettingsModel(
          settingKey: key,
          settingValue: data['value'] as String?,
          settingType: data['type'] as String,
          category: data['category'] as String?,
        );

        await setSetting(setting);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Vérifie si un paramètre existe
  Future<bool> settingExists(String key) async {
    final setting = await getSettingByKey(key);
    return setting != null;
  }

  /// Récupère les catégories de paramètres disponibles
  Future<List<String>> getAvailableCategories() async {
    final db = await _dbService.database;
    final result = await db.rawQuery('''
      SELECT DISTINCT category
      FROM ${AppConstants.tableUserSettings}
      WHERE category IS NOT NULL
      ORDER BY category ASC
    ''');

    return result
        .map((row) => row['category'] as String)
        .where((category) => category.isNotEmpty)
        .toList();
  }

  /// Compte le nombre de paramètres
  Future<int> getSettingsCount() async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.tableUserSettings}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Recherche des paramètres par clé ou description
  Future<List<UserSettingsModel>> searchSettings(String query) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableUserSettings,
      where: 'setting_key LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'setting_key ASC',
    );

    return maps.map((map) => UserSettingsModel.fromMap(map)).toList();
  }

  /// Récupère la date de dernière modification d'un paramètre
  Future<DateTime?> getLastUpdateDate(String key) async {
    final setting = await getSettingByKey(key);
    return setting?.updatedAt;
  }

  /// Récupère tous les paramètres modifiés depuis une date
  Future<List<UserSettingsModel>> getSettingsModifiedSince(
    DateTime date,
  ) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableUserSettings,
      where: 'updated_at > ?',
      whereArgs: [date.toIso8601String()],
      orderBy: 'updated_at DESC',
    );

    return maps.map((map) => UserSettingsModel.fromMap(map)).toList();
  }

  /// Clone les paramètres (pour sauvegarde avant modification)
  Future<Map<String, UserSettingsModel>> cloneAllSettings() async {
    final settings = await getAllSettings();
    final Map<String, UserSettingsModel> clone = {};

    for (final setting in settings) {
      clone[setting.settingKey] = setting;
    }

    return clone;
  }

  /// Restaure des paramètres depuis un clone
  Future<bool> restoreFromClone(Map<String, UserSettingsModel> clone) async {
    try {
      for (final setting in clone.values) {
        await setSetting(setting);
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
