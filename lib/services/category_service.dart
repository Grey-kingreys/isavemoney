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
    return await db.delete(
      AppConstants.tableCategories,
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

  /// Compte le nombre de catégories
  Future<int> getCategoryCount() async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.tableCategories}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Vérifie si une catégorie existe
  Future<bool> categoryExists(String name, String type) async {
    final db = await _dbService.database;
    final result = await db.query(
      AppConstants.tableCategories,
      where: 'name = ? AND category_type = ?',
      whereArgs: [name, type],
    );
    return result.isNotEmpty;
  }
}
