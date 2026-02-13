import 'package:sqflite/sqflite.dart';
import '../models/account_model.dart';
import '../utils/constants.dart';
import 'database_service.dart';

/// Service de gestion des comptes bancaires
class AccountService {
  final DatabaseService _dbService = DatabaseService();

  /// Crée un nouveau compte
  Future<int> createAccount(AccountModel account) async {
    final db = await _dbService.database;
    return await db.insert(
      AppConstants.tableAccounts,
      account.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Récupère tous les comptes
  Future<List<AccountModel>> getAllAccounts() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableAccounts,
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => AccountModel.fromMap(map)).toList();
  }

  /// Récupère les comptes actifs
  Future<List<AccountModel>> getActiveAccounts() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableAccounts,
      where: 'is_active = 1',
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => AccountModel.fromMap(map)).toList();
  }

  /// Récupère un compte par son ID
  Future<AccountModel?> getAccountById(int id) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableAccounts,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return AccountModel.fromMap(maps.first);
  }

  /// Récupère les comptes par type
  Future<List<AccountModel>> getAccountsByType(String type) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableAccounts,
      where: 'account_type = ? AND is_active = 1',
      whereArgs: [type],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => AccountModel.fromMap(map)).toList();
  }

  /// Met à jour un compte
  Future<int> updateAccount(AccountModel account) async {
    final db = await _dbService.database;
    return await db.update(
      AppConstants.tableAccounts,
      account.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  /// Met à jour le solde d'un compte
  Future<void> updateAccountBalance(int accountId, double newBalance) async {
    final db = await _dbService.database;
    await db.update(
      AppConstants.tableAccounts,
      {
        'current_balance': newBalance,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [accountId],
    );
  }

  /// Ajoute un montant au solde d'un compte
  Future<void> addToBalance(int accountId, double amount) async {
    final account = await getAccountById(accountId);
    if (account == null) return;

    final newBalance = account.currentBalance + amount;
    await updateAccountBalance(accountId, newBalance);
  }

  /// Retire un montant du solde d'un compte
  Future<void> subtractFromBalance(int accountId, double amount) async {
    final account = await getAccountById(accountId);
    if (account == null) return;

    final newBalance = account.currentBalance - amount;
    await updateAccountBalance(accountId, newBalance);
  }

  /// Transfère de l'argent entre deux comptes
  Future<bool> transferBetweenAccounts(
    int fromAccountId,
    int toAccountId,
    double amount,
  ) async {
    final db = await _dbService.database;

    try {
      await db.transaction((txn) async {
        // Débite le compte source
        await txn.rawUpdate(
          '''
          UPDATE ${AppConstants.tableAccounts}
          SET current_balance = current_balance - ?,
              updated_at = ?
          WHERE id = ? AND current_balance >= ?
        ''',
          [amount, DateTime.now().toIso8601String(), fromAccountId, amount],
        );

        // Crédite le compte destination
        await txn.rawUpdate(
          '''
          UPDATE ${AppConstants.tableAccounts}
          SET current_balance = current_balance + ?,
              updated_at = ?
          WHERE id = ?
        ''',
          [amount, DateTime.now().toIso8601String(), toAccountId],
        );
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Supprime un compte
  Future<int> deleteAccount(int id) async {
    final db = await _dbService.database;

    // Vérifie s'il y a des transactions liées
    final transactionCount = await _getTransactionCountForAccount(id);
    if (transactionCount > 0) {
      throw Exception(
        'Impossible de supprimer ce compte car il est utilisé par $transactionCount transaction(s)',
      );
    }

    return await db.delete(
      AppConstants.tableAccounts,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Désactive un compte
  Future<int> deactivateAccount(int id) async {
    final db = await _dbService.database;
    return await db.update(
      AppConstants.tableAccounts,
      {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Active un compte
  Future<int> activateAccount(int id) async {
    final db = await _dbService.database;
    return await db.update(
      AppConstants.tableAccounts,
      {'is_active': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Compte le nombre de transactions pour un compte
  Future<int> _getTransactionCountForAccount(int accountId) async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.tableTransactionAccounts} WHERE account_id = ?',
      [accountId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Récupère le solde total de tous les comptes actifs
  Future<double> getTotalBalance() async {
    final db = await _dbService.database;
    final result = await db.rawQuery('''
      SELECT SUM(current_balance) as total
      FROM ${AppConstants.tableAccounts}
      WHERE is_active = 1
    ''');

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Récupère les statistiques des comptes
  Future<Map<String, dynamic>> getAccountStatistics() async {
    final accounts = await getActiveAccounts();

    double totalBalance = 0;
    double totalCash = 0;
    double totalBank = 0;
    double totalSavings = 0;
    double totalInvestment = 0;
    double totalCredit = 0;

    for (final account in accounts) {
      totalBalance += account.currentBalance;

      switch (account.accountType) {
        case 'cash':
          totalCash += account.currentBalance;
          break;
        case 'bank':
          totalBank += account.currentBalance;
          break;
        case 'savings':
          totalSavings += account.currentBalance;
          break;
        case 'investment':
          totalInvestment += account.currentBalance;
          break;
        case 'credit_card':
          totalCredit += account.currentBalance;
          break;
      }
    }

    return {
      'total_accounts': accounts.length,
      'total_balance': totalBalance,
      'total_cash': totalCash,
      'total_bank': totalBank,
      'total_savings': totalSavings,
      'total_investment': totalInvestment,
      'total_credit': totalCredit,
    };
  }

  /// Récupère l'historique des transactions d'un compte
  Future<List<Map<String, dynamic>>> getAccountTransactionHistory(
    int accountId,
  ) async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      '''
      SELECT t.*, ta.amount as account_amount
      FROM ${AppConstants.tableTransactions} t
      INNER JOIN ${AppConstants.tableTransactionAccounts} ta 
        ON t.id = ta.transaction_id
      WHERE ta.account_id = ?
      ORDER BY t.date DESC
    ''',
      [accountId],
    );

    return result;
  }

  /// Vérifie si un compte existe par nom
  Future<bool> accountExistsByName(String name, {int? excludeId}) async {
    final db = await _dbService.database;
    String whereClause = 'name = ?';
    List<dynamic> whereArgs = [name];

    if (excludeId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableAccounts,
      where: whereClause,
      whereArgs: whereArgs,
    );

    return maps.isNotEmpty;
  }
}
