import 'package:flutter/foundation.dart';
import '../models/account_model.dart';
import '../services/account_service.dart';

/// Provider pour la gestion des comptes bancaires
class AccountProvider with ChangeNotifier {
  final AccountService _accountService = AccountService();

  List<AccountModel> _accounts = [];
  List<AccountModel> _activeAccounts = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _statistics;

  // Getters
  List<AccountModel> get accounts => _accounts;
  List<AccountModel> get activeAccounts => _activeAccounts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasAccounts => _accounts.isNotEmpty;
  Map<String, dynamic>? get statistics => _statistics;

  /// Charge tous les comptes
  Future<void> loadAccounts() async {
    _setLoading(true);
    _error = null;

    try {
      _accounts = await _accountService.getAllAccounts();
      _activeAccounts = await _accountService.getActiveAccounts();
      await loadStatistics();
    } catch (e) {
      _error = 'Erreur lors du chargement des comptes: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  /// Charge les statistiques des comptes
  Future<void> loadStatistics() async {
    try {
      _statistics = await _accountService.getAccountStatistics();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du chargement des statistiques: $e');
    }
  }

  /// Obtient un compte par ID
  Future<AccountModel?> getAccountById(int id) async {
    try {
      return await _accountService.getAccountById(id);
    } catch (e) {
      debugPrint('Erreur lors du chargement du compte: $e');
      return null;
    }
  }

  /// Obtient les comptes par type
  Future<List<AccountModel>> getAccountsByType(String type) async {
    try {
      return await _accountService.getAccountsByType(type);
    } catch (e) {
      debugPrint('Erreur lors du chargement: $e');
      return [];
    }
  }

  /// Ajoute un nouveau compte
  Future<bool> addAccount(AccountModel account) async {
    try {
      // Vérifie si le nom existe déjà
      final exists = await _accountService.accountExistsByName(account.name);
      if (exists) {
        _error = 'Un compte avec ce nom existe déjà';
        notifyListeners();
        return false;
      }

      await _accountService.createAccount(account);
      await loadAccounts();
      return true;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout du compte: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Met à jour un compte
  Future<bool> updateAccount(AccountModel account) async {
    try {
      // Vérifie si le nom existe déjà (sauf pour ce compte)
      final exists = await _accountService.accountExistsByName(
        account.name,
        excludeId: account.id,
      );
      if (exists) {
        _error = 'Un compte avec ce nom existe déjà';
        notifyListeners();
        return false;
      }

      await _accountService.updateAccount(account);
      await loadAccounts();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Supprime un compte
  Future<bool> deleteAccount(int id) async {
    try {
      await _accountService.deleteAccount(id);
      await loadAccounts();
      return true;
    } catch (e) {
      _error = e.toString().contains('utilisé')
          ? e.toString()
          : 'Erreur lors de la suppression: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Active/désactive un compte
  Future<bool> toggleAccountStatus(int id, bool isActive) async {
    try {
      if (isActive) {
        await _accountService.activateAccount(id);
      } else {
        await _accountService.deactivateAccount(id);
      }
      await loadAccounts();
      return true;
    } catch (e) {
      _error = 'Erreur lors du changement de statut: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Met à jour le solde d'un compte
  Future<bool> updateBalance(int accountId, double newBalance) async {
    try {
      await _accountService.updateAccountBalance(accountId, newBalance);
      await loadAccounts();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour du solde: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Ajoute un montant à un compte
  Future<bool> addToBalance(int accountId, double amount) async {
    try {
      await _accountService.addToBalance(accountId, amount);
      await loadAccounts();
      return true;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Retire un montant d'un compte
  Future<bool> subtractFromBalance(int accountId, double amount) async {
    try {
      await _accountService.subtractFromBalance(accountId, amount);
      await loadAccounts();
      return true;
    } catch (e) {
      _error = 'Erreur lors du retrait: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Transfère entre deux comptes
  Future<bool> transferBetweenAccounts(
    int fromAccountId,
    int toAccountId,
    double amount,
  ) async {
    try {
      final success = await _accountService.transferBetweenAccounts(
        fromAccountId,
        toAccountId,
        amount,
      );

      if (!success) {
        _error = 'Solde insuffisant pour le transfert';
        notifyListeners();
        return false;
      }

      await loadAccounts();
      return true;
    } catch (e) {
      _error = 'Erreur lors du transfert: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Obtient le solde total
  Future<double> getTotalBalance() async {
    try {
      return await _accountService.getTotalBalance();
    } catch (e) {
      debugPrint('Erreur lors du calcul du solde total: $e');
      return 0.0;
    }
  }

  /// Obtient l'historique des transactions d'un compte
  Future<List<Map<String, dynamic>>> getAccountTransactionHistory(
    int accountId,
  ) async {
    try {
      return await _accountService.getAccountTransactionHistory(accountId);
    } catch (e) {
      debugPrint('Erreur lors du chargement de l\'historique: $e');
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
