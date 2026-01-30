import 'package:sqflite/sqflite.dart';
import '../models/budget_model.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart' as app_date_utils;
import 'database_service.dart';

/// Service de gestion des budgets
class BudgetService {
  final DatabaseService _dbService = DatabaseService();

  /// Crée un nouveau budget
  Future<int> createBudget(BudgetModel budget) async {
    final db = await _dbService.database;

    // Vérifie s'il existe déjà un budget actif pour cette catégorie et période
    final existing = await getActiveBudgetForCategory(budget.categoryId);
    if (existing != null && existing.periodType == budget.periodType) {
      throw Exception(
        'Un budget actif existe déjà pour cette catégorie et cette période',
      );
    }

    return await db.insert(
      AppConstants.tableBudgets,
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Récupère tous les budgets
  Future<List<BudgetModel>> getAllBudgets() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableBudgets,
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => BudgetModel.fromMap(map)).toList();
  }

  /// Récupère les budgets actifs
  Future<List<BudgetModel>> getActiveBudgets() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableBudgets,
      where: 'is_active = 1',
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => BudgetModel.fromMap(map)).toList();
  }

  /// Récupère un budget par son ID
  Future<BudgetModel?> getBudgetById(int id) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableBudgets,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return BudgetModel.fromMap(maps.first);
  }

  /// Récupère le budget actif pour une catégorie
  Future<BudgetModel?> getActiveBudgetForCategory(int categoryId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableBudgets,
      where: 'category_id = ? AND is_active = 1',
      whereArgs: [categoryId],
    );

    if (maps.isEmpty) return null;
    return BudgetModel.fromMap(maps.first);
  }

  /// Récupère les budgets par type de période
  Future<List<BudgetModel>> getBudgetsByPeriodType(String periodType) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableBudgets,
      where: 'period_type = ? AND is_active = 1',
      whereArgs: [periodType],
    );

    return maps.map((map) => BudgetModel.fromMap(map)).toList();
  }

  /// Met à jour un budget
  Future<int> updateBudget(BudgetModel budget) async {
    final db = await _dbService.database;
    return await db.update(
      AppConstants.tableBudgets,
      budget.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  /// Met à jour le montant dépensé d'un budget
  Future<void> updateBudgetSpent(int categoryId, double amount) async {
    final budget = await getActiveBudgetForCategory(categoryId);
    if (budget == null) return;

    final now = DateTime.now();
    final (startDate, endDate) = _getPeriodDates(budget.periodType, now);

    // Calcule le total dépensé pour la période
    final db = await _dbService.database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(amount) as total
      FROM ${AppConstants.tableTransactions}
      WHERE category_id = ?
        AND transaction_type = 'expense'
        AND date BETWEEN ? AND ?
    ''',
      [categoryId, startDate.toIso8601String(), endDate.toIso8601String()],
    );

    final totalSpent = (result.first['total'] as num?)?.toDouble() ?? 0.0;

    await updateBudget(budget.copyWith(currentSpent: totalSpent));
  }

  /// Récupère les dates de début et fin pour un type de période
  (DateTime, DateTime) _getPeriodDates(String periodType, DateTime date) {
    switch (periodType) {
      case 'daily':
        return (
          app_date_utils.DateUtils.getDayStart(date),
          app_date_utils.DateUtils.getDayEnd(date),
        );
      case 'weekly':
        return (
          app_date_utils.DateUtils.getWeekStart(date),
          app_date_utils.DateUtils.getWeekEnd(date),
        );
      case 'monthly':
        return (
          app_date_utils.DateUtils.getMonthStart(date),
          app_date_utils.DateUtils.getMonthEnd(date),
        );
      case 'yearly':
        return (
          app_date_utils.DateUtils.getYearStart(date),
          app_date_utils.DateUtils.getYearEnd(date),
        );
      default:
        return (
          app_date_utils.DateUtils.getMonthStart(date),
          app_date_utils.DateUtils.getMonthEnd(date),
        );
    }
  }

  /// Supprime un budget
  Future<int> deleteBudget(int id) async {
    final db = await _dbService.database;
    return await db.delete(
      AppConstants.tableBudgets,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Active un budget
  Future<int> activateBudget(int id) async {
    final db = await _dbService.database;
    return await db.update(
      AppConstants.tableBudgets,
      {'is_active': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Désactive un budget
  Future<int> deactivateBudget(int id) async {
    final db = await _dbService.database;
    return await db.update(
      AppConstants.tableBudgets,
      {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Récupère les budgets dépassés
  Future<List<BudgetModel>> getExceededBudgets() async {
    final budgets = await getActiveBudgets();
    return budgets.where((budget) => budget.isExceeded).toList();
  }

  /// Récupère les budgets proches du seuil d'alerte
  Future<List<BudgetModel>> getBudgetsNearThreshold() async {
    final budgets = await getActiveBudgets();
    return budgets
        .where((budget) => budget.isThresholdReached && !budget.isExceeded)
        .toList();
  }

  /// Récupère les statistiques des budgets
  Future<Map<String, dynamic>> getBudgetStatistics() async {
    final budgets = await getActiveBudgets();

    int totalBudgets = budgets.length;
    int exceededBudgets = budgets.where((b) => b.isExceeded).length;
    int nearThresholdBudgets = budgets
        .where((b) => b.isThresholdReached && !b.isExceeded)
        .length;

    double totalLimit = budgets.fold(0.0, (sum, b) => sum + b.amountLimit);
    double totalSpent = budgets.fold(0.0, (sum, b) => sum + b.currentSpent);
    double totalRemaining = budgets.fold(
      0.0,
      (sum, b) => sum + b.remainingAmount,
    );

    return {
      'total_budgets': totalBudgets,
      'exceeded_budgets': exceededBudgets,
      'near_threshold_budgets': nearThresholdBudgets,
      'total_limit': totalLimit,
      'total_spent': totalSpent,
      'total_remaining': totalRemaining,
      'percentage_used': totalLimit > 0 ? (totalSpent / totalLimit) * 100 : 0,
    };
  }

  /// Récupère les budgets avec les détails des catégories
  Future<List<Map<String, dynamic>>> getBudgetsWithCategories() async {
    final db = await _dbService.database;
    final result = await db.rawQuery('''
      SELECT 
        b.*,
        c.name as category_name,
        c.icon as category_icon,
        c.color as category_color
      FROM ${AppConstants.tableBudgets} b
      INNER JOIN ${AppConstants.tableCategories} c ON b.category_id = c.id
      WHERE b.is_active = 1
      ORDER BY b.created_at DESC
    ''');

    return result;
  }

  /// Réinitialise les montants dépensés pour une nouvelle période
  Future<void> resetPeriodBudgets(String periodType) async {
    final db = await _dbService.database;
    await db.update(
      AppConstants.tableBudgets,
      {'current_spent': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'period_type = ? AND is_active = 1',
      whereArgs: [periodType],
    );
  }

  /// Récupère le résumé des budgets pour le tableau de bord
  Future<Map<String, dynamic>> getBudgetSummary() async {
    final budgets = await getActiveBudgets();

    if (budgets.isEmpty) {
      return {
        'has_budgets': false,
        'total_limit': 0.0,
        'total_spent': 0.0,
        'total_remaining': 0.0,
        'percentage_used': 0.0,
        'exceeded_count': 0,
        'warning_count': 0,
      };
    }

    double totalLimit = 0;
    double totalSpent = 0;
    int exceededCount = 0;
    int warningCount = 0;

    for (final budget in budgets) {
      if (budget.isValidToday) {
        totalLimit += budget.amountLimit;
        totalSpent += budget.currentSpent;

        if (budget.isExceeded) {
          exceededCount++;
        } else if (budget.isThresholdReached) {
          warningCount++;
        }
      }
    }

    return {
      'has_budgets': true,
      'total_limit': totalLimit,
      'total_spent': totalSpent,
      'total_remaining': totalLimit - totalSpent,
      'percentage_used': totalLimit > 0 ? (totalSpent / totalLimit) * 100 : 0,
      'exceeded_count': exceededCount,
      'warning_count': warningCount,
    };
  }
}
