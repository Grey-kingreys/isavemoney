import 'package:sqflite/sqflite.dart';
import '../models/savings_goal_model.dart';
import '../utils/constants.dart';
import 'database_service.dart';

/// Service de gestion des objectifs d'épargne
class SavingsGoalService {
  final DatabaseService _dbService = DatabaseService();

  /// Crée un nouvel objectif d'épargne
  Future<int> createSavingsGoal(SavingsGoalModel goal) async {
    final db = await _dbService.database;
    return await db.insert(
      AppConstants.tableSavingsGoals,
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Récupère tous les objectifs d'épargne
  Future<List<SavingsGoalModel>> getAllSavingsGoals() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableSavingsGoals,
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => SavingsGoalModel.fromMap(map)).toList();
  }

  /// Récupère les objectifs actifs (non complétés)
  Future<List<SavingsGoalModel>> getActiveSavingsGoals() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableSavingsGoals,
      where: 'is_completed = 0',
      orderBy: 'target_date ASC',
    );

    return maps.map((map) => SavingsGoalModel.fromMap(map)).toList();
  }

  /// Récupère les objectifs complétés
  Future<List<SavingsGoalModel>> getCompletedSavingsGoals() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableSavingsGoals,
      where: 'is_completed = 1',
      orderBy: 'updated_at DESC',
    );

    return maps.map((map) => SavingsGoalModel.fromMap(map)).toList();
  }

  /// Récupère un objectif par son ID
  Future<SavingsGoalModel?> getSavingsGoalById(int id) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableSavingsGoals,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return SavingsGoalModel.fromMap(maps.first);
  }

  /// Met à jour un objectif d'épargne
  Future<int> updateSavingsGoal(SavingsGoalModel goal) async {
    final db = await _dbService.database;
    return await db.update(
      AppConstants.tableSavingsGoals,
      goal.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  /// Ajoute un montant à un objectif
  Future<void> addToSavingsGoal(int goalId, double amount) async {
    final goal = await getSavingsGoalById(goalId);
    if (goal == null) return;

    final newAmount = goal.currentAmount + amount;
    final isNowCompleted = newAmount >= goal.targetAmount;

    final updatedGoal = goal.copyWith(
      currentAmount: newAmount,
      isCompleted: isNowCompleted,
      updatedAt: DateTime.now(),
    );

    await updateSavingsGoal(updatedGoal);
  }

  /// Retire un montant d'un objectif
  Future<void> subtractFromSavingsGoal(int goalId, double amount) async {
    final goal = await getSavingsGoalById(goalId);
    if (goal == null) return;

    final newAmount = (goal.currentAmount - amount).clamp(0.0, double.infinity);
    final isStillCompleted = newAmount >= goal.targetAmount;

    final updatedGoal = goal.copyWith(
      currentAmount: newAmount,
      isCompleted: isStillCompleted,
      updatedAt: DateTime.now(),
    );

    await updateSavingsGoal(updatedGoal);
  }

  /// Marque un objectif comme complété
  Future<int> markAsCompleted(int id) async {
    final db = await _dbService.database;
    return await db.update(
      AppConstants.tableSavingsGoals,
      {'is_completed': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Réactive un objectif complété
  Future<int> markAsIncomplete(int id) async {
    final db = await _dbService.database;
    return await db.update(
      AppConstants.tableSavingsGoals,
      {'is_completed': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Supprime un objectif d'épargne
  Future<int> deleteSavingsGoal(int id) async {
    final db = await _dbService.database;
    return await db.delete(
      AppConstants.tableSavingsGoals,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Récupère les statistiques des objectifs
  Future<Map<String, dynamic>> getSavingsGoalStatistics() async {
    final db = await _dbService.database;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_goals,
        SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) as completed_goals,
        SUM(CASE WHEN is_completed = 0 THEN 1 ELSE 0 END) as active_goals,
        SUM(target_amount) as total_target,
        SUM(current_amount) as total_saved,
        AVG(current_amount * 100.0 / target_amount) as average_progress
      FROM ${AppConstants.tableSavingsGoals}
    ''');

    final row = result.first;
    final totalTarget = (row['total_target'] as num?)?.toDouble() ?? 0.0;
    final totalSaved = (row['total_saved'] as num?)?.toDouble() ?? 0.0;

    return {
      'total_goals': row['total_goals'] as int,
      'completed_goals': row['completed_goals'] as int,
      'active_goals': row['active_goals'] as int,
      'total_target': totalTarget,
      'total_saved': totalSaved,
      'total_remaining': totalTarget - totalSaved,
      'average_progress': (row['average_progress'] as num?)?.toDouble() ?? 0.0,
      'overall_progress': totalTarget > 0
          ? (totalSaved / totalTarget) * 100
          : 0.0,
    };
  }

  /// Récupère les objectifs en retard
  Future<List<SavingsGoalModel>> getOverdueGoals() async {
    final db = await _dbService.database;
    final now = DateTime.now().toIso8601String();
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableSavingsGoals,
      where: 'is_completed = 0 AND target_date < ?',
      whereArgs: [now],
      orderBy: 'target_date ASC',
    );

    return maps.map((map) => SavingsGoalModel.fromMap(map)).toList();
  }

  /// Récupère les objectifs proches de l'échéance
  Future<List<SavingsGoalModel>> getUpcomingGoals({int daysAhead = 30}) async {
    final db = await _dbService.database;
    final now = DateTime.now();
    final future = now.add(Duration(days: daysAhead));

    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableSavingsGoals,
      where: 'is_completed = 0 AND target_date BETWEEN ? AND ?',
      whereArgs: [now.toIso8601String(), future.toIso8601String()],
      orderBy: 'target_date ASC',
    );

    return maps.map((map) => SavingsGoalModel.fromMap(map)).toList();
  }

  /// Récupère les objectifs proches de l'objectif (90%+)
  Future<List<SavingsGoalModel>> getGoalsNearTarget() async {
    final goals = await getActiveSavingsGoals();
    return goals.where((goal) => goal.progressPercentage >= 90).toList();
  }

  /// Vérifie si un objectif existe par nom
  Future<bool> goalExistsByName(String name, {int? excludeId}) async {
    final db = await _dbService.database;
    String whereClause = 'name = ?';
    List<dynamic> whereArgs = [name];

    if (excludeId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableSavingsGoals,
      where: whereClause,
      whereArgs: whereArgs,
    );

    return maps.isNotEmpty;
  }

  /// Calcule le montant total à épargner pour atteindre tous les objectifs
  Future<double> getTotalRemainingAmount() async {
    final goals = await getActiveSavingsGoals();
    return goals.fold(0.0, (sum, goal) {
      return sum;
    });
  }

  /// Récupère les recommandations d'épargne
  Future<Map<String, dynamic>> getSavingsRecommendations() async {
    final goals = await getActiveSavingsGoals();
    if (goals.isEmpty) {
      return {'has_goals': false, 'message': 'Aucun objectif d\'épargne actif'};
    }

    // Trie par urgence (date cible la plus proche)
    goals.sort((a, b) {
      if (a.targetDate == null && b.targetDate == null) return 0;
      if (a.targetDate == null) return 1;
      if (b.targetDate == null) return -1;
      return a.targetDate!.compareTo(b.targetDate!);
    });

    final mostUrgent = goals.first;
    final totalRemaining = goals.fold(
      0.0,
      (sum, goal) => sum + goal.remainingAmount,
    );

    double? dailyAmount;
    if (mostUrgent.daysRemaining != null && mostUrgent.daysRemaining! > 0) {
      dailyAmount = totalRemaining / mostUrgent.daysRemaining!;
    }

    return {
      'has_goals': true,
      'total_goals': goals.length,
      'most_urgent': mostUrgent.toMap(),
      'total_remaining': totalRemaining,
      'recommended_daily_savings': dailyAmount,
      'recommended_monthly_savings': dailyAmount != null
          ? dailyAmount * 30
          : null,
    };
  }
}
