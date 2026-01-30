import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

/// Provider pour la gestion des catégories
class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<CategoryModel> _categories = [];
  List<CategoryModel> _expenseCategories = [];
  List<CategoryModel> _incomeCategories = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CategoryModel> get categories => _categories;
  List<CategoryModel> get expenseCategories => _expenseCategories;
  List<CategoryModel> get incomeCategories => _incomeCategories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasCategories => _categories.isNotEmpty;

  /// Charge toutes les catégories
  Future<void> loadCategories() async {
    _setLoading(true);
    _error = null;

    try {
      _categories = await _categoryService.getActiveCategories();
      _expenseCategories = _categories
          .where((cat) => cat.categoryType == 'expense')
          .toList();
      _incomeCategories = _categories
          .where((cat) => cat.categoryType == 'income')
          .toList();
    } catch (e) {
      _error = 'Erreur lors du chargement des catégories: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  /// Obtient une catégorie par son ID
  CategoryModel? getCategoryById(int id) {
    try {
      return _categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Ajoute une nouvelle catégorie
  Future<bool> addCategory(CategoryModel category) async {
    try {
      // Vérifie si le nom existe déjà
      final exists = await _categoryService.categoryExistsByName(category.name);
      if (exists) {
        _error = 'Une catégorie avec ce nom existe déjà';
        notifyListeners();
        return false;
      }

      await _categoryService.createCategory(category);
      await loadCategories();
      return true;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout de la catégorie: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Met à jour une catégorie
  Future<bool> updateCategory(CategoryModel category) async {
    try {
      // Vérifie si le nom existe déjà (sauf pour cette catégorie)
      final exists = await _categoryService.categoryExistsByName(
        category.name,
        excludeId: category.id,
      );
      if (exists) {
        _error = 'Une catégorie avec ce nom existe déjà';
        notifyListeners();
        return false;
      }

      await _categoryService.updateCategory(category);
      await loadCategories();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Supprime une catégorie
  Future<bool> deleteCategory(int id) async {
    try {
      await _categoryService.deleteCategory(id);
      await loadCategories();
      return true;
    } catch (e) {
      _error = e.toString().contains('utilisée')
          ? e.toString()
          : 'Erreur lors de la suppression: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Active/désactive une catégorie
  Future<bool> toggleCategoryStatus(int id, bool isActive) async {
    try {
      if (isActive) {
        await _categoryService.activateCategory(id);
      } else {
        await _categoryService.deactivateCategory(id);
      }
      await loadCategories();
      return true;
    } catch (e) {
      _error = 'Erreur lors du changement de statut: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Réorganise les catégories
  Future<bool> reorderCategories(
    List<CategoryModel> reorderedCategories,
  ) async {
    try {
      final ids = reorderedCategories.map((cat) => cat.id!).toList();
      await _categoryService.reorderCategories(ids);

      // Met à jour localement
      _categories = reorderedCategories;
      _expenseCategories = _categories
          .where((cat) => cat.categoryType == 'expense')
          .toList();
      _incomeCategories = _categories
          .where((cat) => cat.categoryType == 'income')
          .toList();

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la réorganisation: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Obtient les catégories les plus utilisées
  Future<List<Map<String, dynamic>>> getMostUsedCategories({
    int limit = 5,
  }) async {
    try {
      return await _categoryService.getMostUsedCategories(limit: limit);
    } catch (e) {
      debugPrint('Erreur lors du chargement des catégories populaires: $e');
      return [];
    }
  }

  /// Obtient les statistiques par catégorie
  Future<List<Map<String, dynamic>>> getCategoryStatistics(
    DateTime start,
    DateTime end,
  ) async {
    try {
      return await _categoryService.getCategoryStatistics(start, end);
    } catch (e) {
      debugPrint('Erreur lors du chargement des statistiques: $e');
      return [];
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
