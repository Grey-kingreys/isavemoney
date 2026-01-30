import 'package:flutter/foundation.dart';
import '../models/budget_model.dart';
import '../services/budget_service.dart';

/// Provider pour la gestion des budgets
class BudgetProvider with ChangeNotifier {
  final BudgetService _budgetService = BudgetService();

  List<BudgetModel> _budgets = [];
  List<BudgetModel> _activeBudgets = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _summary;

  // Getters
  List<BudgetModel> get budgets => _budgets;
  List<BudgetModel> get activeBudgets => _activeBudgets;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasBudgets => _budgets.isNotEmpty;
  Map<String, dynamic>? get summary => _summary;

  /// Charge tous les budgets
  Future<void> loadBudgets() async {
    _setLoading(true);
    _error = null;

    try {
      _budgets = await _budgetService.getAllBudgets();
      _activeBudgets = await _budgetService.getActiveBudgets();
      await loadSummary();
    } catch (e) {
      _error = 'Erreur lors du chargement des budgets: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  /// Charge le résumé des budgets
  Future<void> loadSummary() async {
    try {
      _summary = await _budgetService.getBudgetSummary();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du chargement du résumé: $e');
    }
  }

  /// Obtient un budget par ID
  Future<BudgetModel?> getBudgetById(int id) async {
    try {
      return await _budgetService.getBudgetById(id);
    } catch (e) {
      debugPrint('Erreur lors du chargement du budget: $e');
      return null;
    }
  }

  /// Obtient le budget actif pour une catégorie
  Future<BudgetModel?> getBudgetForCategory(int categoryId) async {
    try {
      return await _budgetService.getActiveBudgetForCategory(categoryId);
    } catch (e) {
      debugPrint('Erreur lors du chargement du budget: $e');
      return null;
    }
  }

  /// Ajoute un nouveau budget
  Future<bool> addBudget(BudgetModel budget) async {
    try {
      await _budgetService.createBudget(budget);
      await loadBudgets();
      return true;
    } catch (e) {
      _error = e.toString().contains('existe déjà')
          ? 'Un budget actif existe déjà pour cette catégorie'
          : 'Erreur lors de l\'ajout du budget: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Met à jour un budget
  Future<bool> updateBudget(BudgetModel budget) async {
    try {
      await _budgetService.updateBudget(budget);
      await loadBudgets();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Supprime un budget
  Future<bool> deleteBudget(int id) async {
    try {
      await _budgetService.deleteBudget(id);
      await loadBudgets();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Active/désactive un budget
  Future<bool> toggleBudgetStatus(int id, bool isActive) async {
    try {
      if (isActive) {
        await _budgetService.activateBudget(id);
      } else {
        await _budgetService.deactivateBudget(id);
      }
      await loadBudgets();
      return true;
    } catch (e) {
      _error = 'Erreur lors du changement de statut: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Récupère les budgets dépassés
  Future<List<BudgetModel>> getExceededBudgets() async {
    try {
      return await _budgetService.getExceededBudgets();
    } catch (e) {
      debugPrint('Erreur lors du chargement: $e');
      return [];
    }
  }

  /// Récupère les budgets proches du seuil
  Future<List<BudgetModel>> getBudgetsNearThreshold() async {
    try {
      return await _budgetService.getBudgetsNearThreshold();
    } catch (e) {
      debugPrint('Erreur lors du chargement: $e');
      return [];
    }
  }

  /// Récupère les statistiques des budgets
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      return await _budgetService.getBudgetStatistics();
    } catch (e) {
      debugPrint('Erreur lors du chargement des statistiques: $e');
      return {
        'total_budgets': 0,
        'exceeded_budgets': 0,
        'near_threshold_budgets': 0,
        'total_limit': 0.0,
        'total_spent': 0.0,
        'total_remaining': 0.0,
        'percentage_used': 0.0,
      };
    }
  }

  /// Récupère les budgets avec détails des catégories
  Future<List<Map<String, dynamic>>> getBudgetsWithCategories() async {
    try {
      return await _budgetService.getBudgetsWithCategories();
    } catch (e) {
      debugPrint('Erreur lors du chargement: $e');
      return [];
    }
  }

  /// Réinitialise les montants dépensés pour une période
  Future<bool> resetPeriodBudgets(String periodType) async {
    try {
      await _budgetService.resetPeriodBudgets(periodType);
      await loadBudgets();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la réinitialisation: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Met à jour le montant dépensé d'un budget
  Future<void> updateBudgetSpent(int categoryId, double amount) async {
    try {
      await _budgetService.updateBudgetSpent(categoryId, amount);
      await loadBudgets();
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour du budget: $e');
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
