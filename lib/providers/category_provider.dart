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
      _categories = await _categoryService.getAllCategories();
      _expenseCategories = _categories
          .where((cat) => cat.categoryType == 'expense' && cat.isActive)
          .toList();
      _incomeCategories = _categories
          .where((cat) => cat.categoryType == 'income' && cat.isActive)
          .toList();
    } catch (e) {
      _error = 'Erreur lors du chargement des catégories: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  /// Obtient une catégorie par son ID
  Future<CategoryModel?> getCategoryById(int id) async {
    try {
      return await _categoryService.getCategoryById(id);
    } catch (e) {
      debugPrint('Erreur lors du chargement de la catégorie: $e');
      return null;
    }
  }

  /// Obtient le nom d'une catégorie par son ID
  String getCategoryName(int id) {
    try {
      final category = _categories.firstWhere((cat) => cat.id == id);
      return category.name;
    } catch (e) {
      return 'Catégorie inconnue';
    }
  }

  /// Obtient l'icône d'une catégorie par son ID
  String getCategoryIcon(int id) {
    try {
      final category = _categories.firstWhere((cat) => cat.id == id);
      return category.icon;
    } catch (e) {
      return '📦';
    }
  }

  /// Ajoute une nouvelle catégorie
  Future<bool> addCategory(CategoryModel category) async {
    try {
      await _categoryService.createCategory(category);
      await loadCategories();
      return true;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Met à jour une catégorie
  Future<bool> updateCategory(CategoryModel category) async {
    try {
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
      _error = 'Erreur lors de la suppression: $e';
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
