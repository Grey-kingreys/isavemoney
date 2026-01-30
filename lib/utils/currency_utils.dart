import 'package:intl/intl.dart';

/// Utilitaire pour formater les montants en devise
class CurrencyUtils {
  /// Symboles des devises supportées
  static const Map<String, String> currencySymbols = {
    'EUR': '€',
    'USD': '\$',
    'GBP': '£',
    'GNF': 'FG', // Franc Guinéen
    'XOF': 'CFA', // Franc CFA
    'XAF': 'FCFA',
    'MAD': 'DH',
    'TND': 'DT',
  };

  /// Noms des devises
  static const Map<String, String> currencyNames = {
    'EUR': 'Euro',
    'USD': 'Dollar américain',
    'GBP': 'Livre sterling',
    'GNF': 'Franc Guinéen',
    'XOF': 'Franc CFA (BCEAO)',
    'XAF': 'Franc CFA (BEAC)',
    'MAD': 'Dirham marocain',
    'TND': 'Dinar tunisien',
  };

  /// Formate un montant avec la devise
  static String format(
    double amount, {
    String currency = 'EUR',
    bool withSymbol = true,
  }) {
    final formatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: withSymbol ? currencySymbols[currency] ?? currency : '',
      decimalDigits: _getDecimalDigits(currency),
    );

    return formatter.format(amount);
  }

  /// Formate un montant en format compact (K, M, B)
  static String formatCompact(double amount, {String currency = 'EUR'}) {
    final symbol = currencySymbols[currency] ?? currency;

    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B $symbol';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M $symbol';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K $symbol';
    }

    return format(amount, currency: currency);
  }

  /// Obtient le symbole de la devise
  static String getSymbol(String currency) {
    return currencySymbols[currency] ?? currency;
  }

  /// Obtient le nom de la devise
  static String getName(String currency) {
    return currencyNames[currency] ?? currency;
  }

  /// Obtient le nombre de décimales pour une devise
  static int _getDecimalDigits(String currency) {
    // Les devises sans subdivision (comme le GNF) n'ont pas de décimales
    if (currency == 'GNF' || currency == 'XOF' || currency == 'XAF') {
      return 0;
    }
    return 2;
  }

  /// Parse une chaîne de montant en double
  static double? parse(String amountStr) {
    try {
      // Remplace les virgules par des points
      final cleaned = amountStr
          .replaceAll(RegExp(r'[^\d,.-]'), '')
          .replaceAll(',', '.');
      return double.parse(cleaned);
    } catch (e) {
      return null;
    }
  }

  /// Vérifie si le montant est valide
  static bool isValidAmount(String amountStr) {
    return parse(amountStr) != null;
  }

  /// Calcule le pourcentage d'un montant
  static double calculatePercentage(double amount, double total) {
    if (total == 0) return 0;
    return (amount / total) * 100;
  }

  /// Formate un pourcentage
  static String formatPercentage(double percentage, {int decimals = 1}) {
    return '${percentage.toStringAsFixed(decimals)}%';
  }
}
