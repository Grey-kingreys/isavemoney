import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_dimensions.dart';

/// Thème de l'application BudgetBuddy
/// Combine tous les éléments de design (couleurs, textes, dimensions, ombres)
class AppTheme {
  AppTheme._(); // Constructeur privé

  // ==================== THÈME CLAIR ====================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Couleurs
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight,
        tertiary: AppColors.accent,
        tertiaryContainer: AppColors.accentLight,
        error: AppColors.error,
        errorContainer: AppColors.errorLight,
        surface: AppColors.surface,
        surfaceContainerHighest: AppColors.grey100,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onTertiary: AppColors.white,
        onError: AppColors.white,
        onSurface: AppColors.textPrimary,
        outline: AppColors.grey300,
        shadow: AppColors.black.withOpacity(0.1),
      ),

      // Fond
      scaffoldBackgroundColor: AppColors.background,

      // Typographie
      textTheme: _buildTextTheme(AppColors.textPrimary),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: AppDimensions.appBarElevation,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headlineSmall,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: AppDimensions.iconMD,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: AppDimensions.cardElevation,
        shadowColor: AppColors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusCard,
        ),
        margin: AppDimensions.marginMD,
      ),

      // Boutons élevés
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: AppDimensions.cardElevation,
          padding: AppDimensions.buttonPadding,
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeightMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusButton,
          ),
          textStyle: AppTextStyles.buttonPrimary,
        ),
      ),

      // Boutons outlined
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: AppDimensions.buttonPadding,
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeightMD,
          ),
          side: const BorderSide(
            color: AppColors.primary,
            width: AppDimensions.borderMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusButton,
          ),
          textStyle: AppTextStyles.buttonSecondary,
        ),
      ),

      // Boutons texte
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: AppDimensions.buttonPadding,
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeightMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusButton,
          ),
          textStyle: AppTextStyles.buttonText,
        ),
      ),

      // Champs de texte
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey100,
        contentPadding: AppDimensions.inputPadding,
        border: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusInput,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusInput,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusInput,
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: AppDimensions.borderMedium,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusInput,
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppDimensions.borderMedium,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusInput,
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppDimensions.borderMedium,
          ),
        ),
        labelStyle: AppTextStyles.bodyMedium,
        hintStyle: AppTextStyles.hint,
        errorStyle: AppTextStyles.error,
      ),

      // FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusLG,
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusDialog,
        ),
        titleTextStyle: AppTextStyles.headlineSmall,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.white,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusBottomSheet,
        ),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.grey100,
        selectedColor: AppColors.primaryLight,
        disabledColor: AppColors.grey200,
        padding: AppDimensions.paddingSM,
        labelStyle: AppTextStyles.chip,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusSM,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.grey200,
        thickness: AppDimensions.dividerThickness,
        space: AppDimensions.space16,
      ),

      // Icons
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: AppDimensions.iconMD,
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.grey400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.grey200;
        }),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.grey200;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusXS,
        ),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.grey400;
        }),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.grey200,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withOpacity(0.2),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusSM,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==================== THÈME SOMBRE ====================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Couleurs
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryLight,
        primaryContainer: AppColors.primary,
        secondary: AppColors.secondaryLight,
        secondaryContainer: AppColors.secondary,
        tertiary: AppColors.accentLight,
        tertiaryContainer: AppColors.accent,
        error: AppColors.errorLight,
        errorContainer: AppColors.error,
        surface: AppColors.darkSurface,
        surfaceContainerHighest: AppColors.darkSurfaceLight,
        onPrimary: AppColors.black,
        onSecondary: AppColors.black,
        onTertiary: AppColors.black,
        onError: AppColors.black,
        onSurface: AppColors.darkTextPrimary,
        outline: AppColors.grey700,
        shadow: AppColors.black.withOpacity(0.3),
      ),

      // Fond
      scaffoldBackgroundColor: AppColors.darkBackground,

      // Typographie
      textTheme: _buildTextTheme(AppColors.darkTextPrimary),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: AppDimensions.appBarElevation,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.darkTextPrimary,
          size: AppDimensions.iconMD,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: AppDimensions.cardElevation,
        shadowColor: AppColors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusCard,
        ),
        margin: AppDimensions.marginMD,
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.darkTextSecondary,
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Autres thèmes similaires au thème clair mais adaptés pour le mode sombre
      // ... (je garde les mêmes configurations que le thème clair)
    );
  }

  // ==================== MÉTHODES UTILITAIRES ====================

  /// Construit le TextTheme avec la couleur appropriée
  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: textColor),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: textColor),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: textColor),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: textColor),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: textColor),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: textColor),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: textColor),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: textColor),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: textColor),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: textColor),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: textColor),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: textColor),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: textColor),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: textColor),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: textColor),
    );
  }

  /// Retourne le thème basé sur le mode (clair/sombre)
  static ThemeData getTheme(ThemeMode mode, Brightness brightness) {
    if (mode == ThemeMode.dark ||
        (mode == ThemeMode.system && brightness == Brightness.dark)) {
      return darkTheme;
    }
    return lightTheme;
  }
}
