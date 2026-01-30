import 'package:sqflite/sqflite.dart';
import '../models/category_model.dart';
import '../utils/constants.dart';
import 'database_service.dart';

/// Service de gestion des catégories
class CategoryService {
  final DatabaseService _dbService = DatabaseService();

  /// Crée une nouvelle catégorie
  Future<int> createCategory(CategoryModel category) async {
    final db = await _dbService.database;
    return await db.insert(
      AppConstants.tableCategories,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Récupère toutes les catégories
  Future<List<CategoryModel>> getAllCategories() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableCategories,
      orderBy: 'sort_order ASC',
    );

    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  /// Récupère les catégories actives
  Future<List<CategoryModel>> getActiveCategories() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableCategories,
      where: 'is_active = 1',
      orderBy: 'sort_order ASC',
    );

    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  /// Récupère une catégorie par son ID
  Future<CategoryModel?> getCategoryById(int id) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableCategories,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return CategoryModel.fromMap(maps.first);
  }

  /// Récupère les catégories par type
  Future<List<CategoryModel>> getCategoriesByType(String type) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableCategories,
      where: 'category_type = ? AND is_active = 1',
      whereArgs: [type],
      orderBy: 'sort_order ASC',
    );

    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  /// Récupère les catégories de dépenses
  Future<List<CategoryModel>> getExpenseCategories() async {
    return getCategoriesByType('expense');
  }

  /// Récupère les catégories de revenus
  Future<List<CategoryModel>> getIncomeCategories() async {
    return getCategoriesByType('income');
  }

  /// Met à jour une catégorie
  Future<int> updateCategory(CategoryModel category) async {
    final db = await _dbService.database;
    return await db.update(
      AppConstants.tableCategories,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Supprime une catégorie
  Future<int> deleteCategory(int id) async {
    final db = await _dbService.database;

    // Vérifie s'il y a des transactions liées
    final transactionCount = await _getTransactionCountForCategory(id);
    if (transactionCount > 0) {
      throw Exception(
        'Impossible de supprimer cette catégorie car elle est utilisée par $transactionCount transaction(s)',
      );
    }

    return await db.delete(
      AppConstants.tableCategories,
      where: 'id = ? AND is_default = 0',
      whereArgs: [id],
    );
  }

  /// Désactive une catégorie
  Future<int> deactivateCategory(int id) async {
    final db = await _dbService.database;
    return await db.update(
      AppConstants.tableCategories,
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Active une catégorie
  Future<int> activateCategory(int id) async {
    final db = await _dbService.database;
    return await db.update(
      AppConstants.tableCategories,
      {'is_active': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Réordonne les catégories
  Future<void> reorderCategories(List<int> categoryIds) async {
    final db = await _dbService.database;
    await db.transaction((txn) async {
      for (var i = 0; i < categoryIds.length; i++) {
        await txn.update(
          AppConstants.tableCategories,
          {'sort_order': i},
          where: 'id = ?',
          whereArgs: [categoryIds[i]],
        );
      }
    });
  }

  /// Compte le nombre de transactions pour une catégorie
  Future<int> _getTransactionCountForCategory(int categoryId) async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.tableTransactions} WHERE category_id = ?',
      [categoryId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Récupère les catégories les plus utilisées
  Future<List<Map<String, dynamic>>> getMostUsedCategories({
    int limit = 5,
  }) async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      '''
      SELECT 
        c.*,
        COUNT(t.id) as usage_count,
        SUM(t.amount) as total_amount
      FROM ${AppConstants.tableCategories} c
      LEFT JOIN ${AppConstants.tableTransactions} t ON c.id = t.category_id
      WHERE c.is_active = 1
      GROUP BY c.id
      ORDER BY usage_count DESC
      LIMIT ?
    ''',
      [limit],
    );

    return result;
  }

  /// Vérifie si une catégorie existe par nom
  Future<bool> categoryExistsByName(String name, {int? excludeId}) async {
    final db = await _dbService.database;
    String whereClause = 'name = ?';
    List<dynamic> whereArgs = [name];

    if (excludeId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableCategories,
      where: whereClause,
      whereArgs: whereArgs,
    );

    return maps.isNotEmpty;
  }

  /// Récupère les statistiques par catégorie pour une période
  Future<List<Map<String, dynamic>>> getCategoryStatistics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      '''
      SELECT 
        c.id,
        c.name,
        c.icon,
        c.color,
        c.category_type,
        COUNT(t.id) as transaction_count,
        SUM(t.amount) as total_amount,
        AVG(t.amount) as average_amount
      FROM ${AppConstants.tableCategories} c
      LEFT JOIN ${AppConstants.tableTransactions} t 
        ON c.id = t.category_id 
        AND t.date BETWEEN ? AND ?
      WHERE c.is_active = 1
      GROUP BY c.id
      ORDER BY total_amount DESC
    ''',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    return result;
  }
}
