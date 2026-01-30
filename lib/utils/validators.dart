/// Validateurs pour les formulaires
class Validators {
  /// Valide que le champ n'est pas vide
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? "Ce champ"} est obligatoire';
    }
    return null;
  }

  /// Valide un montant
  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le montant est obligatoire';
    }

    final cleaned = value
        .replaceAll(',', '.')
        .replaceAll(RegExp(r'[^\d.]'), '');
    final amount = double.tryParse(cleaned);

    if (amount == null) {
      return 'Montant invalide';
    }

    if (amount < 0) {
      return 'Le montant doit être positif';
    }

    if (amount > 999999999) {
      return 'Le montant est trop élevé';
    }

    return null;
  }

  /// Valide un titre de transaction
  static String? transactionTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le titre est obligatoire';
    }

    if (value.length < 2) {
      return 'Le titre doit contenir au moins 2 caractères';
    }

    if (value.length > 100) {
      return 'Le titre ne doit pas dépasser 100 caractères';
    }

    return null;
  }

  /// Valide une description
  static String? description(String? value, {int maxLength = 500}) {
    if (value == null || value.isEmpty) {
      return null; // La description est optionnelle
    }

    if (value.length > maxLength) {
      return 'La description ne doit pas dépasser $maxLength caractères';
    }

    return null;
  }

  /// Valide un nom de catégorie
  static String? categoryName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le nom de la catégorie est obligatoire';
    }

    if (value.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }

    if (value.length > 50) {
      return 'Le nom ne doit pas dépasser 50 caractères';
    }

    return null;
  }

  /// Valide un nom de budget
  static String? budgetName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le nom du budget est obligatoire';
    }

    if (value.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }

    if (value.length > 100) {
      return 'Le nom ne doit pas dépasser 100 caractères';
    }

    return null;
  }

  /// Valide une limite de budget
  static String? budgetLimit(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La limite est obligatoire';
    }

    final cleaned = value
        .replaceAll(',', '.')
        .replaceAll(RegExp(r'[^\d.]'), '');
    final limit = double.tryParse(cleaned);

    if (limit == null) {
      return 'Limite invalide';
    }

    if (limit <= 0) {
      return 'La limite doit être supérieure à 0';
    }

    if (limit > 999999999) {
      return 'La limite est trop élevée';
    }

    return null;
  }

  /// Valide un nom de compte
  static String? accountName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le nom du compte est obligatoire';
    }

    if (value.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }

    if (value.length > 50) {
      return 'Le nom ne doit pas dépasser 50 caractères';
    }

    return null;
  }

  /// Valide un solde initial
  static String? initialBalance(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le solde initial est obligatoire';
    }

    final cleaned = value
        .replaceAll(',', '.')
        .replaceAll(RegExp(r'[^\d.-]'), '');
    final balance = double.tryParse(cleaned);

    if (balance == null) {
      return 'Solde invalide';
    }

    if (balance < -999999999 || balance > 999999999) {
      return 'Le solde est hors limites';
    }

    return null;
  }

  /// Valide un objectif d'épargne
  static String? savingsGoal(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'L\'objectif est obligatoire';
    }

    final cleaned = value
        .replaceAll(',', '.')
        .replaceAll(RegExp(r'[^\d.]'), '');
    final goal = double.tryParse(cleaned);

    if (goal == null) {
      return 'Objectif invalide';
    }

    if (goal <= 0) {
      return 'L\'objectif doit être supérieur à 0';
    }

    if (goal > 999999999) {
      return 'L\'objectif est trop élevé';
    }

    return null;
  }

  /// Valide une date
  static String? date(DateTime? value) {
    if (value == null) {
      return 'La date est obligatoire';
    }

    final now = DateTime.now();
    final maxDate = DateTime(now.year + 10);
    final minDate = DateTime(2000);

    if (value.isAfter(maxDate)) {
      return 'La date ne peut pas être dans plus de 10 ans';
    }

    if (value.isBefore(minDate)) {
      return 'La date ne peut pas être avant l\'an 2000';
    }

    return null;
  }

  /// Valide une date future
  static String? futureDate(DateTime? value) {
    if (value == null) {
      return 'La date est obligatoire';
    }

    final now = DateTime.now();

    if (value.isBefore(now)) {
      return 'La date doit être dans le futur';
    }

    return null;
  }

  /// Combine plusieurs validateurs
  static String? combine(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}
