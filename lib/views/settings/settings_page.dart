import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: ListView(
        padding: AppDimensions.paddingPage,
        children: [
          // Section Données
          _buildSectionHeader('Données'),
          _buildSettingTile(
            context,
            icon: Icons.category,
            title: 'Catégories',
            subtitle: 'Gérer les catégories',
            onTap: () => Navigator.pushNamed(context, '/categories'),
          ),
          _buildSettingTile(
            context,
            icon: Icons.account_balance,
            title: 'Comptes bancaires',
            subtitle: 'Gérer vos comptes',
            onTap: () => Navigator.pushNamed(context, '/accounts'),
          ),

          AppDimensions.verticalSpace(AppDimensions.space24),

          // Section Sauvegarde
          _buildSectionHeader('Sauvegarde'),
          _buildSettingTile(
            context,
            icon: Icons.backup,
            title: 'Sauvegarder',
            subtitle: 'Créer une sauvegarde',
            onTap: () => _showBackupDialog(context),
          ),
          _buildSettingTile(
            context,
            icon: Icons.restore,
            title: 'Restaurer',
            subtitle: 'Restaurer depuis une sauvegarde',
            onTap: () => _showRestoreDialog(context),
          ),

          AppDimensions.verticalSpace(AppDimensions.space24),

          // Section Préférences
          _buildSectionHeader('Préférences'),
          _buildSettingTile(
            context,
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Gérer les notifications',
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: AppColors.primary,
            ),
          ),
          _buildSettingTile(
            context,
            icon: Icons.dark_mode,
            title: 'Thème sombre',
            subtitle: 'Activer le mode sombre',
            trailing: Switch(
              value: false,
              onChanged: (value) {},
              activeColor: AppColors.primary,
            ),
          ),

          AppDimensions.verticalSpace(AppDimensions.space24),

          // Section Application
          _buildSectionHeader('Application'),
          _buildSettingTile(
            context,
            icon: Icons.info,
            title: 'À propos',
            subtitle: 'Version 1.0.0',
            onTap: () => _showAboutDialog(context),
          ),
          _buildSettingTile(
            context,
            icon: Icons.help,
            title: 'Aide',
            subtitle: 'Centre d\'aide et support',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      title: const Text('Paramètres'),
      elevation: 0,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.space8,
        bottom: AppDimensions.space12,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.space8),
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusCard,
      ),
      child: ListTile(
        contentPadding: AppDimensions.paddingCard,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSM),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: AppDimensions.iconMD,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        trailing:
            trailing ??
            (onTap != null
                ? const Icon(Icons.chevron_right, color: AppColors.textTertiary)
                : null),
        onTap: onTap,
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sauvegarder'),
        content: const Text(
          'Voulez-vous créer une sauvegarde de toutes vos données ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implémenter la sauvegarde
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Sauvegarde créée')));
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurer'),
        content: const Text(
          'Cette action remplacera toutes vos données actuelles. Continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implémenter la restauration
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Restaurer'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'BudgetBuddy',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 BudgetBuddy. Tous droits réservés.',
      children: [
        AppDimensions.verticalSpace(AppDimensions.space16),
        const Text(
          'Application de gestion budgétaire personnelle pour vous aider à mieux gérer vos finances.',
        ),
      ],
    );
  }
}
