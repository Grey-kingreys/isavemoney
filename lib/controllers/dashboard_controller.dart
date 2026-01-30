import 'package:flutter/material.dart';
import '../providers/dashboard_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';
import '../utils/date_utils.dart' as app_date_utils;

/// Controller pour le tableau de bord
class DashboardController {
  final DashboardProvider dashboardProvider;
  final TransactionProvider transactionProvider;
  final BudgetProvider budgetProvider;

  DashboardController({
    required this.dashboardProvider,
    required this.transactionProvider,
    required this.budgetProvider,
  });

  // Période sélectionnée pour les filtres
  DateTime _selectedMonth = DateTime.now();
  String _selectedPeriod = 'month'; // 'day', 'week', 'month', 'year'

  /// Getters
  DateTime get selectedMonth => _selectedMonth;
  String get selectedPeriod => _selectedPeriod;

  /// Initialise le dashboard
  Future<void> initialize() async {
    await dashboardProvider.loadDashboard();
  }

  /// Rafraîchit toutes les données
  Future<void> refresh() async {
    await Future.wait([
      dashboardProvider.refresh(),
      transactionProvider.loadRecentTransactions(),
      budgetProvider.loadBudgets(),
    ]);
  }

  /// Change la période sélectionnée
  void setPeriod(String period) {
    _selectedPeriod = period;
  }

  /// Change le mois sélectionné
  void setMonth(DateTime month) {
    _selectedMonth = month;
  }

  /// Obtient le solde actuel
  double getCurrentBalance() {
    return dashboardProvider.currentBalance;
  }

  /// Obtient le solde du mois
  double getMonthBalance() {
    return dashboardProvider.monthBalance;
  }

  /// Obtient les revenus du mois
  double getMonthIncome() {
    return dashboardProvider.monthIncome;
  }

  /// Obtient les dépenses du mois
  double getMonthExpense() {
    return dashboardProvider.monthExpense;
  }

  /// Obtient le taux d'épargne
  double getSavingsRate() {
    return dashboardProvider.savingsRate;
  }

  /// Vérifie si des alertes budgets existent
  bool hasBudgetAlerts() {
    return dashboardProvider.hasBudgetAlerts;
  }

  /// Obtient le nombre de budgets dépassés
  int getExceededBudgetCount() {
    return dashboardProvider.exceededBudgetCount;
  }

  /// Obtient le nombre de budgets en alerte
  int getWarningBudgetCount() {
    return dashboardProvider.warningBudgetCount;
  }

  /// Obtient les transactions récentes
  List<Map<String, dynamic>> getRecentTransactions() {
    return dashboardProvider.recentTransactions;
  }

  /// Obtient la répartition par catégorie
  List<Map<String, dynamic>> getCategoryBreakdown() {
    return dashboardProvider.categoryBreakdown;
  }

  /// Obtient le résumé financier
  Map<String, dynamic>? getFinancialSummary() {
    return dashboardProvider.summary;
  }

  /// Obtient les statistiques du mois
  Map<String, dynamic>? getMonthStatistics() {
    return dashboardProvider.monthStats;
  }

  /// Obtient le résumé des budgets
  Map<String, dynamic>? getBudgetSummary() {
    return dashboardProvider.budgetSummary;
  }

  /// Vérifie si le solde est positif
  bool hasPositiveBalance() {
    return getCurrentBalance() > 0;
  }

  /// Vérifie si le mois est bénéficiaire
  bool isMonthProfitable() {
    return getMonthBalance() > 0;
  }

  /// Obtient le pourcentage d'utilisation du budget
  double getBudgetUsagePercentage() {
    final summary = getBudgetSummary();
    if (summary == null || !summary.containsKey('percentage_used')) {
      return 0.0;
    }
    return (summary['percentage_used'] as num).toDouble();
  }

  /// Obtient le montant restant du budget
  double getRemainingBudget() {
    final summary = getBudgetSummary();
    if (summary == null || !summary.containsKey('total_remaining')) {
      return 0.0;
    }
    return (summary['total_remaining'] as num).toDouble();
  }

  /// Calcule la tendance (augmentation/diminution)
  Future<Map<String, double>> calculateTrends() async {
    final now = DateTime.now();
    final thisMonth = app_date_utils.DateUtils.getMonthStart(now);
    final lastMonth = app_date_utils.DateUtils.getMonthStart(
      DateTime(now.year, now.month - 1),
    );

    final thisMonthEnd = app_date_utils.DateUtils.getMonthEnd(now);
    final lastMonthEnd = app_date_utils.DateUtils.getMonthEnd(
      DateTime(now.year, now.month - 1),
    );

    final thisMonthBalance = await transactionProvider.getBalance(
      thisMonth,
      thisMonthEnd,
    );
    final lastMonthBalance = await transactionProvider.getBalance(
      lastMonth,
      lastMonthEnd,
    );

    final difference = thisMonthBalance - lastMonthBalance;
    final percentageChange = lastMonthBalance != 0
        ? (difference / lastMonthBalance) * 100
        : 0.0;

    return {'difference': difference, 'percentage': percentageChange};
  }

  /// Obtient le message d'état du budget
  String getBudgetStatusMessage() {
    if (!dashboardProvider.budgetSummary!['has_budgets']) {
      return 'Aucun budget défini';
    }

    final exceeded = getExceededBudgetCount();
    final warning = getWarningBudgetCount();

    if (exceeded > 0) {
      return '$exceeded budget${exceeded > 1 ? 's' : ''} dépassé${exceeded > 1 ? 's' : ''}';
    } else if (warning > 0) {
      return '$warning budget${warning > 1 ? 's' : ''} en alerte';
    } else {
      return 'Tous les budgets sont OK';
    }
  }

  /// Obtient la couleur du statut du budget
  Color getBudgetStatusColor() {
    final exceeded = getExceededBudgetCount();
    final warning = getWarningBudgetCount();

    if (exceeded > 0) {
      return Colors.red;
    } else if (warning > 0) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  /// Obtient le message de santé financière
  String getFinancialHealthMessage() {
    final balance = getMonthBalance();
    final savingsRate = getSavingsRate();

    if (balance < 0) {
      return 'Attention : dépenses supérieures aux revenus';
    } else if (savingsRate > 20) {
      return 'Excellente gestion financière !';
    } else if (savingsRate > 10) {
      return 'Bonne gestion, continuez !';
    } else if (savingsRate > 0) {
      return 'Vous épargnez, c\'est bien !';
    } else {
      return 'Essayez d\'épargner davantage';
    }
  }

  /// Obtient les données pour les graphiques
  Future<List<Map<String, dynamic>>> getChartData() async {
    final breakdown = getCategoryBreakdown();
    return breakdown.take(5).toList();
  }

  /// Vérifie s'il y a des données
  bool hasData() {
    final summary = getFinancialSummary();
    if (summary == null) return false;
    return (summary['total_transactions'] as int) > 0;
  }
}
