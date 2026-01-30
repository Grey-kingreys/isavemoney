import 'package:flutter/material.dart';
import '../models/budget_model.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import '../utils/validators.dart';

/// Controller pour la gestion des budgets
class BudgetController {
  final BudgetProvider budgetProvider;
  final CategoryProvider categoryProvider;

  BudgetController({
    required this.budgetProvider,
    required this.categoryProvider,
  });

  // Controllers de formulaire
  final amountController = TextEditingController();
  final thresholdController = TextEditingController();

  // Données du formulaire
  int? selectedCategoryId;
  String periodType = 'monthly';
  DateTime startDate = DateTime.now();
  DateTime? endDate;
  bool isActive = true;
  bool notificationsEnabled = true;
  double notificationThreshold = 80.0;

  /// Initialise le formulaire pour un nouveau budget
  void initializeForNew() {
    clearForm();
  }

  /// Initialise le formulaire pour une édition
  void initializeForEdit(BudgetModel budget) {
    amountController.text = budget.amountLimit.toString();
    thresholdController.text = budget.notificationThreshold.toString();
    selectedCategoryId = budget.categoryId;
    periodType = budget.periodType;
    startDate = budget.startDate;
    endDate = budget.endDate;
    isActive = budget.isActive;
    notificationsEnabled = budget.notificationsEnabled;
    notificationThreshold = budget.notificationThreshold;
  }

  /// Valide le formulaire
  Map<String, String?> validateForm() {
    final errors = <String, String?>{};

    errors['amount'] = Validators.budgetLimit(amountController.text);
    errors['date'] = Validators.date(startDate);

    if (selectedCategoryId == null) {
      errors['category'] = 'Veuillez sélectionner une catégorie';
    }

    // Valide le seuil
    final threshold = double.tryParse(thresholdController.text);
    if (threshold == null || threshold < 0 || threshold > 100) {
      errors['threshold'] = 'Le seuil doit être entre 0 et 100';
    }

    return errors..removeWhere((key, value) => value == null);
  }

  /// Crée un budget depuis le formulaire
  BudgetModel createBudget({int? id}) {
    final amount = double.parse(
      amountController.text
          .replaceAll(',', '.')
          .replaceAll(RegExp(r'[^\d.]'), ''),
    );

    final threshold = double.parse(
      thresholdController.text.replaceAll(',', '.'),
    );

    return BudgetModel(
      id: id,
      categoryId: selectedCategoryId!,
      amountLimit: amount,
      periodType: periodType,
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
      notificationsEnabled: notificationsEnabled,
      notificationThreshold: threshold,
    );
  }

  /// Sauvegarde le budget
  Future<bool> saveBudget({int? id}) async {
    final errors = validateForm();
    if (errors.isNotEmpty) {
      return false;
    }

    final budget = createBudget(id: id);

    if (id == null) {
      return await budgetProvider.addBudget(budget);
    } else {
      return await budgetProvider.updateBudget(budget);
    }
  }

  /// Supprime un budget
  Future<bool> deleteBudget(int id) async {
    return await budgetProvider.deleteBudget(id);
  }

  /// Active/désactive un budget
  Future<bool> toggleBudgetStatus(int id, bool status) async {
    return await budgetProvider.toggleBudgetStatus(id, status);
  }

  /// Sélectionne une catégorie
  void selectCategory(int categoryId) {
    selectedCategoryId = categoryId;
  }

  /// Change le type de période
  void setPeriodType(String type) {
    periodType = type;
    _updateDatesForPeriod();
  }

  /// Change la date de début
  void setStartDate(DateTime date) {
    startDate = date;
    _updateDatesForPeriod();
  }

  /// Change la date de fin
  void setEndDate(DateTime? date) {
    endDate = date;
  }

  /// Active/désactive le budget
  void toggleActive(bool value) {
    isActive = value;
  }

  /// Active/désactive les notifications
  void toggleNotifications(bool value) {
    notificationsEnabled = value;
  }

  /// Change le seuil de notification
  void setNotificationThreshold(double threshold) {
    notificationThreshold = threshold;
    thresholdController.text = threshold.toStringAsFixed(0);
  }

  /// Met à jour les dates selon le type de période
  void _updateDatesForPeriod() {
    switch (periodType) {
      case 'daily':
        endDate = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          23,
          59,
          59,
        );
        break;
      case 'weekly':
        endDate = startDate.add(
          const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
        );
        break;
      case 'monthly':
        endDate = DateTime(startDate.year, startDate.month + 1, 0, 23, 59, 59);
        break;
      case 'yearly':
        endDate = DateTime(startDate.year, 12, 31, 23, 59, 59);
        break;
      default:
        endDate = null;
    }
  }

  /// Obtient le nom de la période
  String getPeriodName() {
    switch (periodType) {
      case 'daily':
        return 'Journalier';
      case 'weekly':
        return 'Hebdomadaire';
      case 'monthly':
        return 'Mensuel';
      case 'yearly':
        return 'Annuel';
      default:
        return periodType;
    }
  }

  /// Obtient les catégories de dépenses
  List<dynamic> getExpenseCategories() {
    return categoryProvider.expenseCategories;
  }

  /// Vérifie si un budget existe pour la catégorie
  Future<bool> hasBudgetForCategory(int categoryId) async {
    final budget = await budgetProvider.getBudgetForCategory(categoryId);
    return budget != null;
  }

  /// Nettoie le formulaire
  void clearForm() {
    amountController.clear();
    thresholdController.text = '80';
    selectedCategoryId = null;
    periodType = 'monthly';
    startDate = DateTime.now();
    endDate = null;
    isActive = true;
    notificationsEnabled = true;
    notificationThreshold = 80.0;
  }

  /// Dispose les controllers
  void dispose() {
    amountController.dispose();
    thresholdController.dispose();
  }
}
