import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../utils/validators.dart';

/// Controller pour la gestion des transactions
class TransactionController {
  final TransactionProvider transactionProvider;
  final CategoryProvider categoryProvider;

  TransactionController({
    required this.transactionProvider,
    required this.categoryProvider,
  });

  // Controllers de formulaire
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();

  // Données du formulaire
  int? selectedCategoryId;
  String transactionType = 'expense';
  DateTime selectedDate = DateTime.now();
  String? selectedPaymentMethod;
  bool isRecurring = false;
  String? recurringPattern;

  /// Initialise le formulaire pour une nouvelle transaction
  void initializeForNew({String? defaultType}) {
    clearForm();
    if (defaultType != null) {
      transactionType = defaultType;
    }
  }

  /// Initialise le formulaire pour une édition
  void initializeForEdit(TransactionModel transaction) {
    titleController.text = transaction.title;
    amountController.text = transaction.amount.toString();
    descriptionController.text = transaction.description ?? '';
    locationController.text = transaction.location ?? '';
    selectedCategoryId = transaction.categoryId;
    transactionType = transaction.transactionType;
    selectedDate = transaction.date;
    selectedPaymentMethod = transaction.paymentMethod;
    isRecurring = transaction.isRecurring;
    recurringPattern = transaction.recurringPattern;
  }

  /// Valide le formulaire
  Map<String, String?> validateForm() {
    final errors = <String, String?>{};

    errors['title'] = Validators.transactionTitle(titleController.text);
    errors['amount'] = Validators.amount(amountController.text);
    errors['description'] = Validators.description(descriptionController.text);
    errors['date'] = Validators.date(selectedDate);

    if (selectedCategoryId == null) {
      errors['category'] = 'Veuillez sélectionner une catégorie';
    }

    // Retourne null si aucune erreur
    return errors..removeWhere((key, value) => value == null);
  }

  /// Crée une transaction depuis le formulaire
  TransactionModel createTransaction({int? id}) {
    final amount = double.parse(
      amountController.text
          .replaceAll(',', '.')
          .replaceAll(RegExp(r'[^\d.]'), ''),
    );

    return TransactionModel(
      id: id,
      title: titleController.text.trim(),
      amount: amount,
      date: selectedDate,
      categoryId: selectedCategoryId!,
      transactionType: transactionType,
      paymentMethod: selectedPaymentMethod,
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      location: locationController.text.trim().isEmpty
          ? null
          : locationController.text.trim(),
      isRecurring: isRecurring,
      recurringPattern: recurringPattern,
    );
  }

  /// Sauvegarde la transaction
  Future<bool> saveTransaction({int? id}) async {
    final errors = validateForm();
    if (errors.isNotEmpty) {
      return false;
    }

    final transaction = createTransaction(id: id);

    if (id == null) {
      return await transactionProvider.addTransaction(transaction);
    } else {
      return await transactionProvider.updateTransaction(transaction);
    }
  }

  /// Supprime une transaction
  Future<bool> deleteTransaction(int id) async {
    return await transactionProvider.deleteTransaction(id);
  }

  /// Change le type de transaction
  void setTransactionType(String type) {
    transactionType = type;
    selectedCategoryId = null; // Réinitialise la catégorie
  }

  /// Sélectionne une catégorie
  void selectCategory(int categoryId) {
    selectedCategoryId = categoryId;
  }

  /// Change la date
  void setDate(DateTime date) {
    selectedDate = date;
  }

  /// Change le mode de paiement
  void setPaymentMethod(String? method) {
    selectedPaymentMethod = method;
  }

  /// Active/désactive la récurrence
  void toggleRecurring(bool value) {
    isRecurring = value;
    if (!value) {
      recurringPattern = null;
    }
  }

  /// Définit le pattern de récurrence
  void setRecurringPattern(String? pattern) {
    recurringPattern = pattern;
  }

  /// Obtient les catégories disponibles
  List<CategoryModel> getAvailableCategories() {
    if (transactionType == 'expense') {
      return categoryProvider.expenseCategories;
    } else {
      return categoryProvider.incomeCategories;
    }
  }

  /// Nettoie le formulaire
  void clearForm() {
    titleController.clear();
    amountController.clear();
    descriptionController.clear();
    locationController.clear();
    selectedCategoryId = null;
    transactionType = 'expense';
    selectedDate = DateTime.now();
    selectedPaymentMethod = null;
    isRecurring = false;
    recurringPattern = null;
  }

  /// Dispose les controllers
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    locationController.dispose();
  }
}
