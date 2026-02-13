import 'package:flutter/foundation.dart';
import '../models/savings_goal_model.dart';
import '../services/savings_goal_service.dart';
import '../services/notification_service.dart';

/// Provider pour la gestion des objectifs d'épargne
class SavingsGoalProvider with ChangeNotifier {
  final SavingsGoalService _savingsGoalService = SavingsGoalService();
  final NotificationService _notificationService = NotificationService();

  List<SavingsGoalModel> _goals = [];
  List<SavingsGoalModel> _activeGoals = [];
  List<SavingsGoalModel> _completedGoals = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _statistics;
  Map<String, dynamic>? _recommendations;

  // Getters
  List<SavingsGoalModel> get goals => _goals;
  List<SavingsGoalModel> get activeGoals => _activeGoals;
  List<SavingsGoalModel> get completedGoals => _completedGoals;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasGoals => _goals.isNotEmpty;
  Map<String, dynamic>? get statistics => _statistics;
  Map<String, dynamic>? get recommendations => _recommendations;

  /// Charge tous les objectifs
  Future<void> loadSavingsGoals() async {
    _setLoading(true);
    _error = null;

    try {
      _goals = await _savingsGoalService.getAllSavingsGoals();
      _activeGoals = await _savingsGoalService.getActiveSavingsGoals();
      _completedGoals = await _savingsGoalService.getCompletedSavingsGoals();
      await loadStatistics();
      await loadRecommendations();
    } catch (e) {
      _error = 'Erreur lors du chargement des objectifs: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  /// Charge les statistiques
  Future<void> loadStatistics() async {
    try {
      _statistics = await _savingsGoalService.getSavingsGoalStatistics();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du chargement des statistiques: $e');
    }
  }

  /// Charge les recommandations
  Future<void> loadRecommendations() async {
    try {
      _recommendations = await _savingsGoalService.getSavingsRecommendations();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du chargement des recommandations: $e');
    }
  }

  /// Obtient un objectif par ID
  Future<SavingsGoalModel?> getSavingsGoalById(int id) async {
    try {
      return await _savingsGoalService.getSavingsGoalById(id);
    } catch (e) {
      debugPrint('Erreur lors du chargement de l\'objectif: $e');
      return null;
    }
  }

  /// Ajoute un nouvel objectif
  Future<bool> addSavingsGoal(SavingsGoalModel goal) async {
    try {
      // Vérifie si le nom existe déjà
      final exists = await _savingsGoalService.goalExistsByName(goal.name);
      if (exists) {
        _error = 'Un objectif avec ce nom existe déjà';
        notifyListeners();
        return false;
      }

      await _savingsGoalService.createSavingsGoal(goal);
      await loadSavingsGoals();
      return true;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout de l\'objectif: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Met à jour un objectif
  Future<bool> updateSavingsGoal(SavingsGoalModel goal) async {
    try {
      // Vérifie si le nom existe déjà (sauf pour cet objectif)
      final exists = await _savingsGoalService.goalExistsByName(
        goal.name,
        excludeId: goal.id,
      );
      if (exists) {
        _error = 'Un objectif avec ce nom existe déjà';
        notifyListeners();
        return false;
      }

      await _savingsGoalService.updateSavingsGoal(goal);
      await loadSavingsGoals();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Supprime un objectif
  Future<bool> deleteSavingsGoal(int id) async {
    try {
      await _savingsGoalService.deleteSavingsGoal(id);
      await loadSavingsGoals();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Ajoute un montant à un objectif
  Future<bool> addToSavingsGoal(
    int goalId,
    double amount, {
    bool showNotification = true,
  }) async {
    try {
      final goalBefore = await getSavingsGoalById(goalId);
      if (goalBefore == null) return false;

      await _savingsGoalService.addToSavingsGoal(goalId, amount);

      final goalAfter = await getSavingsGoalById(goalId);
      if (goalAfter == null) return false;

      // Notifications
      if (showNotification) {
        // Objectif atteint
        if (!goalBefore.isReached && goalAfter.isReached) {
          await _notificationService.notifySavingsGoalReached(
            goalName: goalAfter.name,
            targetAmount: goalAfter.targetAmount,
          );
        }
        // Proche de l'objectif (90%+)
        else if (goalAfter.progressPercentage >= 90 &&
            goalBefore.progressPercentage < 90) {
          await _notificationService.notifySavingsGoalNearTarget(
            goalName: goalAfter.name,
            targetAmount: goalAfter.targetAmount,
            currentAmount: goalAfter.currentAmount,
            percentage: goalAfter.progressPercentage,
          );
        }
      }

      await loadSavingsGoals();
      return true;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Retire un montant d'un objectif
  Future<bool> subtractFromSavingsGoal(int goalId, double amount) async {
    try {
      await _savingsGoalService.subtractFromSavingsGoal(goalId, amount);
      await loadSavingsGoals();
      return true;
    } catch (e) {
      _error = 'Erreur lors du retrait: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Marque un objectif comme complété
  Future<bool> markAsCompleted(int id) async {
    try {
      await _savingsGoalService.markAsCompleted(id);
      await loadSavingsGoals();
      return true;
    } catch (e) {
      _error = 'Erreur: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Réactive un objectif
  Future<bool> markAsIncomplete(int id) async {
    try {
      await _savingsGoalService.markAsIncomplete(id);
      await loadSavingsGoals();
      return true;
    } catch (e) {
      _error = 'Erreur: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Obtient les objectifs en retard
  Future<List<SavingsGoalModel>> getOverdueGoals() async {
    try {
      return await _savingsGoalService.getOverdueGoals();
    } catch (e) {
      debugPrint('Erreur lors du chargement: $e');
      return [];
    }
  }

  /// Obtient les objectifs proches de l'échéance
  Future<List<SavingsGoalModel>> getUpcomingGoals({int daysAhead = 30}) async {
    try {
      return await _savingsGoalService.getUpcomingGoals(daysAhead: daysAhead);
    } catch (e) {
      debugPrint('Erreur lors du chargement: $e');
      return [];
    }
  }

  /// Obtient les objectifs proches de l'objectif
  Future<List<SavingsGoalModel>> getGoalsNearTarget() async {
    try {
      return await _savingsGoalService.getGoalsNearTarget();
    } catch (e) {
      debugPrint('Erreur lors du chargement: $e');
      return [];
    }
  }

  /// Obtient le total restant à épargner
  Future<double> getTotalRemainingAmount() async {
    try {
      return await _savingsGoalService.getTotalRemainingAmount();
    } catch (e) {
      debugPrint('Erreur: $e');
      return 0.0;
    }
  }

  /// Vérifie les objectifs et envoie des notifications si nécessaire
  Future<void> checkGoalsAndNotify() async {
    try {
      // Objectifs en retard
      final overdueGoals = await getOverdueGoals();
      for (final goal in overdueGoals) {
        if (goal.remainingAmount > 0) {
          await _notificationService.notifySavingsGoalDeadlineApproaching(
            goalName: goal.name,
            daysRemaining: 0,
            remainingAmount: goal.remainingAmount,
          );
        }
      }

      // Objectifs proches de l'échéance (7 jours)
      final upcomingGoals = await getUpcomingGoals(daysAhead: 7);
      for (final goal in upcomingGoals) {
        if (goal.daysRemaining != null && goal.remainingAmount > 0) {
          await _notificationService.notifySavingsGoalDeadlineApproaching(
            goalName: goal.name,
            daysRemaining: goal.daysRemaining!,
            remainingAmount: goal.remainingAmount,
          );
        }
      }

      // Objectifs proches de l'objectif
      final nearTargetGoals = await getGoalsNearTarget();
      for (final goal in nearTargetGoals) {
        await _notificationService.notifySavingsGoalNearTarget(
          goalName: goal.name,
          targetAmount: goal.targetAmount,
          currentAmount: goal.currentAmount,
          percentage: goal.progressPercentage,
        );
      }
    } catch (e) {
      debugPrint('Erreur lors de la vérification des objectifs: $e');
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
