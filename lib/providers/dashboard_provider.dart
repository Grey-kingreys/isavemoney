import 'package:flutter/foundation.dart';
import '../services/transaction_service.dart';
import '../services/budget_service.dart';
import '../services/report_service.dart';
import '../utils/date_utils.dart' as app_date_utils;

/// Provider pour le tableau de bord
class DashboardProvider with ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  final BudgetService _budgetService = BudgetService();
  final ReportService _reportService = ReportService();

  bool _isLoading = false;
  String? _error;

  // Données du dashboard
  Map<String, dynamic>? _summary;
  Map<String, dynamic>? _monthStats;
  Map<String, dynamic>? _budgetSummary;
  List<Map<String, dynamic>> _recentTransactions = [];
  List<Map<String, dynamic>> _categoryBreakdown = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get summary => _summary;
  Map<String, dynamic>? get monthStats => _monthStats;
  Map<String, dynamic>? get budgetSummary => _budgetSummary;
  List<Map<String, dynamic>> get recentTransactions => _recentTransactions;
  List<Map<String, dynamic>> get categoryBreakdown => _categoryBreakdown;

  /// Charge toutes les données du dashboard
  Future<void> loadDashboard() async {
    _setLoading(true);
    _error = null;

    try {
      await Future.wait([
        _loadSummary(),
        _loadMonthStats(),
        _loadBudgetSummary(),
        _loadRecentTransactions(),
        _loadCategoryBreakdown(),
      ]);
    } catch (e) {
      _error = 'Erreur lors du chargement du tableau de bord: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  /// Charge le résumé global
  Future<void> _loadSummary() async {
    try {
      _summary = await _transactionService.getGlobalStatistics();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du chargement du résumé: $e');
    }
  }

  /// Charge les statistiques du mois
  Future<void> _loadMonthStats() async {
    try {
      final now = DateTime.now();
      final startOfMonth = app_date_utils.DateUtils.getMonthStart(now);
      final endOfMonth = app_date_utils.DateUtils.getMonthEnd(now);

      final income = await _transactionService.getIncomeByPeriod(
        startOfMonth,
        endOfMonth,
      );
      final expense = await _transactionService.getExpenseByPeriod(
        startOfMonth,
        endOfMonth,
      );
      final transactions = await _transactionService.getTransactionsByPeriod(
        startOfMonth,
        endOfMonth,
      );

      _monthStats = {
        'income': income,
        'expense': expense,
        'balance': income - expense,
        'transaction_count': transactions.length,
        'average_transaction': transactions.isNotEmpty
            ? (income + expense) / transactions.length
            : 0.0,
        'month_name': app_date_utils.DateUtils.formatMonthYear(now),
      };

      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du chargement des stats du mois: $e');
    }
  }

  /// Charge le résumé des budgets
  Future<void> _loadBudgetSummary() async {
    try {
      _budgetSummary = await _budgetService.getBudgetSummary();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du chargement du résumé budgets: $e');
    }
  }

  /// Charge les transactions récentes
  Future<void> _loadRecentTransactions() async {
    try {
      final transactions = await _transactionService.getRecentTransactions(
        limit: 5,
      );
      _recentTransactions = transactions.map((t) => t.toMap()).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du chargement des transactions: $e');
    }
  }

  /// Charge la répartition par catégorie
  Future<void> _loadCategoryBreakdown() async {
    try {
      final now = DateTime.now();
      final startOfMonth = app_date_utils.DateUtils.getMonthStart(now);
      final endOfMonth = app_date_utils.DateUtils.getMonthEnd(now);

      final expenses = await _transactionService.getExpensesByCategoryForPeriod(
        startOfMonth,
        endOfMonth,
      );

      _categoryBreakdown = expenses.entries.map((entry) {
        return {'category_id': entry.key, 'amount': entry.value};
      }).toList();

      // Trie par montant décroissant
      _categoryBreakdown.sort(
        (a, b) => (b['amount'] as double).compareTo(a['amount'] as double),
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du chargement de la répartition: $e');
    }
  }

  /// Obtient le solde actuel
  double get currentBalance {
    if (_summary == null) return 0.0;
    return (_summary!['total_income'] as num).toDouble() -
        (_summary!['total_expense'] as num).toDouble();
  }

  /// Obtient le solde du mois
  double get monthBalance {
    if (_monthStats == null) return 0.0;
    return (_monthStats!['balance'] as num).toDouble();
  }

  /// Obtient les revenus du mois
  double get monthIncome {
    if (_monthStats == null) return 0.0;
    return (_monthStats!['income'] as num).toDouble();
  }

  /// Obtient les dépenses du mois
  double get monthExpense {
    if (_monthStats == null) return 0.0;
    return (_monthStats!['expense'] as num).toDouble();
  }

  /// Obtient le nombre de transactions du mois
  int get monthTransactionCount {
    if (_monthStats == null) return 0;
    return _monthStats!['transaction_count'] as int;
  }

  /// Obtient le taux d'épargne
  double get savingsRate {
    if (_monthStats == null) return 0.0;
    final income = (_monthStats!['income'] as num).toDouble();
    final expense = (_monthStats!['expense'] as num).toDouble();
    if (income == 0) return 0.0;
    return ((income - expense) / income) * 100;
  }

  /// Vérifie si les budgets sont dépassés
  bool get hasBudgetAlerts {
    if (_budgetSummary == null) return false;
    final exceeded = _budgetSummary!['exceeded_count'] as int;
    final warning = _budgetSummary!['warning_count'] as int;
    return exceeded > 0 || warning > 0;
  }

  /// Obtient le nombre de budgets dépassés
  int get exceededBudgetCount {
    if (_budgetSummary == null) return 0;
    return _budgetSummary!['exceeded_count'] as int;
  }

  /// Obtient le nombre de budgets en alerte
  int get warningBudgetCount {
    if (_budgetSummary == null) return 0;
    return _budgetSummary!['warning_count'] as int;
  }

  /// Rafraîchit les données
  Future<void> refresh() async {
    await loadDashboard();
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
