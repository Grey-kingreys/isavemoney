import 'package:flutter/material.dart';

/// Dimensions et espacements de l'application BudgetBuddy
/// Système cohérent basé sur une échelle de 4px
class AppDimensions {
  AppDimensions._(); // Constructeur privé

  // ==================== SYSTÈME D'ESPACEMENT (4px base) ====================

  /// Espacement minimal (4px)
  static const double space4 = 4.0;

  /// Espacement très petit (8px)
  static const double space8 = 8.0;

  /// Espacement petit (12px)
  static const double space12 = 12.0;

  /// Espacement moyen (16px)
  static const double space16 = 16.0;

  /// Espacement moyen-large (20px)
  static const double space20 = 20.0;

  /// Espacement large (24px)
  static const double space24 = 24.0;

  /// Espacement très large (32px)
  static const double space32 = 32.0;

  /// Espacement extra large (40px)
  static const double space40 = 40.0;

  /// Espacement énorme (48px)
  static const double space48 = 48.0;

  /// Espacement massif (64px)
  static const double space64 = 64.0;

  /// Espacement géant (80px)
  static const double space80 = 80.0;

  // ==================== PADDING ====================

  /// Padding minimal
  static const EdgeInsets paddingXS = EdgeInsets.all(space4);

  /// Padding très petit
  static const EdgeInsets paddingSM = EdgeInsets.all(space8);

  /// Padding petit
  static const EdgeInsets paddingMD = EdgeInsets.all(space12);

  /// Padding moyen (défaut)
  static const EdgeInsets paddingLG = EdgeInsets.all(space16);

  /// Padding large
  static const EdgeInsets paddingXL = EdgeInsets.all(space24);

  /// Padding très large
  static const EdgeInsets padding2XL = EdgeInsets.all(space32);

  /// Padding énorme
  static const EdgeInsets padding3XL = EdgeInsets.all(space48);

  // Padding horizontal
  static const EdgeInsets paddingHorizontalXS = EdgeInsets.symmetric(
    horizontal: space4,
  );
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(
    horizontal: space8,
  );
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(
    horizontal: space12,
  );
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(
    horizontal: space16,
  );
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(
    horizontal: space24,
  );
  static const EdgeInsets paddingHorizontal2XL = EdgeInsets.symmetric(
    horizontal: space32,
  );

  // Padding vertical
  static const EdgeInsets paddingVerticalXS = EdgeInsets.symmetric(
    vertical: space4,
  );
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(
    vertical: space8,
  );
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(
    vertical: space12,
  );
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(
    vertical: space16,
  );
  static const EdgeInsets paddingVerticalXL = EdgeInsets.symmetric(
    vertical: space24,
  );
  static const EdgeInsets paddingVertical2XL = EdgeInsets.symmetric(
    vertical: space32,
  );

  // Padding de page
  static const EdgeInsets paddingPage = EdgeInsets.all(space16);
  static const EdgeInsets paddingPageHorizontal = EdgeInsets.symmetric(
    horizontal: space16,
  );
  static const EdgeInsets paddingPageVertical = EdgeInsets.symmetric(
    vertical: space16,
  );

  // Padding de carte
  static const EdgeInsets paddingCard = EdgeInsets.all(space16);
  static const EdgeInsets paddingCardSmall = EdgeInsets.all(space12);
  static const EdgeInsets paddingCardLarge = EdgeInsets.all(space24);

  // ==================== MARGIN ====================

  /// Margin minimal
  static const EdgeInsets marginXS = EdgeInsets.all(space4);

  /// Margin très petit
  static const EdgeInsets marginSM = EdgeInsets.all(space8);

  /// Margin petit
  static const EdgeInsets marginMD = EdgeInsets.all(space12);

  /// Margin moyen (défaut)
  static const EdgeInsets marginLG = EdgeInsets.all(space16);

  /// Margin large
  static const EdgeInsets marginXL = EdgeInsets.all(space24);

  /// Margin très large
  static const EdgeInsets margin2XL = EdgeInsets.all(space32);

  // ==================== BORDER RADIUS ====================

  /// Pas de bordure arrondie
  static const double radiusNone = 0.0;

  /// Bordure légèrement arrondie (4px)
  static const double radiusXS = 4.0;

  /// Bordure arrondie petite (8px)
  static const double radiusSM = 8.0;

  /// Bordure arrondie moyenne (12px)
  static const double radiusMD = 12.0;

  /// Bordure arrondie standard (16px)
  static const double radiusLG = 16.0;

  /// Bordure arrondie large (20px)
  static const double radiusXL = 20.0;

  /// Bordure arrondie très large (24px)
  static const double radius2XL = 24.0;

  /// Bordure arrondie énorme (32px)
  static const double radius3XL = 32.0;

  /// Bordure complètement arrondie (circulaire)
  static const double radiusFull = 999.0;

  // BorderRadius objets
  static const BorderRadius borderRadiusXS = BorderRadius.all(
    Radius.circular(radiusXS),
  );
  static const BorderRadius borderRadiusSM = BorderRadius.all(
    Radius.circular(radiusSM),
  );
  static const BorderRadius borderRadiusMD = BorderRadius.all(
    Radius.circular(radiusMD),
  );
  static const BorderRadius borderRadiusLG = BorderRadius.all(
    Radius.circular(radiusLG),
  );
  static const BorderRadius borderRadiusXL = BorderRadius.all(
    Radius.circular(radiusXL),
  );
  static const BorderRadius borderRadius2XL = BorderRadius.all(
    Radius.circular(radius2XL),
  );
  static const BorderRadius borderRadius3XL = BorderRadius.all(
    Radius.circular(radius3XL),
  );
  static const BorderRadius borderRadiusFull = BorderRadius.all(
    Radius.circular(radiusFull),
  );

  // BorderRadius pour des éléments spécifiques
  static const BorderRadius borderRadiusCard = borderRadiusLG;
  static const BorderRadius borderRadiusButton = borderRadiusMD;
  static const BorderRadius borderRadiusInput = borderRadiusMD;
  static const BorderRadius borderRadiusDialog = borderRadiusXL;
  static const BorderRadius borderRadiusBottomSheet = BorderRadius.vertical(
    top: Radius.circular(radius2XL),
  );

  // ==================== ICON SIZES ====================

  /// Icône très petite (16px)
  static const double iconXS = 16.0;

  /// Icône petite (20px)
  static const double iconSM = 20.0;

  /// Icône moyenne (24px) - Standard Material
  static const double iconMD = 24.0;

  /// Icône large (32px)
  static const double iconLG = 32.0;

  /// Icône très large (40px)
  static const double iconXL = 40.0;

  /// Icône énorme (48px)
  static const double icon2XL = 48.0;

  /// Icône géante (64px)
  static const double icon3XL = 64.0;

  /// Icône massive (80px)
  static const double icon4XL = 80.0;

  // ==================== BUTTON SIZES ====================

  /// Hauteur du bouton petit
  static const double buttonHeightSM = 36.0;

  /// Hauteur du bouton moyen (défaut)
  static const double buttonHeightMD = 48.0;

  /// Hauteur du bouton large
  static const double buttonHeightLG = 56.0;

  /// Largeur minimale du bouton
  static const double buttonMinWidth = 88.0;

  /// Padding horizontal du bouton
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: space24,
    vertical: space12,
  );

  /// Padding du bouton petit
  static const EdgeInsets buttonPaddingSM = EdgeInsets.symmetric(
    horizontal: space16,
    vertical: space8,
  );

  /// Padding du bouton large
  static const EdgeInsets buttonPaddingLG = EdgeInsets.symmetric(
    horizontal: space32,
    vertical: space16,
  );

  // ==================== INPUT SIZES ====================

  /// Hauteur du champ de saisie
  static const double inputHeight = 56.0;

  /// Hauteur du champ de saisie petit
  static const double inputHeightSM = 48.0;

  /// Hauteur du champ de saisie large
  static const double inputHeightLG = 64.0;

  /// Padding du champ de saisie
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: space16,
    vertical: space12,
  );

  // ==================== CARD SIZES ====================

  /// Élévation de carte par défaut
  static const double cardElevation = 2.0;

  /// Élévation de carte au survol
  static const double cardElevationHover = 4.0;

  /// Élévation de carte pressée
  static const double cardElevationPressed = 1.0;

  /// Hauteur minimale d'une carte
  static const double cardMinHeight = 80.0;

  // ==================== DIVIDER ====================

  /// Épaisseur du séparateur
  static const double dividerThickness = 1.0;

  /// Épaisseur du séparateur épais
  static const double dividerThicknessBold = 2.0;

  /// Indentation du séparateur
  static const double dividerIndent = space16;

  // ==================== BORDER WIDTH ====================

  /// Bordure fine
  static const double borderThin = 1.0;

  /// Bordure moyenne
  static const double borderMedium = 2.0;

  /// Bordure épaisse
  static const double borderThick = 3.0;

  /// Bordure très épaisse
  static const double borderExtraThick = 4.0;

  // ==================== APPBAR ====================

  /// Hauteur de l'AppBar
  static const double appBarHeight = 56.0;

  /// Hauteur de l'AppBar large
  static const double appBarHeightLarge = 64.0;

  /// Élévation de l'AppBar
  static const double appBarElevation = 0.0;

  // ==================== BOTTOM NAVIGATION ====================

  /// Hauteur de la bottom navigation
  static const double bottomNavHeight = 64.0;

  /// Hauteur de la bottom navigation compacte
  static const double bottomNavHeightCompact = 56.0;

  // ==================== FAB (Floating Action Button) ====================

  /// Taille du FAB standard
  static const double fabSize = 56.0;

  /// Taille du FAB petit
  static const double fabSizeSM = 40.0;

  /// Taille du FAB large
  static const double fabSizeLG = 64.0;

  // ==================== DIALOG ====================

  /// Largeur maximale du dialog
  static const double dialogMaxWidth = 400.0;

  /// Largeur minimale du dialog
  static const double dialogMinWidth = 280.0;

  /// Padding du dialog
  static const EdgeInsets dialogPadding = EdgeInsets.all(space24);

  // ==================== BOTTOM SHEET ====================

  /// Hauteur maximale du bottom sheet
  static const double bottomSheetMaxHeight = 0.9; // 90% de l'écran

  /// Padding du bottom sheet
  static const EdgeInsets bottomSheetPadding = EdgeInsets.all(space24);

  // ==================== CHART ====================

  /// Hauteur du graphique petit
  static const double chartHeightSM = 150.0;

  /// Hauteur du graphique moyen
  static const double chartHeightMD = 200.0;

  /// Hauteur du graphique large
  static const double chartHeightLG = 300.0;

  // ==================== AVATAR ====================

  /// Taille de l'avatar très petit
  static const double avatarXS = 24.0;

  /// Taille de l'avatar petit
  static const double avatarSM = 32.0;

  /// Taille de l'avatar moyen
  static const double avatarMD = 40.0;

  /// Taille de l'avatar large
  static const double avatarLG = 56.0;

  /// Taille de l'avatar très large
  static const double avatarXL = 80.0;

  // ==================== MÉTHODES UTILITAIRES ====================

  /// Crée un EdgeInsets personnalisé
  static EdgeInsets custom({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    if (all != null) {
      return EdgeInsets.all(all);
    }
    if (horizontal != null || vertical != null) {
      return EdgeInsets.symmetric(
        horizontal: horizontal ?? 0,
        vertical: vertical ?? 0,
      );
    }
    return EdgeInsets.only(
      top: top ?? 0,
      bottom: bottom ?? 0,
      left: left ?? 0,
      right: right ?? 0,
    );
  }

  /// Crée un BorderRadius personnalisé
  static BorderRadius customRadius({
    double? all,
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
  }) {
    if (all != null) {
      return BorderRadius.all(Radius.circular(all));
    }
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft ?? 0),
      topRight: Radius.circular(topRight ?? 0),
      bottomLeft: Radius.circular(bottomLeft ?? 0),
      bottomRight: Radius.circular(bottomRight ?? 0),
    );
  }

  /// Crée un SizedBox avec espacement vertical
  static SizedBox verticalSpace(double height) => SizedBox(height: height);

  /// Crée un SizedBox avec espacement horizontal
  static SizedBox horizontalSpace(double width) => SizedBox(width: width);
}
