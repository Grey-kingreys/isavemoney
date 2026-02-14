import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/app_button.dart';

/// Widget d'affichage d'erreur
class ErrorView extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final bool fullScreen;

  const ErrorView({
    super.key,
    this.title,
    this.message,
    this.onRetry,
    this.icon,
    this.fullScreen = true,
  });

  /// Erreur réseau
  factory ErrorView.network({VoidCallback? onRetry, bool fullScreen = true}) {
    return ErrorView(
      title: 'Erreur de connexion',
      message: 'Impossible de se connecter. Vérifiez votre connexion internet.',
      icon: Icons.wifi_off_rounded,
      onRetry: onRetry,
      fullScreen: fullScreen,
    );
  }

  /// Erreur serveur
  factory ErrorView.server({VoidCallback? onRetry, bool fullScreen = true}) {
    return ErrorView(
      title: 'Erreur serveur',
      message: 'Une erreur s\'est produite. Veuillez réessayer plus tard.',
      icon: Icons.error_outline_rounded,
      onRetry: onRetry,
      fullScreen: fullScreen,
    );
  }

  /// Erreur de chargement
  factory ErrorView.loading({
    String? message,
    VoidCallback? onRetry,
    bool fullScreen = true,
  }) {
    return ErrorView(
      title: 'Erreur de chargement',
      message: message ?? 'Impossible de charger les données.',
      icon: Icons.warning_amber_rounded,
      onRetry: onRetry,
      fullScreen: fullScreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Padding(
        padding: AppDimensions.paddingPage,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône
            Icon(
              icon ?? Icons.error_outline_rounded,
              size: AppDimensions.icon3XL,
              color: AppColors.error,
            ),

            AppDimensions.verticalSpace(AppDimensions.space24),

            // Titre
            Text(
              title ?? 'Une erreur est survenue',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            if (message != null) ...[
              AppDimensions.verticalSpace(AppDimensions.space12),
              Text(
                message!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Bouton retry
            if (onRetry != null) ...[
              AppDimensions.verticalSpace(AppDimensions.space32),
              AppButton.primary(
                text: 'Réessayer',
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );

    if (fullScreen) {
      return Scaffold(backgroundColor: AppColors.background, body: content);
    }

    return content;
  }
}

/// Widget d'erreur compact (pour les cartes)
class ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorCard({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusCard,
      ),
      child: Padding(
        padding: AppDimensions.paddingCard,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: AppDimensions.iconXL,
              color: AppColors.error,
            ),
            AppDimensions.verticalSpace(AppDimensions.space12),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              AppDimensions.verticalSpace(AppDimensions.space16),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Réessayer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
