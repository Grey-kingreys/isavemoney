import 'package:sqflite/sqflite.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';
import 'database_service.dart';

/// Service de gestion des transactions
class TransactionService {
  final DatabaseService _dbService = DatabaseService();

  /// Crée une nouvelle transaction
  Future<int> createTransaction(TransactionModel transaction) async {
    final db = await _dbService.database;
    return await db.insert(
      AppConstants.tableTransactions,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Récupère toutes les transactions
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableTransactions,
      orderBy: 'date DESC',
    );

    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  /// Récupère une transaction par son ID
  Future<TransactionModel?> getTransactionById(int id) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableTransactions,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return TransactionModel.fromMap(maps.first);
  }

  /// Récupère les transactions par type
  Future<List<TransactionModel>> getTransactionsByType(String type) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableTransactions,
      where: 'transaction_type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );

    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  /// Récupère les transactions par catégorie
  Future<List<TransactionModel>> getTransactionsByCategory(
    int categoryId,
  ) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableTransactions,
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'date DESC',
    );

    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  /// Récupère les transactions dans une période
  Future<List<TransactionModel>> getTransactionsByPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableTransactions,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date DESC',
    );

    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  /// Récupère les transactions du mois en cours
  Future<List<TransactionModel>> getCurrentMonthTransactions() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return getTransactionsByPeriod(startOfMonth, endOfMonth);
  }

  /// Récupère les revenus d'une période
  Future<double> getIncomeByPeriod(DateTime startDate, DateTime endDate) async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(amount) as total
      FROM ${AppConstants.tableTransactions}
      WHERE transaction_type = 'income'
        AND date BETWEEN ? AND ?
    ''',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Récupère les dépenses d'une période
  Future<double> getExpenseByPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(amount) as total
      FROM ${AppConstants.tableTransactions}
      WHERE transaction_type = 'expense'
        AND date BETWEEN ? AND ?
    ''',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Récupère le solde d'une période
  Future<double> getBalanceByPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final income = await getIncomeByPeriod(startDate, endDate);
    final expense = await getExpenseByPeriod(startDate, endDate);
    return income - expense;
  }

  /// Récupère les dépenses par catégorie pour une période
  Future<Map<int, double>> getExpensesByCategoryForPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      '''
      SELECT category_id, SUM(amount) as total
      FROM ${AppConstants.tableTransactions}
      WHERE transaction_type = 'expense'
        AND date BETWEEN ? AND ?
      GROUP BY category_id
    ''',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    final Map<int, double> expenses = {};
    for (final row in result) {
      expenses[row['category_id'] as int] = (row['total'] as num).toDouble();
    }
    return expenses;
  }

  /// Recherche des transactions
  Future<List<TransactionModel>> searchTransactions(String query) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableTransactions,
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'date DESC',
    );

    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  /// Met à jour une transaction
  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await _dbService.database;
    return await db.update(
      AppConstants.tableTransactions,
      transaction.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  /// Supprime une transaction
  Future<int> deleteTransaction(int id) async {
    final db = await _dbService.database;
    return await db.delete(
      AppConstants.tableTransactions,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Supprime toutes les transactions
  Future<int> deleteAllTransactions() async {
    final db = await _dbService.database;
    return await db.delete(AppConstants.tableTransactions);
  }

  /// Compte le nombre total de transactions
  Future<int> getTransactionCount() async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.tableTransactions}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Récupère les statistiques globales
  Future<Map<String, dynamic>> getGlobalStatistics() async {
    final db = await _dbService.database;
    final result = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN transaction_type = 'income' THEN amount ELSE 0 END) as total_income,
        SUM(CASE WHEN transaction_type = 'expense' THEN amount ELSE 0 END) as total_expense,
        COUNT(*) as total_transactions
      FROM ${AppConstants.tableTransactions}
    ''');

    final row = result.first;
    final totalIncome = (row['total_income'] as num?)?.toDouble() ?? 0.0;
    final totalExpense = (row['total_expense'] as num?)?.toDouble() ?? 0.0;

    return {
      'total_income': totalIncome,
      'total_expense': totalExpense,
      'total_transactions': row['total_transactions'] as int,
      'net_balance': totalIncome - totalExpense,
    };
  }

  /// Récupère les transactions récurrentes
  Future<List<TransactionModel>> getRecurringTransactions() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableTransactions,
      where: 'is_recurring = 1',
      orderBy: 'next_occurrence ASC',
    );

    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  /// Récupère les dernières transactions (limite)
  Future<List<TransactionModel>> getRecentTransactions({int limit = 10}) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableTransactions,
      orderBy: 'date DESC',
      limit: limit,
    );

    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }
}
