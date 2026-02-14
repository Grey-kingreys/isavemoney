import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/app_button.dart';

/// Widget d'affichage d'état vide
class EmptyView extends StatelessWidget {
  final String? title;
  final String? message;
  final String? emoji;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionLabel;
  final bool fullScreen;

  const EmptyView({
    super.key,
    this.title,
    this.message,
    this.emoji,
    this.icon,
    this.onAction,
    this.actionLabel,
    this.fullScreen = true,
  });

  /// Aucune transaction
  factory EmptyView.noTransactions({
    VoidCallback? onAction,
    bool fullScreen = true,
  }) {
    return EmptyView(
      emoji: '📝',
      title: 'Aucune transaction',
      message: 'Commencez à enregistrer vos revenus et dépenses',
      actionLabel: 'Ajouter une transaction',
      onAction: onAction,
      fullScreen: fullScreen,
    );
  }

  /// Aucun budget
  factory EmptyView.noBudgets({
    VoidCallback? onAction,
    bool fullScreen = true,
  }) {
    return EmptyView(
      emoji: '🎯',
      title: 'Aucun budget',
      message: 'Créez des budgets pour mieux contrôler vos dépenses',
      actionLabel: 'Créer un budget',
      onAction: onAction,
      fullScreen: fullScreen,
    );
  }

  /// Aucune catégorie
  factory EmptyView.noCategories({
    VoidCallback? onAction,
    bool fullScreen = true,
  }) {
    return EmptyView(
      emoji: '🏷️',
      title: 'Aucune catégorie',
      message: 'Ajoutez des catégories pour organiser vos transactions',
      actionLabel: 'Ajouter une catégorie',
      onAction: onAction,
      fullScreen: fullScreen,
    );
  }

  /// Aucun résultat de recherche
  factory EmptyView.noSearchResults({bool fullScreen = true}) {
    return EmptyView(
      emoji: '🔍',
      title: 'Aucun résultat',
      message: 'Essayez avec d\'autres mots-clés',
      fullScreen: fullScreen,
    );
  }

  /// Aucune donnée
  factory EmptyView.noData({
    String? title,
    String? message,
    bool fullScreen = true,
  }) {
    return EmptyView(
      emoji: '📊',
      title: title ?? 'Aucune donnée',
      message: message ?? 'Les données apparaîtront ici',
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
            // Emoji ou Icône
            if (emoji != null)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(emoji!, style: const TextStyle(fontSize: 60)),
                ),
              )
            else if (icon != null)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: AppDimensions.icon3XL,
                  color: AppColors.textTertiary,
                ),
              ),

            AppDimensions.verticalSpace(AppDimensions.space24),

            // Titre
            Text(
              title ?? 'Aucune donnée',
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

            // Bouton d'action
            if (onAction != null && actionLabel != null) ...[
              AppDimensions.verticalSpace(AppDimensions.space32),
              AppButton.primary(
                text: actionLabel!,
                icon: Icons.add_rounded,
                onPressed: onAction,
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

/// Widget empty compact (pour les cartes)
class EmptyCard extends StatelessWidget {
  final String message;
  final String? emoji;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyCard({
    super.key,
    required this.message,
    this.emoji,
    this.icon,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusCard,
      ),
      child: Padding(
        padding: AppDimensions.padding2XL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji ou Icône
            if (emoji != null)
              Text(emoji!, style: const TextStyle(fontSize: 48))
            else if (icon != null)
              Icon(
                icon,
                size: AppDimensions.icon2XL,
                color: AppColors.textTertiary,
              ),

            AppDimensions.verticalSpace(AppDimensions.space16),

            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            if (onAction != null && actionLabel != null) ...[
              AppDimensions.verticalSpace(AppDimensions.space16),
              TextButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
