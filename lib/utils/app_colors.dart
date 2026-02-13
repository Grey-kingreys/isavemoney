import 'package:flutter/material.dart';

/// Palette de couleurs de l'application BudgetBuddy
/// Design moderne avec support du mode clair et sombre
class AppColors {
  AppColors._(); // Constructeur privé pour empêcher l'instanciation

  // ==================== COULEURS PRINCIPALES ====================

  /// Couleur principale de l'application (Purple moderne)
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4339F2);

  /// Couleur secondaire (Turquoise/Cyan)
  static const Color secondary = Color(0xFF4ECDC4);
  static const Color secondaryLight = Color(0xFF7EDDD6);
  static const Color secondaryDark = Color(0xFF2EADA3);

  /// Couleur d'accent (Corail/Rose)
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentLight = Color(0xFFFF9B9B);
  static const Color accentDark = Color(0xFFE64A4A);

  // ==================== COULEURS DE STATUT ====================

  /// Couleur de succès (Vert)
  static const Color success = Color(0xFF2ECC71);
  static const Color successLight = Color(0xFF58D68D);
  static const Color successDark = Color(0xFF27AE60);

  /// Couleur d'avertissement (Orange)
  static const Color warning = Color(0xFFF39C12);
  static const Color warningLight = Color(0xFFF5B041);
  static const Color warningDark = Color(0xFFE67E22);

  /// Couleur d'erreur (Rouge)
  static const Color error = Color(0xFFE74C3C);
  static const Color errorLight = Color(0xFFEC7063);
  static const Color errorDark = Color(0xFFC0392B);

  /// Couleur d'information (Bleu)
  static const Color info = Color(0xFF3498DB);
  static const Color infoLight = Color(0xFF5DADE2);
  static const Color infoDark = Color(0xFF2980B9);

  // ==================== COULEURS NEUTRES ====================

  /// Blancs et gris clairs
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF7F8FA);
  static const Color backgroundLight = Color(0xFFFCFCFC);
  static const Color surface = Color(0xFFFFFFFF);

  /// Gris
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  /// Noirs et gris foncés
  static const Color black = Color(0xFF000000);
  static const Color blackLight = Color(0xFF1A1A1A);
  static const Color blackSoft = Color(0xFF2C2C2C);

  // ==================== COULEURS DE TEXTE ====================

  /// Texte principal
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textTertiary = Color(0xFFBDC3C7);
  static const Color textDisabled = Color(0xFFCFD8DC);

  /// Texte sur fond sombre
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ==================== COULEURS SPÉCIFIQUES ====================

  /// Revenus (Vert)
  static const Color income = Color(0xFF2ECC71);
  static const Color incomeLight = Color(0xFFE8F8F5);
  static const Color incomeDark = Color(0xFF27AE60);

  /// Dépenses (Rouge/Orange)
  static const Color expense = Color(0xFFE74C3C);
  static const Color expenseLight = Color(0xFFFDEDEC);
  static const Color expenseDark = Color(0xFFC0392B);

  /// Épargne (Bleu)
  static const Color savings = Color(0xFF3498DB);
  static const Color savingsLight = Color(0xFFEBF5FB);
  static const Color savingsDark = Color(0xFF2980B9);

  /// Budget
  static const Color budget = Color(0xFF9B59B6);
  static const Color budgetLight = Color(0xFFF4ECF7);
  static const Color budgetDark = Color(0xFF8E44AD);

  // ==================== COULEURS DES GRAPHIQUES ====================

  static const List<Color> chartColors = [
    Color(0xFF6C63FF), // Purple
    Color(0xFF4ECDC4), // Turquoise
    Color(0xFFFF6B6B), // Coral
    Color(0xFF2ECC71), // Green
    Color(0xFFF39C12), // Orange
    Color(0xFF9B59B6), // Purple Light
    Color(0xFF3498DB), // Blue
    Color(0xFFE74C3C), // Red
    Color(0xFF1ABC9C), // Teal
    Color(0xFFE67E22), // Dark Orange
  ];

  // ==================== DÉGRADÉS ====================

  /// Dégradé principal
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  /// Dégradé secondaire
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryDark],
  );

  /// Dégradé succès
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [successLight, successDark],
  );

  /// Dégradé doux
  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF7F8FA), Color(0xFFFFFFFF)],
  );

  /// Dégradé revenus
  static const LinearGradient incomeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [incomeLight, income],
  );

  /// Dégradé dépenses
  static const LinearGradient expenseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [expenseLight, expense],
  );

  // ==================== OPACITÉS ====================

  /// Opacité pour les overlays
  static const double overlayLight = 0.05;
  static const double overlayMedium = 0.10;
  static const double overlayStrong = 0.20;

  /// Opacité pour les ombres
  static const double shadowLight = 0.08;
  static const double shadowMedium = 0.15;
  static const double shadowStrong = 0.25;

  // ==================== COULEURS THÈME SOMBRE ====================

  /// Fond sombre
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkBackgroundLight = Color(0xFF1E1E1E);
  static const Color darkSurface = Color(0xFF2C2C2C);
  static const Color darkSurfaceLight = Color(0xFF383838);

  /// Texte sur fond sombre
  static const Color darkTextPrimary = Color(0xFFE1E1E1);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextTertiary = Color(0xFF808080);

  // ==================== MÉTHODES UTILITAIRES ====================

  /// Obtient une couleur avec opacité
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Obtient une couleur plus claire
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Obtient une couleur plus foncée
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Convertit une couleur hex en Color
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Convertit une Color en hex
  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}
