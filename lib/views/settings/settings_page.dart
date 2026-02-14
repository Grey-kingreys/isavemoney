import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../app/routes.dart';

/// Page de paramètres (PLACEHOLDER - ÉTAPE 5)
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: AppDimensions.paddingPage,
        children: [
          _buildSection(
            title: 'GÉNÉRAL',
            children: [
              _buildSettingTile(
                icon: Icons.category,
                title: 'Catégories',
                subtitle: 'Gérer vos catégories',
                onTap: () {
                  AppRoutes.navigateTo(context, AppRoutes.settingsCategories);
                },
              ),
              _buildSettingTile(
                icon: Icons.account_balance,
                title: 'Comptes bancaires',
                subtitle: 'Gérer vos comptes',
                onTap: () {
                  AppRoutes.navigateTo(context, AppRoutes.settingsAccounts);
                },
              ),
            ],
          ),
          AppDimensions.verticalSpace(AppDimensions.space24),
          _buildSection(
            title: 'DONNÉES',
            children: [
              _buildSettingTile(
                icon: Icons.backup,
                title: 'Sauvegarde',
                subtitle: 'Sauvegarder et restaurer',
                onTap: () {
                  AppRoutes.navigateTo(context, AppRoutes.settingsBackup);
                },
              ),
              _buildSettingTile(
                icon: Icons.download,
                title: 'Export CSV',
                subtitle: 'Exporter vos données',
                onTap: () {
                  _showComingSoon(context, 'Export CSV');
                },
              ),
            ],
          ),
          AppDimensions.verticalSpace(AppDimensions.space24),
          _buildSection(
            title: 'PRÉFÉRENCES',
            children: [
              _buildSettingTile(
                icon: Icons.palette,
                title: 'Thème',
                subtitle: 'Clair / Sombre',
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    _showComingSoon(context, 'Thème sombre');
                  },
                ),
              ),
              _buildSettingTile(
                icon: Icons.language,
                title: 'Langue',
                subtitle: 'Français',
                onTap: () {
                  _showComingSoon(context, 'Changement de langue');
                },
              ),
              _buildSettingTile(
                icon: Icons.attach_money,
                title: 'Devise',
                subtitle: 'EUR (€)',
                onTap: () {
                  _showComingSoon(context, 'Changement de devise');
                },
              ),
            ],
          ),
          AppDimensions.verticalSpace(AppDimensions.space24),
          _buildSection(
            title: 'À PROPOS',
            children: [
              _buildSettingTile(
                icon: Icons.info,
                title: 'Version',
                subtitle: '1.0.0',
                trailing: const SizedBox.shrink(),
              ),
              _buildSettingTile(
                icon: Icons.help,
                title: 'Aide',
                subtitle: 'Besoin d\'aide ?',
                onTap: () {
                  _showComingSoon(context, 'Aide');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppDimensions.paddingHorizontalLG,
          child: Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        AppDimensions.verticalSpace(AppDimensions.space8),
        Card(
          elevation: AppDimensions.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusCard,
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: AppDimensions.borderRadiusSM,
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(title, style: AppTextStyles.titleMedium),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
      trailing:
          trailing ??
          const Icon(Icons.chevron_right, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bientôt disponible'),
        content: Text('$feature sera disponible dans une prochaine étape.'),
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
