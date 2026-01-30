/// Modèle de paramètres utilisateur
class UserSettingsModel {
  final int? id;
  final String settingKey;
  final String? settingValue;
  final String settingType; // 'string', 'integer', 'real', 'boolean', 'json'
  final String? category;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSettingsModel({
    this.id,
    required this.settingKey,
    this.settingValue,
    required this.settingType,
    this.category,
    this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Crée un paramètre depuis une Map
  factory UserSettingsModel.fromMap(Map<String, dynamic> map) {
    return UserSettingsModel(
      id: map['id'] as int?,
      settingKey: map['setting_key'] as String,
      settingValue: map['setting_value'] as String?,
      settingType: map['setting_type'] as String,
      category: map['category'] as String?,
      description: map['description'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Convertit le paramètre en Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'setting_key': settingKey,
      'setting_value': settingValue,
      'setting_type': settingType,
      'category': category,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copie le paramètre avec de nouvelles valeurs
  UserSettingsModel copyWith({
    int? id,
    String? settingKey,
    String? settingValue,
    String? settingType,
    String? category,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettingsModel(
      id: id ?? this.id,
      settingKey: settingKey ?? this.settingKey,
      settingValue: settingValue ?? this.settingValue,
      settingType: settingType ?? this.settingType,
      category: category ?? this.category,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Obtient la valeur en tant que String
  String? get stringValue => settingValue;

  /// Obtient la valeur en tant que int
  int? get intValue {
    if (settingValue == null) return null;
    return int.tryParse(settingValue!);
  }

  /// Obtient la valeur en tant que double
  double? get doubleValue {
    if (settingValue == null) return null;
    return double.tryParse(settingValue!);
  }

  /// Obtient la valeur en tant que bool
  bool? get boolValue {
    if (settingValue == null) return null;
    return settingValue == '1' || settingValue?.toLowerCase() == 'true';
  }

  @override
  String toString() {
    return 'UserSettingsModel(key: $settingKey, value: $settingValue)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserSettingsModel && other.settingKey == settingKey;
  }

  @override
  int get hashCode => settingKey.hashCode;
}

/// Classe pour gérer les paramètres de l'application
class AppSettings {
  String currency;
  String language;
  int firstDayOfWeek;
  String theme;
  String defaultTransactionType;
  int backupInterval;
  bool notificationsEnabled;
  bool biometricAuth;
  bool dataEncryption;

  AppSettings({
    this.currency = 'EUR',
    this.language = 'fr',
    this.firstDayOfWeek = 1,
    this.theme = 'light',
    this.defaultTransactionType = 'expense',
    this.backupInterval = 7,
    this.notificationsEnabled = true,
    this.biometricAuth = false,
    this.dataEncryption = false,
  });

  /// Crée les paramètres depuis une liste de UserSettingsModel
  factory AppSettings.fromList(List<UserSettingsModel> settings) {
    final appSettings = AppSettings();

    for (final setting in settings) {
      switch (setting.settingKey) {
        case 'currency':
          appSettings.currency = setting.stringValue ?? 'EUR';
          break;
        case 'language':
          appSettings.language = setting.stringValue ?? 'fr';
          break;
        case 'first_day_of_week':
          appSettings.firstDayOfWeek = setting.intValue ?? 1;
          break;
        case 'theme':
          appSettings.theme = setting.stringValue ?? 'light';
          break;
        case 'default_transaction_type':
          appSettings.defaultTransactionType = setting.stringValue ?? 'expense';
          break;
        case 'backup_interval':
          appSettings.backupInterval = setting.intValue ?? 7;
          break;
        case 'notifications_enabled':
          appSettings.notificationsEnabled = setting.boolValue ?? true;
          break;
        case 'biometric_auth':
          appSettings.biometricAuth = setting.boolValue ?? false;
          break;
        case 'data_encryption':
          appSettings.dataEncryption = setting.boolValue ?? false;
          break;
      }
    }

    return appSettings;
  }

  /// Convertit les paramètres en liste de UserSettingsModel
  List<UserSettingsModel> toList() {
    return [
      UserSettingsModel(
        settingKey: 'currency',
        settingValue: currency,
        settingType: 'string',
        category: 'general',
      ),
      UserSettingsModel(
        settingKey: 'language',
        settingValue: language,
        settingType: 'string',
        category: 'general',
      ),
      UserSettingsModel(
        settingKey: 'first_day_of_week',
        settingValue: firstDayOfWeek.toString(),
        settingType: 'integer',
        category: 'general',
      ),
      UserSettingsModel(
        settingKey: 'theme',
        settingValue: theme,
        settingType: 'string',
        category: 'appearance',
      ),
      UserSettingsModel(
        settingKey: 'default_transaction_type',
        settingValue: defaultTransactionType,
        settingType: 'string',
        category: 'transactions',
      ),
      UserSettingsModel(
        settingKey: 'backup_interval',
        settingValue: backupInterval.toString(),
        settingType: 'integer',
        category: 'backup',
      ),
      UserSettingsModel(
        settingKey: 'notifications_enabled',
        settingValue: notificationsEnabled ? '1' : '0',
        settingType: 'boolean',
        category: 'notifications',
      ),
      UserSettingsModel(
        settingKey: 'biometric_auth',
        settingValue: biometricAuth ? '1' : '0',
        settingType: 'boolean',
        category: 'security',
      ),
      UserSettingsModel(
        settingKey: 'data_encryption',
        settingValue: dataEncryption ? '1' : '0',
        settingType: 'boolean',
        category: 'security',
      ),
    ];
  }
}
