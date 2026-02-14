import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';

/// Page de sauvegarde et restauration (PLACEHOLDER - ÉTAPE 5)
class SavingsGoalsPage extends StatelessWidget {
  const SavingsGoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Sauvegarde')),
      body: ListView(
        padding: AppDimensions.paddingPage,
        children: [
          _buildInfoCard(),
          AppDimensions.verticalSpace(AppDimensions.space24),
          _buildBackupSection(context),
          AppDimensions.verticalSpace(AppDimensions.space24),
          _buildRestoreSection(context),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: AppDimensions.cardElevation,
      color: AppColors.infoLight,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusCard,
      ),
      child: Padding(
        padding: AppDimensions.paddingCard,
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.info,
              size: AppDimensions.iconLG,
            ),
            AppDimensions.horizontalSpace(AppDimensions.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sauvegarde automatique',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppDimensions.verticalSpace(AppDimensions.space4),
                  Text(
                    'Vos données sont automatiquement\nsauvegardées localement.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupSection(BuildContext context) {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusCard,
      ),
      child: Padding(
        padding: AppDimensions.paddingCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: AppDimensions.borderRadiusSM,
                  ),
                  child: Icon(
                    Icons.backup,
                    color: AppColors.success,
                    size: AppDimensions.iconLG,
                  ),
                ),
                AppDimensions.horizontalSpace(AppDimensions.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Créer une sauvegarde',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppDimensions.verticalSpace(AppDimensions.space4),
                      Text(
                        'Exportez vos données',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppDimensions.verticalSpace(AppDimensions.space16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showComingSoon(context),
                icon: const Icon(Icons.save_alt),
                label: const Text('Créer une sauvegarde'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestoreSection(BuildContext context) {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusCard,
      ),
      child: Padding(
        padding: AppDimensions.paddingCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: AppDimensions.borderRadiusSM,
                  ),
                  child: Icon(
                    Icons.restore,
                    color: AppColors.warning,
                    size: AppDimensions.iconLG,
                  ),
                ),
                AppDimensions.horizontalSpace(AppDimensions.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Restaurer une sauvegarde',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppDimensions.verticalSpace(AppDimensions.space4),
                      Text(
                        'Importez vos données',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppDimensions.verticalSpace(AppDimensions.space16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showComingSoon(context),
                icon: const Icon(Icons.folder_open),
                label: const Text('Choisir un fichier'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bientôt disponible'),
        content: const Text(
          'La fonctionnalité de sauvegarde/restauration\n'
          'sera disponible à l\'ÉTAPE 5.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
