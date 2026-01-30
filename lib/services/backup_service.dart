import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import '../utils/constants.dart';
import 'database_service.dart';

/// Service de sauvegarde et restauration des données
class BackupService {
  final DatabaseService _dbService = DatabaseService();

  /// Crée une sauvegarde complète de la base de données
  Future<File> createBackup() async {
    final db = await _dbService.database;
    final dbPath = await getDatabasesPath();
    final dbFile = File(join(dbPath, AppConstants.databaseName));

    // Créer le dossier de sauvegarde
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(join(appDir.path, 'backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    // Nom du fichier de sauvegarde avec timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupFileName = 'budget_buddy_backup_$timestamp.db';
    final backupFile = File(join(backupDir.path, backupFileName));

    // Copier la base de données
    await db.close();
    await dbFile.copy(backupFile.path);

    // Réouvrir la base de données
    await _dbService.database;

    return backupFile;
  }

  /// Crée une sauvegarde au format JSON
  Future<File> createJSONBackup() async {
    final db = await _dbService.database;

    // Récupérer toutes les données
    final data = <String, dynamic>{};

    // Transactions
    final transactions = await db.query(AppConstants.tableTransactions);
    data['transactions'] = transactions;

    // Catégories
    final categories = await db.query(AppConstants.tableCategories);
    data['categories'] = categories;

    // Budgets
    final budgets = await db.query(AppConstants.tableBudgets);
    data['budgets'] = budgets;

    // Comptes
    final accounts = await db.query(AppConstants.tableAccounts);
    data['accounts'] = accounts;

    // Objectifs d'épargne
    final savingsGoals = await db.query(AppConstants.tableSavingsGoals);
    data['savings_goals'] = savingsGoals;

    // Paramètres
    final settings = await db.query(AppConstants.tableUserSettings);
    data['settings'] = settings;

    // Rapports
    final reports = await db.query(AppConstants.tableReports);
    data['reports'] = reports;

    // Métadonnées
    data['metadata'] = {
      'version': AppConstants.appVersion,
      'backup_date': DateTime.now().toIso8601String(),
      'database_version': AppConstants.databaseVersion,
    };

    // Créer le fichier JSON
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(join(appDir.path, 'backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupFileName = 'budget_buddy_backup_$timestamp.json';
    final backupFile = File(join(backupDir.path, backupFileName));

    // Écrire les données
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    await backupFile.writeAsString(jsonString);

    return backupFile;
  }

  /// Restaure une sauvegarde depuis un fichier de base de données
  Future<void> restoreFromBackup(File backupFile) async {
    final db = await _dbService.database;
    final dbPath = await getDatabasesPath();
    final dbFile = File(join(dbPath, AppConstants.databaseName));

    // Fermer la connexion
    await db.close();

    // Copier le fichier de sauvegarde
    await backupFile.copy(dbFile.path);

    // Réouvrir la base de données
    await _dbService.database;
  }

  /// Restaure une sauvegarde depuis un fichier JSON
  Future<void> restoreFromJSONBackup(File backupFile) async {
    final db = await _dbService.database;

    // Lire le fichier JSON
    final jsonString = await backupFile.readAsString();
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    // Vérifier la version
    final metadata = data['metadata'] as Map<String, dynamic>?;
    if (metadata != null) {
      final backupVersion = metadata['database_version'] as int?;
      if (backupVersion != null &&
          backupVersion != AppConstants.databaseVersion) {
        throw Exception(
          'Version de sauvegarde incompatible. Sauvegarde: $backupVersion, Application: ${AppConstants.databaseVersion}',
        );
      }
    }

    // Commencer une transaction
    await db.transaction((txn) async {
      // Supprimer toutes les données existantes
      await txn.delete(AppConstants.tableTransactions);
      await txn.delete(AppConstants.tableCategories);
      await txn.delete(AppConstants.tableBudgets);
      await txn.delete(AppConstants.tableAccounts);
      await txn.delete(AppConstants.tableSavingsGoals);
      await txn.delete(AppConstants.tableUserSettings);
      await txn.delete(AppConstants.tableReports);

      // Restaurer les catégories d'abord (pour les clés étrangères)
      final categories = data['categories'] as List<dynamic>?;
      if (categories != null) {
        for (final category in categories) {
          await txn.insert(
            AppConstants.tableCategories,
            category as Map<String, dynamic>,
          );
        }
      }

      // Restaurer les comptes
      final accounts = data['accounts'] as List<dynamic>?;
      if (accounts != null) {
        for (final account in accounts) {
          await txn.insert(
            AppConstants.tableAccounts,
            account as Map<String, dynamic>,
          );
        }
      }

      // Restaurer les transactions
      final transactions = data['transactions'] as List<dynamic>?;
      if (transactions != null) {
        for (final transaction in transactions) {
          await txn.insert(
            AppConstants.tableTransactions,
            transaction as Map<String, dynamic>,
          );
        }
      }

      // Restaurer les budgets
      final budgets = data['budgets'] as List<dynamic>?;
      if (budgets != null) {
        for (final budget in budgets) {
          await txn.insert(
            AppConstants.tableBudgets,
            budget as Map<String, dynamic>,
          );
        }
      }

      // Restaurer les objectifs d'épargne
      final savingsGoals = data['savings_goals'] as List<dynamic>?;
      if (savingsGoals != null) {
        for (final goal in savingsGoals) {
          await txn.insert(
            AppConstants.tableSavingsGoals,
            goal as Map<String, dynamic>,
          );
        }
      }

      // Restaurer les paramètres
      final settings = data['settings'] as List<dynamic>?;
      if (settings != null) {
        for (final setting in settings) {
          await txn.insert(
            AppConstants.tableUserSettings,
            setting as Map<String, dynamic>,
          );
        }
      }

      // Restaurer les rapports
      final reports = data['reports'] as List<dynamic>?;
      if (reports != null) {
        for (final report in reports) {
          await txn.insert(
            AppConstants.tableReports,
            report as Map<String, dynamic>,
          );
        }
      }
    });
  }

  /// Liste toutes les sauvegardes disponibles
  Future<List<File>> listBackups() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(join(appDir.path, 'backups'));

    if (!await backupDir.exists()) {
      return [];
    }

    final files = await backupDir.list().toList();
    final backupFiles = files
        .whereType<File>()
        .where(
          (file) => file.path.endsWith('.db') || file.path.endsWith('.json'),
        )
        .toList();

    // Trier par date de modification (plus récent en premier)
    backupFiles.sort((a, b) {
      final aStat = a.statSync();
      final bStat = b.statSync();
      return bStat.modified.compareTo(aStat.modified);
    });

    return backupFiles;
  }

  /// Supprime une sauvegarde
  Future<void> deleteBackup(File backupFile) async {
    if (await backupFile.exists()) {
      await backupFile.delete();
    }
  }

  /// Supprime toutes les sauvegardes
  Future<void> deleteAllBackups() async {
    final backups = await listBackups();
    for (final backup in backups) {
      await backup.delete();
    }
  }

  /// Partage une sauvegarde
  Future<void> shareBackup(File backupFile) async {
    await Share.shareXFiles(
      [XFile(backupFile.path)],
      subject: 'Sauvegarde BudgetBuddy',
      text: 'Voici ma sauvegarde BudgetBuddy',
    );
  }

  /// Exporte les données au format CSV
  Future<File> exportToCSV() async {
    final db = await _dbService.database;
    final buffer = StringBuffer();

    // En-tête
    buffer.writeln('=== BUDGET BUDDY - EXPORT DE DONNÉES ===');
    buffer.writeln('Date d\'export: ${DateTime.now()}');
    buffer.writeln();

    // Transactions
    buffer.writeln('=== TRANSACTIONS ===');
    buffer.writeln('ID,Titre,Montant,Date,Type,Catégorie ID,Description');
    final transactions = await db.query(AppConstants.tableTransactions);
    for (final transaction in transactions) {
      buffer.writeln(
        '${transaction['id']},${transaction['title']},${transaction['amount']},${transaction['date']},${transaction['transaction_type']},${transaction['category_id']},${transaction['description'] ?? ''}',
      );
    }
    buffer.writeln();

    // Catégories
    buffer.writeln('=== CATÉGORIES ===');
    buffer.writeln('ID,Nom,Type,Icône,Couleur');
    final categories = await db.query(AppConstants.tableCategories);
    for (final category in categories) {
      buffer.writeln(
        '${category['id']},${category['name']},${category['category_type']},${category['icon']},${category['color']}',
      );
    }
    buffer.writeln();

    // Budgets
    buffer.writeln('=== BUDGETS ===');
    buffer.writeln('ID,Catégorie ID,Limite,Type de période,Montant dépensé');
    final budgets = await db.query(AppConstants.tableBudgets);
    for (final budget in budgets) {
      buffer.writeln(
        '${budget['id']},${budget['category_id']},${budget['amount_limit']},${budget['period_type']},${budget['current_spent']}',
      );
    }

    // Créer le fichier
    final appDir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final csvFile = File(
      join(appDir.path, 'budget_buddy_export_$timestamp.csv'),
    );
    await csvFile.writeAsString(buffer.toString());

    return csvFile;
  }

  /// Nettoie les anciennes sauvegardes (garde les 5 plus récentes)
  Future<void> cleanOldBackups({int keepCount = 5}) async {
    final backups = await listBackups();

    if (backups.length <= keepCount) {
      return;
    }

    // Supprimer les anciennes sauvegardes
    for (var i = keepCount; i < backups.length; i++) {
      await backups[i].delete();
    }
  }
}
