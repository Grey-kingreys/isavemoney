import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../providers/account_provider.dart';
import '../utils/validators.dart';

/// Controller pour la gestion des comptes bancaires
class AccountController {
  final AccountProvider accountProvider;

  AccountController({required this.accountProvider});

  // Controllers de formulaire
  final nameController = TextEditingController();
  final initialBalanceController = TextEditingController();

  // Données du formulaire
  String accountType = 'bank';
  String currency = 'EUR';
  bool isActive = true;
  String? selectedColor;
  String? selectedIcon;

  // Types de comptes disponibles
  static const List<Map<String, dynamic>> accountTypes = [
    {'value': 'cash', 'name': 'Espèces', 'icon': Icons.account_balance_wallet},
    {'value': 'bank', 'name': 'Compte bancaire', 'icon': Icons.account_balance},
    {
      'value': 'credit_card',
      'name': 'Carte de crédit',
      'icon': Icons.credit_card,
    },
    {'value': 'savings', 'name': 'Épargne', 'icon': Icons.savings},
    {
      'value': 'investment',
      'name': 'Investissement',
      'icon': Icons.trending_up,
    },
  ];

  // Couleurs disponibles
  static const List<String> availableColors = [
    '#2ECC71',
    '#3498DB',
    '#9B59B6',
    '#E74C3C',
    '#F39C12',
    '#1ABC9C',
    '#34495E',
    '#E67E22',
  ];

  /// Initialise le formulaire pour un nouveau compte
  void initializeForNew() {
    clearForm();
  }

  /// Initialise le formulaire pour une édition
  void initializeForEdit(AccountModel account) {
    nameController.text = account.name;
    initialBalanceController.text = account.currentBalance.toString();
    accountType = account.accountType;
    currency = account.currency;
    isActive = account.isActive;
    selectedColor = account.color;
    selectedIcon = account.icon;
  }

  /// Valide le formulaire
  Map<String, String?> validateForm() {
    final errors = <String, String?>{};

    errors['name'] = Validators.accountName(nameController.text);
    errors['balance'] = Validators.initialBalance(
      initialBalanceController.text,
    );

    return errors..removeWhere((key, value) => value == null);
  }

  /// Crée un compte depuis le formulaire
  AccountModel createAccount({int? id}) {
    final initialBalance = double.parse(
      initialBalanceController.text
          .replaceAll(',', '.')
          .replaceAll(RegExp(r'[^\d.-]'), ''),
    );

    return AccountModel(
      id: id,
      name: nameController.text.trim(),
      accountType: accountType,
      initialBalance: initialBalance,
      currentBalance: initialBalance,
      currency: currency,
      isActive: isActive,
      color: selectedColor,
      icon: selectedIcon,
    );
  }

  /// Sauvegarde le compte
  Future<bool> saveAccount({int? id}) async {
    final errors = validateForm();
    if (errors.isNotEmpty) {
      return false;
    }

    final account = createAccount(id: id);

    if (id == null) {
      return await accountProvider.addAccount(account);
    } else {
      return await accountProvider.updateAccount(account);
    }
  }

  /// Supprime un compte
  Future<bool> deleteAccount(int id) async {
    return await accountProvider.deleteAccount(id);
  }

  /// Active/désactive un compte
  Future<bool> toggleAccountStatus(int id, bool status) async {
    return await accountProvider.toggleAccountStatus(id, status);
  }

  /// Change le type de compte
  void setAccountType(String type) {
    accountType = type;
  }

  /// Change la devise
  void setCurrency(String newCurrency) {
    currency = newCurrency;
  }

  /// Active/désactive le compte
  void toggleActive(bool value) {
    isActive = value;
  }

  /// Sélectionne une couleur
  void selectColor(String color) {
    selectedColor = color;
  }

  /// Sélectionne une icône
  void selectIcon(String icon) {
    selectedIcon = icon;
  }

  /// Obtient le nom du type de compte
  String getAccountTypeName() {
    final type = accountTypes.firstWhere(
      (t) => t['value'] == accountType,
      orElse: () => {'name': accountType},
    );
    return type['name'] as String;
  }

  /// Obtient l'icône du type de compte
  IconData getAccountTypeIcon() {
    final type = accountTypes.firstWhere(
      (t) => t['value'] == accountType,
      orElse: () => {'icon': Icons.account_balance},
    );
    return type['icon'] as IconData;
  }

  /// Transfère entre deux comptes
  Future<bool> transferBetweenAccounts(
    int fromAccountId,
    int toAccountId,
    double amount,
  ) async {
    return await accountProvider.transferBetweenAccounts(
      fromAccountId,
      toAccountId,
      amount,
    );
  }

  /// Ajoute un montant à un compte
  Future<bool> addToBalance(int accountId, double amount) async {
    return await accountProvider.addToBalance(accountId, amount);
  }

  /// Retire un montant d'un compte
  Future<bool> subtractFromBalance(int accountId, double amount) async {
    return await accountProvider.subtractFromBalance(accountId, amount);
  }

  /// Obtient le solde total
  Future<double> getTotalBalance() async {
    return await accountProvider.getTotalBalance();
  }

  /// Nettoie le formulaire
  void clearForm() {
    nameController.clear();
    initialBalanceController.text = '0';
    accountType = 'bank';
    currency = 'EUR';
    isActive = true;
    selectedColor = null;
    selectedIcon = null;
  }

  /// Dispose les controllers
  void dispose() {
    nameController.dispose();
    initialBalanceController.dispose();
  }
}
