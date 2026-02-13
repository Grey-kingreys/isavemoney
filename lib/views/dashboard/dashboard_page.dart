import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/budget_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/category_chip.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/currency_utils.dart';
import '../../app/routes.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
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
          _buildSummaryCards(provider),

          AppDimensions.verticalSpace(AppDimensions.space24),

          // Alertes budgets
          if (provider.hasBudgetAlerts) ...[
            _buildBudgetAlerts(provider),
            AppDimensions.verticalSpace(AppDimensions.space24),
          ],

          // Graphique de répartition
          _buildCategoryBreakdown(provider),

          AppDimensions.verticalSpace(AppDimensions.space24),

          // Transactions récentes
          _buildRecentTransactions(provider),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(DashboardProvider provider) {
    return Column(
      children: [
        // Solde actuel
        SummaryCard.balance(
          amount: provider.currentBalance,
          subtitle: provider.isMonthProfitable()
              ? '↗️ Bénéfice ce mois'
              : '↘️ Déficit ce mois',
        ),

        AppDimensions.verticalSpace(AppDimensions.space16),

        // Revenus et Dépenses du mois
        Row(
          children: [
            Expanded(
              child: SummaryCard.income(
                amount: provider.monthIncome,
                subtitle: 'Ce mois',
              ),
            ),
            AppDimensions.horizontalSpace(AppDimensions.space16),
            Expanded(
              child: SummaryCard.expense(
                amount: provider.monthExpense,
                subtitle: 'Ce mois',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetAlerts(DashboardProvider provider) {
    final exceededCount = provider.exceededBudgetCount;
    final warningCount = provider.warningBudgetCount;

    if (exceededCount == 0 && warningCount == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: AppDimensions.cardElevation,
      color: exceededCount > 0 ? AppColors.errorLight : AppColors.warningLight,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusCard,
      ),
      child: Padding(
        padding: AppDimensions.paddingCard,
        child: Row(
          children: [
            Icon(
              exceededCount > 0
                  ? Icons.error_outline
                  : Icons.warning_amber_rounded,
              color: exceededCount > 0 ? AppColors.error : AppColors.warning,
              size: AppDimensions.iconLG,
            ),
            AppDimensions.horizontalSpace(AppDimensions.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exceededCount > 0
                        ? 'Budgets dépassés'
                        : 'Budgets en alerte',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppDimensions.verticalSpace(AppDimensions.space4),
                  Text(
                    provider.getBudgetStatusMessage(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(DashboardProvider provider) {
    final breakdown = provider.categoryBreakdown.take(5).toList();

    if (breakdown.isEmpty) {
      return _buildEmptyState('Aucune dépense ce mois');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Dépenses par catégorie',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                AppRoutes.navigateTo(context, AppRoutes.statistics);
              },
              child: Text('Voir tout'),
            ),
          ],
        ),

        AppDimensions.verticalSpace(AppDimensions.space16),

        Card(
          elevation: AppDimensions.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusCard,
          ),
          child: Padding(
            padding: AppDimensions.paddingCard,
            child: Column(
              children: [
                // Graphique (placeholder - à implémenter avec fl_chart)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: AppDimensions.borderRadiusMD,
                  ),
                  child: Center(
                    child: Text(
                      '📊 Graphique à venir',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),

                AppDimensions.verticalSpace(AppDimensions.space16),

                // Liste des catégories
                ...breakdown.map(
                  (category) => _buildCategoryItem(
                    category['category_id'] as int,
                    category['amount'] as double,
                    provider.monthExpense,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(int categoryId, double amount, double total) {
    final percentage = (amount / total) * 100;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.space8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Catégorie $categoryId', // TODO: Récupérer le nom réel
                  style: AppTextStyles.bodyLarge,
                ),
              ),
              Text(
                CurrencyUtils.format(amount),
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          AppDimensions.verticalSpace(AppDimensions.space8),
          ClipRRect(
            borderRadius: AppDimensions.borderRadiusXS,
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.grey200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(DashboardProvider provider) {
    final transactions = provider.recentTransactions.take(5).toList();

    if (transactions.isEmpty) {
      return _buildEmptyState('Aucune transaction récente');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transactions récentes',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                AppRoutes.navigateTo(context, AppRoutes.transactions);
              },
              child: Text('Voir tout'),
            ),
          ],
        ),

        AppDimensions.verticalSpace(AppDimensions.space16),

        Card(
          elevation: AppDimensions.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusCard,
          ),
          child: Column(
            children: transactions
                .asMap()
                .entries
                .map(
                  (entry) => _buildTransactionItem(
                    entry.value,
                    isLast: entry.key == transactions.length - 1,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(
    Map<String, dynamic> transaction, {
    bool isLast = false,
  }) {
    final isIncome = transaction['transaction_type'] == 'income';
    final amount = (transaction['amount'] as num).toDouble();

    return InkWell(
      onTap: () {
        // TODO: Afficher les détails de la transaction
      },
      child: Container(
        padding: AppDimensions.paddingCard,
        decoration: BoxDecoration(
          border: !isLast
              ? Border(
                  bottom: BorderSide(
                    color: AppColors.grey200,
                    width: AppDimensions.borderThin,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (isIncome ? AppColors.income : AppColors.expense)
                    .withOpacity(0.1),
                borderRadius: AppDimensions.borderRadiusSM,
              ),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome ? AppColors.income : AppColors.expense,
              ),
            ),
            AppDimensions.horizontalSpace(AppDimensions.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction['title'] as String,
                    style: AppTextStyles.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppDimensions.verticalSpace(AppDimensions.space4),
                  Text(
                    'Catégorie ${transaction['category_id']}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'} ${CurrencyUtils.format(amount)}',
              style: AppTextStyles.titleMedium.copyWith(
                color: isIncome ? AppColors.income : AppColors.expense,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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

  Widget _buildEmptyState(String message) {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusCard,
      ),
      child: Padding(
        padding: AppDimensions.padding2XL,
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: AppDimensions.icon2XL,
              color: AppColors.textTertiary,
            ),
            AppDimensions.verticalSpace(AppDimensions.space16),
            Text(
              message,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
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
