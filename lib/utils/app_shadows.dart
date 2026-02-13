import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Ombres et élévations de l'application BudgetBuddy
/// Système cohérent pour donner de la profondeur aux éléments
class AppShadows {
  AppShadows._(); // Constructeur privé

  // ==================== OMBRES DE BASE ====================

  /// Ombre très légère (élévation 1)
  static List<BoxShadow> get shadowXS => [
    BoxShadow(
      color: AppColors.black.withOpacity(0.05),
      offset: const Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  /// Ombre légère (élévation 2)
  static List<BoxShadow> get shadowSM => [
    BoxShadow(
      color: AppColors.black.withOpacity(0.08),
      offset: const Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  /// Ombre moyenne (élévation 4)
  static List<BoxShadow> get shadowMD => [
    BoxShadow(
      color: AppColors.black.withOpacity(0.10),
      offset: const Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  /// Ombre large (élévation 8)
  static List<BoxShadow> get shadowLG => [
    BoxShadow(
      color: AppColors.black.withOpacity(0.12),
      offset: const Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  /// Ombre très large (élévation 12)
  static List<BoxShadow> get shadowXL => [
    BoxShadow(
      color: AppColors.black.withOpacity(0.15),
      offset: const Offset(0, 12),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];

  /// Ombre énorme (élévation 16)
  static List<BoxShadow> get shadow2XL => [
    BoxShadow(
      color: AppColors.black.withOpacity(0.18),
      offset: const Offset(0, 16),
      blurRadius: 32,
      spreadRadius: 0,
    ),
  ];

  /// Ombre massive (élévation 24)
  static List<BoxShadow> get shadow3XL => [
    BoxShadow(
      color: AppColors.black.withOpacity(0.20),
      offset: const Offset(0, 24),
      blurRadius: 48,
      spreadRadius: 0,
    ),
  ];

  // ==================== OMBRES AVEC COULEUR ====================

  /// Ombre avec couleur primaire
  static List<BoxShadow> get shadowPrimary => [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.25),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  /// Ombre avec couleur secondaire
  static List<BoxShadow> get shadowSecondary => [
    BoxShadow(
      color: AppColors.secondary.withOpacity(0.25),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  /// Ombre avec couleur de succès
  static List<BoxShadow> get shadowSuccess => [
    BoxShadow(
      color: AppColors.success.withOpacity(0.25),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  /// Ombre avec couleur d'erreur
  static List<BoxShadow> get shadowError => [
    BoxShadow(
      color: AppColors.error.withOpacity(0.25),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  /// Ombre avec couleur d'avertissement
  static List<BoxShadow> get shadowWarning => [
    BoxShadow(
      color: AppColors.warning.withOpacity(0.25),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  // ==================== OMBRES SPÉCIFIQUES ====================

  /// Ombre pour les cartes
  static List<BoxShadow> get shadowCard => [
    BoxShadow(
      color: AppColors.black.withOpacity(0.08),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.black.withOpacity(0.04),
      offset: const Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  /// Ombre pour les cartes au survol
  static List<BoxShadow> get shadowCardHover => [
    BoxShadow(
      color: AppColors.black.withOpacity(0.10),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.black.withOpacity(0.06),
      offset: const Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];

  /// Ombre pour les boutons
  static List<BoxShadow> get shadowButton => [
    BoxShadow(
      color: AppColors.black.withOpacity(0.10),
      offset: const Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  /// Ombre pour les boutons au survol
  static List<BoxShadow> get shadowButtonHover => [
    BoxShadow(
      color: AppColors.black.withOpacity(0.15),
      offset: const Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  /// Ombre pour les boutons pressés
  static List<BoxShadow> get shadowButtonPressed => [
    BoxShadow(
      color: AppColors.black.withOpacity(0.08),
      offset: const Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  /// Ombre pour le FAB (Floating Action Button)
  static List<BoxShadow> get shadowFAB => [
    BoxShadow(
      color: AppColors.black.withOpacity(0.12),
      offset: const Offset(0, 6),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.black.withOpacity(0.08),
      offset: const Offset(0, 3),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];

  /// Ombre pour les dialogs
  static List<BoxShadow> get shadowDialog => [
    BoxShadow(
      color: AppColors.black.withOpacity(0.15),
      offset: const Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.black.withOpacity(0.10),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  /// Ombre pour les bottom sheets
  static List<BoxShadow> get shadowBottomSheet => [
    BoxShadow(
      color: AppColors.black.withOpacity(0.20),
      offset: const Offset(0, -4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  /// Ombre pour les dropdowns/menus
  static List<BoxShadow> get shadowDropdown => [
    BoxShadow(
      color: AppColors.black.withOpacity(0.12),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  /// Ombre pour les tooltips
  static List<BoxShadow> get shadowTooltip => [
    BoxShadow(
      color: AppColors.black.withOpacity(0.20),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  // ==================== OMBRES INTERNES ====================

  /// Ombre interne légère
  static List<BoxShadow> get innerShadowSM => [
    BoxShadow(
      color: AppColors.black.withOpacity(0.05),
      offset: const Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -2,
    ),
  ];

  /// Ombre interne moyenne
  static List<BoxShadow> get innerShadowMD => [
    BoxShadow(
      color: AppColors.black.withOpacity(0.08),
      offset: const Offset(0, 4),
      blurRadius: 8,
      spreadRadius: -4,
    ),
  ];

  // ==================== OMBRES DE TEXTE ====================

  /// Ombre de texte légère
  static List<Shadow> get textShadowSM => [
    Shadow(
      color: AppColors.black.withOpacity(0.25),
      offset: const Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  /// Ombre de texte moyenne
  static List<Shadow> get textShadowMD => [
    Shadow(
      color: AppColors.black.withOpacity(0.30),
      offset: const Offset(0, 2),
      blurRadius: 4,
    ),
  ];

  /// Ombre de texte forte
  static List<Shadow> get textShadowLG => [
    Shadow(
      color: AppColors.black.withOpacity(0.40),
      offset: const Offset(0, 4),
      blurRadius: 8,
    ),
  ];

  // ==================== OMBRES POUR THÈME SOMBRE ====================

  /// Ombre légère pour mode sombre
  static List<BoxShadow> get shadowDarkSM => [
    BoxShadow(
      color: AppColors.black.withOpacity(0.20),
      offset: const Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  /// Ombre moyenne pour mode sombre
  static List<BoxShadow> get shadowDarkMD => [
    BoxShadow(
      color: AppColors.black.withOpacity(0.25),
      offset: const Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  /// Ombre large pour mode sombre
  static List<BoxShadow> get shadowDarkLG => [
    BoxShadow(
      color: AppColors.black.withOpacity(0.30),
      offset: const Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  // ==================== MÉTHODES UTILITAIRES ====================

  /// Crée une ombre personnalisée
  static List<BoxShadow> custom({
    required Color color,
    required double opacity,
    required Offset offset,
    required double blurRadius,
    double spreadRadius = 0,
  }) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        offset: offset,
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
    ];
  }

  /// Crée une ombre de couleur personnalisée
  static List<BoxShadow> colored({
    required Color color,
    double opacity = 0.25,
    Offset offset = const Offset(0, 4),
    double blurRadius = 12,
    double spreadRadius = 0,
  }) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        offset: offset,
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
    ];
  }

  /// Crée une ombre avec élévation
  static List<BoxShadow> elevation(double elevation) {
    if (elevation <= 0) return [];
    if (elevation <= 2) return shadowXS;
    if (elevation <= 4) return shadowSM;
    if (elevation <= 8) return shadowMD;
    if (elevation <= 12) return shadowLG;
    if (elevation <= 16) return shadowXL;
    if (elevation <= 24) return shadow2XL;
    return shadow3XL;
  }

  /// Obtient une ombre sans ombre (pour désactiver)
  static List<BoxShadow> get none => [];
}
