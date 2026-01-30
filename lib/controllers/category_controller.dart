import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../providers/category_provider.dart';
import '../utils/validators.dart';

/// Controller pour la gestion des catégories
class CategoryController {
  final CategoryProvider categoryProvider;

  CategoryController({required this.categoryProvider});

  // Controllers de formulaire
  final nameController = TextEditingController();

  // Données du formulaire
  String selectedIcon = '📦';
  String selectedColor = '#AAB7B8';
  String categoryType = 'expense';
  bool isActive = true;

  // Liste d'icônes disponibles
  static const List<String> availableIcons = [
    '🍔',
    '🚗',
    '🏠',
    '💡',
    '🛍️',
    '🎬',
    '🏥',
    '📚',
    '📦',
    '💰',
    '💼',
    '📈',
    '🎁',
    '↪️',
    '📥',
    '✈️',
    '☕',
    '🎮',
    '💊',
    '⚡',
    '🏋️',
    '🎵',
    '📱',
    '💳',
  ];

  // Liste de couleurs disponibles
  static const List<String> availableColors = [
    '#FF6B6B',
    '#4ECDC4',
    '#45B7D1',
    '#96CEB4',
    '#FFEAA7',
    '#DDA0DD',
    '#F7DC6F',
    '#BB8FCE',
    '#AAB7B8',
    '#2ECC71',
    '#3498DB',
    '#9B59B6',
    '#E74C3C',
    '#F39C12',
    '#95A5A6',
    '#E67E22',
  ];

  /// Initialise le formulaire pour une nouvelle catégorie
  void initializeForNew({String? defaultType}) {
    clearForm();
    if (defaultType != null) {
      categoryType = defaultType;
      _setDefaultIconAndColor();
    }
  }

  /// Initialise le formulaire pour une édition
  void initializeForEdit(CategoryModel category) {
    nameController.text = category.name;
    selectedIcon = category.icon;
    selectedColor = category.color;
    categoryType = category.categoryType;
    isActive = category.isActive;
  }

  /// Valide le formulaire
  Map<String, String?> validateForm() {
    final errors = <String, String?>{};

    errors['name'] = Validators.categoryName(nameController.text);

    return errors..removeWhere((key, value) => value == null);
  }

  /// Crée une catégorie depuis le formulaire
  CategoryModel createCategory({int? id}) {
    return CategoryModel(
      id: id,
      name: nameController.text.trim(),
      icon: selectedIcon,
      color: selectedColor,
      categoryType: categoryType,
      isActive: isActive,
      isDefault: false,
    );
  }

  /// Sauvegarde la catégorie
  Future<bool> saveCategory({int? id}) async {
    final errors = validateForm();
    if (errors.isNotEmpty) {
      return false;
    }

    final category = createCategory(id: id);

    if (id == null) {
      return await categoryProvider.addCategory(category);
    } else {
      return await categoryProvider.updateCategory(category);
    }
  }

  /// Supprime une catégorie
  Future<bool> deleteCategory(int id) async {
    return await categoryProvider.deleteCategory(id);
  }

  /// Active/désactive une catégorie
  Future<bool> toggleCategoryStatus(int id, bool status) async {
    return await categoryProvider.toggleCategoryStatus(id, status);
  }

  /// Change le type de catégorie
  void setCategoryType(String type) {
    categoryType = type;
    _setDefaultIconAndColor();
  }

  /// Sélectionne une icône
  void selectIcon(String icon) {
    selectedIcon = icon;
  }

  /// Sélectionne une couleur
  void selectColor(String color) {
    selectedColor = color;
  }

  /// Active/désactive la catégorie
  void toggleActive(bool value) {
    isActive = value;
  }

  /// Définit l'icône et la couleur par défaut selon le type
  void _setDefaultIconAndColor() {
    if (categoryType == 'expense') {
      selectedIcon = '📦';
      selectedColor = '#AAB7B8';
    } else {
      selectedIcon = '💰';
      selectedColor = '#2ECC71';
    }
  }

  /// Obtient une couleur aléatoire
  String getRandomColor() {
    availableColors.shuffle();
    return availableColors.first;
  }

  /// Obtient une icône aléatoire
  String getRandomIcon() {
    availableIcons.shuffle();
    return availableIcons.first;
  }

  /// Nettoie le formulaire
  void clearForm() {
    nameController.clear();
    selectedIcon = '📦';
    selectedColor = '#AAB7B8';
    categoryType = 'expense';
    isActive = true;
  }

  /// Dispose les controllers
  void dispose() {
    nameController.dispose();
  }
}
