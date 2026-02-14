import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../app/routes.dart';
import '../../widgets/dashboard_widget.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Charger les données après que le widget soit construit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final dashboardProvider = context.read<DashboardProvider>();
    await dashboardProvider.loadDashboard();
  }

  Future<void> _refreshData() async {
    final dashboardProvider = context.read<DashboardProvider>();
    await dashboardProvider.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.primary,
        child: Consumer<DashboardProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.summary == null) {
              return _buildLoadingState();
            }

            if (provider.error != null) {
              return _buildErrorState(provider.error!);
            }

            return _buildDashboardContent(provider);
          },
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tableau de Bord',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Bonjour! 👋',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // TODO: Afficher les notifications
          },
        ),
      ],
    );
  }

  Widget _buildDashboardContent(DashboardProvider provider) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppDimensions.paddingPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cartes de résumé
          DashboardSummaryCards(
            currentBalance: provider.currentBalance,
            monthIncome: provider.monthIncome,
            monthExpense: provider.monthExpense,
            isMonthProfitable: provider.isMonthProfitable(),
          ),

          AppDimensions.verticalSpace(AppDimensions.space24),

          // Statistiques rapides
          if (provider.monthStats != null)
            DashboardQuickStats(
              transactionCount: provider.monthTransactionCount,
              savingsRate: provider.savingsRate,
              averageTransaction:
                  (provider.monthStats!['average_transaction'] as num?)
                      ?.toDouble() ??
                  0.0,
            ),

          AppDimensions.verticalSpace(AppDimensions.space24),

          // Alertes budgets avec bouton vers la page budgets
          if (provider.hasBudgetAlerts) ...[
            DashboardBudgetAlerts(
              exceededCount: provider.exceededBudgetCount,
              warningCount: provider.warningBudgetCount,
              statusMessage: provider.getBudgetStatusMessage(),
              onTap: () {
                AppRoutes.navigateTo(context, AppRoutes.budgets);
              },
            ),
            AppDimensions.verticalSpace(AppDimensions.space16),
          ],

          // Bouton d'accès rapide aux budgets
          _buildQuickAccessButton(
            icon: Icons.account_balance_wallet,
            label: 'Gérer mes budgets',
            color: AppColors.budget,
            onTap: () {
              AppRoutes.navigateTo(context, AppRoutes.budgets);
            },
          ),

          AppDimensions.verticalSpace(AppDimensions.space24),

          // Graphique de répartition par catégorie
          DashboardCategoryBreakdown(
            breakdown: provider.categoryBreakdown.take(5).toList(),
            totalExpense: provider.monthExpense,
            onViewAll: () {
              AppRoutes.navigateTo(context, AppRoutes.statistics);
            },
          ),

          AppDimensions.verticalSpace(AppDimensions.space24),

          // Transactions récentes
          DashboardRecentTransactions(
            transactions: provider.recentTransactions.take(5).toList(),
            onViewAll: () {
              AppRoutes.navigateTo(context, AppRoutes.transactions);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusCard,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.borderRadiusCard,
        child: Container(
          padding: AppDimensions.paddingCard,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppDimensions.borderRadiusCard,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.space12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: AppDimensions.borderRadiusSM,
                ),
                child: Icon(
                  icon,
                  color: AppColors.white,
                  size: AppDimensions.iconLG,
                ),
              ),
              AppDimensions.horizontalSpace(AppDimensions.space16),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: AppDimensions.iconSM,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: AppDimensions.paddingPage,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppDimensions.icon3XL,
              color: AppColors.error,
            ),
            AppDimensions.verticalSpace(AppDimensions.space16),
            Text(
              'Erreur de chargement',
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            AppDimensions.verticalSpace(AppDimensions.space8),
            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            AppDimensions.verticalSpace(AppDimensions.space24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        AppRoutes.navigateTo(context, AppRoutes.transactionAdd);
      },
      icon: const Icon(Icons.add),
      label: const Text('Nouvelle transaction'),
      backgroundColor: AppColors.primary,
    );
  }
}
