import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../services/budget_service.dart';

/// Provider pour la gestion des transactions
class TransactionProvider with ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  final BudgetService _budgetService = BudgetService();

  List<TransactionModel> _transactions = [];
  List<TransactionModel> _filteredTransactions = [];
  bool _isLoading = false;
  String? _error;

  // Filtres
  String? _selectedCategoryId;
  String? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';

  // Getters
  List<TransactionModel> get transactions => _filteredTransactions;
  List<TransactionModel> get allTransactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasTransactions => _transactions.isNotEmpty;

  // Filtres getters
  String? get selectedCategoryId => _selectedCategoryId;
  String? get selectedType => _selectedType;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get searchQuery => _searchQuery;

  /// Charge toutes les transactions
  Future<void> loadTransactions() async {
    _setLoading(true);
    _error = null;

    try {
      _transactions = await _transactionService.getAllTransactions();
      _applyFilters();
    } catch (e) {
      _error = 'Erreur lors du chargement des transactions: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  /// Charge les transactions récentes
  Future<void> loadRecentTransactions({int limit = 10}) async {
    _setLoading(true);
    _error = null;

    try {
      _transactions = await _transactionService.getRecentTransactions(
        limit: limit,
      );
      _applyFilters();
    } catch (e) {
      _error = 'Erreur lors du chargement: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  /// Ajoute une nouvelle transaction
  Future<bool> addTransaction(TransactionModel transaction) async {
    try {
      final id = await _transactionService.createTransaction(transaction);

      // Met à jour le budget si c'est une dépense
      if (transaction.isExpense) {
        await _budgetService.updateBudgetSpent(
          transaction.categoryId,
          transaction.amount,
        );
      }

      // Recharge les transactions
      await loadTransactions();
      return true;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Met à jour une transaction
  Future<bool> updateTransaction(TransactionModel transaction) async {
    try {
      await _transactionService.updateTransaction(transaction);

      // Met à jour le budget
      if (transaction.isExpense) {
        await _budgetService.updateBudgetSpent(
          transaction.categoryId,
          transaction.amount,
        );
      }

      await loadTransactions();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Supprime une transaction
  Future<bool> deleteTransaction(int id) async {
    try {
      final transaction = await _transactionService.getTransactionById(id);
      if (transaction == null) return false;

      await _transactionService.deleteTransaction(id);

      // Met à jour le budget
      if (transaction.isExpense) {
        await _budgetService.updateBudgetSpent(
          transaction.categoryId,
          transaction.amount,
        );
      }

      await loadTransactions();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Recherche des transactions
  Future<void> searchTransactions(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      _applyFilters();
      return;
    }

    _setLoading(true);
    try {
      final results = await _transactionService.searchTransactions(query);
      _filteredTransactions = results;
    } catch (e) {
      _error = 'Erreur lors de la recherche: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  /// Filtre par catégorie
  void filterByCategory(int? categoryId) {
    _selectedCategoryId = categoryId?.toString();
    _applyFilters();
  }

  /// Filtre par type de transaction
  void filterByType(String? type) {
    _selectedType = type;
    _applyFilters();
  }

  /// Filtre par période
  void filterByPeriod(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    _applyFilters();
  }

  /// Réinitialise tous les filtres
  void clearFilters() {
    _selectedCategoryId = null;
    _selectedType = null;
    _startDate = null;
    _endDate = null;
    _searchQuery = '';
    _applyFilters();
  }

  /// Applique les filtres actifs
  void _applyFilters() {
    _filteredTransactions = _transactions.where((transaction) {
      // Filtre par catégorie
      if (_selectedCategoryId != null) {
        if (transaction.categoryId.toString() != _selectedCategoryId) {
          return false;
        }
      }

      // Filtre par type
      if (_selectedType != null) {
        if (transaction.transactionType != _selectedType) {
          return false;
        }
      }

      // Filtre par période
      if (_startDate != null && transaction.date.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && transaction.date.isAfter(_endDate!)) {
        return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  /// Obtient les statistiques
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      return await _transactionService.getGlobalStatistics();
    } catch (e) {
      debugPrint('Erreur lors du chargement des statistiques: $e');
      return {
        'total_income': 0.0,
        'total_expense': 0.0,
        'total_transactions': 0,
        'net_balance': 0.0,
      };
    }
  }

  /// Obtient le solde d'une période
  Future<double> getBalance(DateTime start, DateTime end) async {
    try {
      return await _transactionService.getBalanceByPeriod(start, end);
    } catch (e) {
      debugPrint('Erreur lors du calcul du solde: $e');
      return 0.0;
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
