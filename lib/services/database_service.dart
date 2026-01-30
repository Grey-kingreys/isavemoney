import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../utils/constants.dart';

/// Service de gestion de la base de données SQLite
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  /// Obtient l'instance de la base de données
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialise la base de données
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Configure la base de données
  Future<void> _onConfigure(Database db) async {
    // Active les contraintes de clés étrangères
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Crée les tables lors de la première installation
  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _insertInitialData(db);
  }

  /// Met à jour la base de données lors d'une nouvelle version
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Logique de migration pour les futures versions
    if (oldVersion < 2) {
      // Exemple de migration pour la version 2
      // await db.execute('ALTER TABLE ...');
    }
  }

  /// Crée toutes les tables
  Future<void> _createTables(Database db) async {
    // Table des transactions
    await db.execute('''
      CREATE TABLE ${AppConstants.tableTransactions} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL CHECK(amount >= 0),
        date DATETIME NOT NULL,
        category_id INTEGER NOT NULL,
        transaction_type TEXT NOT NULL CHECK(transaction_type IN ('income', 'expense')),
        payment_method TEXT,
        description TEXT,
        location TEXT,
        is_recurring BOOLEAN DEFAULT 0,
        recurring_pattern TEXT,
        next_occurrence DATETIME,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES ${AppConstants.tableCategories}(id) ON DELETE RESTRICT
      )
    ''');

    // Index pour améliorer les performances
    await db.execute('''
      CREATE INDEX idx_transactions_date ON ${AppConstants.tableTransactions}(date DESC)
    ''');
    await db.execute('''
      CREATE INDEX idx_transactions_category ON ${AppConstants.tableTransactions}(category_id)
    ''');

    // Table des catégories
    await db.execute('''
      CREATE TABLE ${AppConstants.tableCategories} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        icon TEXT NOT NULL,
        color TEXT NOT NULL,
        category_type TEXT NOT NULL CHECK(category_type IN ('income', 'expense')),
        is_default BOOLEAN DEFAULT 1,
        is_active BOOLEAN DEFAULT 1,
        sort_order INTEGER DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Table des budgets
    await db.execute('''
      CREATE TABLE ${AppConstants.tableBudgets} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        amount_limit REAL NOT NULL CHECK(amount_limit >= 0),
        period_type TEXT NOT NULL CHECK(period_type IN ('daily', 'weekly', 'monthly', 'yearly')),
        start_date DATETIME NOT NULL,
        end_date DATETIME,
        current_spent REAL DEFAULT 0,
        is_active BOOLEAN DEFAULT 1,
        notifications_enabled BOOLEAN DEFAULT 1,
        notification_threshold REAL DEFAULT 80,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES ${AppConstants.tableCategories}(id) ON DELETE CASCADE
      )
    ''');

    // Table des objectifs d'épargne
    await db.execute('''
      CREATE TABLE ${AppConstants.tableSavingsGoals} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        target_amount REAL NOT NULL CHECK(target_amount > 0),
        current_amount REAL DEFAULT 0,
        target_date DATETIME,
        icon TEXT,
        color TEXT,
        is_completed BOOLEAN DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Table des comptes bancaires
    await db.execute('''
      CREATE TABLE ${AppConstants.tableAccounts} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        account_type TEXT CHECK(account_type IN ('cash', 'bank', 'credit_card', 'savings', 'investment')),
        initial_balance REAL DEFAULT 0,
        current_balance REAL DEFAULT 0,
        currency TEXT DEFAULT 'EUR',
        is_active BOOLEAN DEFAULT 1,
        color TEXT,
        icon TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Table de liaison transactions-comptes
    await db.execute('''
      CREATE TABLE ${AppConstants.tableTransactionAccounts} (
        transaction_id INTEGER NOT NULL,
        account_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        PRIMARY KEY (transaction_id, account_id),
        FOREIGN KEY (transaction_id) REFERENCES ${AppConstants.tableTransactions}(id) ON DELETE CASCADE,
        FOREIGN KEY (account_id) REFERENCES ${AppConstants.tableAccounts}(id) ON DELETE CASCADE
      )
    ''');

    // Table des rapports
    await db.execute('''
      CREATE TABLE ${AppConstants.tableReports} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        report_type TEXT NOT NULL CHECK(report_type IN ('monthly', 'yearly', 'custom')),
        period_start DATETIME NOT NULL,
        period_end DATETIME NOT NULL,
        total_income REAL DEFAULT 0,
        total_expense REAL DEFAULT 0,
        net_balance REAL DEFAULT 0,
        report_data TEXT,
        generated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        is_favorite BOOLEAN DEFAULT 0
      )
    ''');

    // Table des paramètres utilisateur
    await db.execute('''
      CREATE TABLE ${AppConstants.tableUserSettings} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        setting_key TEXT NOT NULL UNIQUE,
        setting_value TEXT,
        setting_type TEXT CHECK(setting_type IN ('string', 'integer', 'real', 'boolean', 'json')),
        category TEXT,
        description TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Table d'audit
    await db.execute('''
      CREATE TABLE ${AppConstants.tableAuditLog} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id INTEGER NOT NULL,
        action TEXT NOT NULL CHECK(action IN ('INSERT', 'UPDATE', 'DELETE')),
        old_values TEXT,
        new_values TEXT,
        changed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        changed_by TEXT DEFAULT 'system'
      )
    ''');

    // Triggers pour updated_at
    await _createUpdateTriggers(db);
  }

  /// Crée les triggers pour mettre à jour automatiquement updated_at
  Future<void> _createUpdateTriggers(Database db) async {
    final tables = [
      AppConstants.tableTransactions,
      AppConstants.tableBudgets,
      AppConstants.tableSavingsGoals,
      AppConstants.tableAccounts,
      AppConstants.tableUserSettings,
    ];

    for (final table in tables) {
      await db.execute('''
        CREATE TRIGGER update_${table}_timestamp
        AFTER UPDATE ON $table
        FOR EACH ROW
        BEGIN
          UPDATE $table SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
        END;
      ''');
    }
  }

  /// Insère les données initiales
  Future<void> _insertInitialData(Database db) async {
    // Insertion des catégories de dépenses
    final expenseCategories = [
      {
        'name': 'Alimentation',
        'icon': '🍔',
        'color': '#FF6B6B',
        'type': 'expense',
        'order': 1,
      },
      {
        'name': 'Transport',
        'icon': '🚗',
        'color': '#4ECDC4',
        'type': 'expense',
        'order': 2,
      },
      {
        'name': 'Logement',
        'icon': '🏠',
        'color': '#45B7D1',
        'type': 'expense',
        'order': 3,
      },
      {
        'name': 'Services',
        'icon': '💡',
        'color': '#96CEB4',
        'type': 'expense',
        'order': 4,
      },
      {
        'name': 'Shopping',
        'icon': '🛍️',
        'color': '#FFEAA7',
        'type': 'expense',
        'order': 5,
      },
      {
        'name': 'Loisirs',
        'icon': '🎬',
        'color': '#DDA0DD',
        'type': 'expense',
        'order': 6,
      },
      {
        'name': 'Santé',
        'icon': '🏥',
        'color': '#F7DC6F',
        'type': 'expense',
        'order': 7,
      },
      {
        'name': 'Éducation',
        'icon': '📚',
        'color': '#BB8FCE',
        'type': 'expense',
        'order': 8,
      },
      {
        'name': 'Autres dépenses',
        'icon': '📦',
        'color': '#AAB7B8',
        'type': 'expense',
        'order': 9,
      },
    ];

    for (final category in expenseCategories) {
      await db.insert(AppConstants.tableCategories, {
        'name': category['name'],
        'icon': category['icon'],
        'color': category['color'],
        'category_type': category['type'],
        'sort_order': category['order'],
      });
    }

    // Insertion des catégories de revenus
    final incomeCategories = [
      {
        'name': 'Salaire',
        'icon': '💰',
        'color': '#2ECC71',
        'type': 'income',
        'order': 10,
      },
      {
        'name': 'Freelance',
        'icon': '💼',
        'color': '#3498DB',
        'type': 'income',
        'order': 11,
      },
      {
        'name': 'Investissements',
        'icon': '📈',
        'color': '#9B59B6',
        'type': 'income',
        'order': 12,
      },
      {
        'name': 'Cadeaux',
        'icon': '🎁',
        'color': '#E74C3C',
        'type': 'income',
        'order': 13,
      },
      {
        'name': 'Remboursements',
        'icon': '↪️',
        'color': '#F39C12',
        'type': 'income',
        'order': 14,
      },
      {
        'name': 'Autres revenus',
        'icon': '📥',
        'color': '#95A5A6',
        'type': 'income',
        'order': 15,
      },
    ];

    for (final category in incomeCategories) {
      await db.insert(AppConstants.tableCategories, {
        'name': category['name'],
        'icon': category['icon'],
        'color': category['color'],
        'category_type': category['type'],
        'sort_order': category['order'],
      });
    }

    // Insertion des paramètres par défaut
    await _insertDefaultSettings(db);
  }

  /// Insère les paramètres par défaut
  Future<void> _insertDefaultSettings(Database db) async {
    final settings = [
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

    for (final setting in settings) {
      await db.insert(AppConstants.tableUserSettings, {
        'setting_key': setting['key'],
        'setting_value': setting['value'],
        'setting_type': setting['type'],
        'category': setting['category'],
      });
    }
  }

  /// Ferme la connexion à la base de données
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Réinitialise la base de données (ATTENTION: supprime toutes les données!)
  Future<void> reset() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);
    await deleteDatabase(path);
    _database = null;
  }
}
