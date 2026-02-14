import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_dimensions.dart';
import '../app/routes.dart';

/// Menu latéral de l'application
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      child: SafeArea(
        child: Column(
          children: [
            // En-tête du drawer
            _buildHeader(context),

            AppDimensions.verticalSpace(AppDimensions.space8),

            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.dashboard_rounded,
                    title: 'Tableau de bord',
                    route: AppRoutes.dashboard,
                    gradient: AppColors.primaryGradient,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.receipt_long_rounded,
                    title: 'Transactions',
                    route: AppRoutes.transactions,
                    gradient: AppColors.secondaryGradient,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'Budgets',
                    route: AppRoutes.budgets,
                    gradient: const LinearGradient(
                      colors: [AppColors.budget, AppColors.budgetDark],
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.bar_chart_rounded,
                    title: 'Statistiques',
                    route: AppRoutes.statistics,
                    gradient: const LinearGradient(
                      colors: [AppColors.info, AppColors.infoDark],
                    ),
                  ),

                  const Divider(height: AppDimensions.space32),

                  // Catégories et paramètres
                  Padding(
                    padding: AppDimensions.paddingHorizontalLG,
                    child: Text(
                      'PARAMÈTRES',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  AppDimensions.verticalSpace(AppDimensions.space8),

                  _buildSimpleMenuItem(
                    context,
                    icon: Icons.category_rounded,
                    title: 'Catégories',
                    route: AppRoutes.settingsCategories,
                  ),
                  _buildSimpleMenuItem(
                    context,
                    icon: Icons.account_balance_rounded,
                    title: 'Comptes',
                    route: AppRoutes.settingsAccounts,
                  ),
                  _buildSimpleMenuItem(
                    context,
                    icon: Icons.backup_rounded,
                    title: 'Sauvegarde',
                    route: AppRoutes.settingsBackup,
                  ),
                  _buildSimpleMenuItem(
                    context,
                    icon: Icons.settings_rounded,
                    title: 'Paramètres',
                    route: AppRoutes.settings,
                  ),
                ],
              ),
            ),

            // Footer avec version
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: AppDimensions.paddingLG,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.radius2XL),
          bottomRight: Radius.circular(AppDimensions.radius2XL),
        ),
      ),
      child: Column(
        children: [
          // Logo/Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text('💰', style: TextStyle(fontSize: 40)),
            ),
          ),

          AppDimensions.verticalSpace(AppDimensions.space16),

          // Nom de l'app
          Text(
            'BudgetBuddy',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          AppDimensions.verticalSpace(AppDimensions.space4),

          // Slogan
          Text(
            'Gérez votre argent intelligemment',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required Gradient gradient,
  }) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isCurrentRoute = currentRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.space4,
      ),
      decoration: BoxDecoration(
        gradient: isCurrentRoute ? gradient : null,
        borderRadius: AppDimensions.borderRadiusMD,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context); // Ferme le drawer
            if (!isCurrentRoute) {
              AppRoutes.navigateTo(context, route);
            }
          },
          borderRadius: AppDimensions.borderRadiusMD,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
              vertical: AppDimensions.space16,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCurrentRoute
                        ? AppColors.white.withOpacity(0.2)
                        : AppColors.grey100,
                    borderRadius: AppDimensions.borderRadiusSM,
                  ),
                  child: Icon(
                    icon,
                    color: isCurrentRoute ? AppColors.white : AppColors.primary,
                    size: AppDimensions.iconMD,
                  ),
                ),
                AppDimensions.horizontalSpace(AppDimensions.space16),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isCurrentRoute
                          ? AppColors.white
                          : AppColors.textPrimary,
                      fontWeight: isCurrentRoute
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
                if (isCurrentRoute)
                  const Icon(Icons.chevron_right, color: AppColors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.textSecondary,
        size: AppDimensions.iconMD,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
      onTap: () {
        Navigator.pop(context); // Ferme le drawer
        AppRoutes.navigateTo(context, route);
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: AppDimensions.paddingLG,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.grey200,
            width: AppDimensions.borderThin,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Version 1.0.0',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          AppDimensions.verticalSpace(AppDimensions.space4),
          Text(
            '© 2024 BudgetBuddy',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
