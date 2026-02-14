import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/currency_utils.dart';
import '../../widgets/summary_card.dart';

/// Widget pour les cartes de résumé du dashboard
class DashboardSummaryCards extends StatelessWidget {
  final double currentBalance;
  final double monthIncome;
  final double monthExpense;
  final bool isMonthProfitable;

  const DashboardSummaryCards({
    super.key,
    required this.currentBalance,
    required this.monthIncome,
    required this.monthExpense,
    required this.isMonthProfitable,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Solde actuel
        SummaryCard.balance(
          amount: currentBalance,
          subtitle: isMonthProfitable
              ? '↗️ Bénéfice ce mois'
              : '↘️ Déficit ce mois',
        ),

        AppDimensions.verticalSpace(AppDimensions.space16),

        // Revenus et Dépenses du mois
        Row(
          children: [
            Expanded(
              child: SummaryCard.income(
                amount: monthIncome,
                subtitle: 'Ce mois',
              ),
            ),
            AppDimensions.horizontalSpace(AppDimensions.space16),
            Expanded(
              child: SummaryCard.expense(
                amount: monthExpense,
                subtitle: 'Ce mois',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Widget pour les alertes de budget
class DashboardBudgetAlerts extends StatelessWidget {
  final int exceededCount;
  final int warningCount;
  final String statusMessage;
  final VoidCallback? onTap;

  const DashboardBudgetAlerts({
    super.key,
    required this.exceededCount,
    required this.warningCount,
    required this.statusMessage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (exceededCount == 0 && warningCount == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: AppDimensions.cardElevation,
      color: exceededCount > 0 ? AppColors.errorLight : AppColors.warningLight,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusCard,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.borderRadiusCard,
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
                      statusMessage,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget pour la répartition par catégorie
class DashboardCategoryBreakdown extends StatelessWidget {
  final List<Map<String, dynamic>> breakdown;
  final double totalExpense;
  final VoidCallback? onViewAll;

  const DashboardCategoryBreakdown({
    super.key,
    required this.breakdown,
    required this.totalExpense,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (breakdown.isEmpty) {
      return _buildEmptyState();
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
            if (onViewAll != null)
              TextButton(onPressed: onViewAll, child: const Text('Voir tout')),
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
                // Graphique placeholder
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: AppDimensions.borderRadiusMD,
                  ),
                  child: Center(
                    child: Text(
                      '📊 Graphique circulaire',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),

                AppDimensions.verticalSpace(AppDimensions.space16),

                // Liste des catégories
                ...breakdown.map(
                  (category) => CategoryBreakdownItem(
                    categoryId: category['category_id'] as int,
                    amount: category['amount'] as double,
                    total: totalExpense,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
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
              Icons.pie_chart_outline,
              size: AppDimensions.icon2XL,
              color: AppColors.textTertiary,
            ),
            AppDimensions.verticalSpace(AppDimensions.space16),
            Text(
              'Aucune dépense ce mois',
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
}

/// Widget pour un élément de catégorie dans la répartition
class CategoryBreakdownItem extends StatelessWidget {
  final int categoryId;
  final double amount;
  final double total;

  const CategoryBreakdownItem({
    super.key,
    required this.categoryId,
    required this.amount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (amount / total) * 100 : 0.0;

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
}

/// Widget pour les transactions récentes
class DashboardRecentTransactions extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final VoidCallback? onViewAll;

  const DashboardRecentTransactions({
    super.key,
    required this.transactions,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return _buildEmptyState();
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
            if (onViewAll != null)
              TextButton(onPressed: onViewAll, child: const Text('Voir tout')),
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
                  (entry) => TransactionItem(
                    transaction: entry.value,
                    isLast: entry.key == transactions.length - 1,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
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
              Icons.receipt_long_outlined,
              size: AppDimensions.icon2XL,
              color: AppColors.textTertiary,
            ),
            AppDimensions.verticalSpace(AppDimensions.space16),
            Text(
              'Aucune transaction récente',
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
}

/// Widget pour un élément de transaction
class TransactionItem extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final bool isLast;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
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
}

/// Widget pour les statistiques rapides
class DashboardQuickStats extends StatelessWidget {
  final int transactionCount;
  final double savingsRate;
  final double averageTransaction;

  const DashboardQuickStats({
    super.key,
    required this.transactionCount,
    required this.savingsRate,
    required this.averageTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusCard,
      ),
      child: Padding(
        padding: AppDimensions.paddingCard,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              icon: Icons.receipt_long,
              label: 'Transactions',
              value: transactionCount.toString(),
              color: AppColors.info,
            ),
            _buildDivider(),
            _buildStatItem(
              icon: Icons.savings,
              label: 'Épargne',
              value: '${savingsRate.toStringAsFixed(0)}%',
              color: AppColors.success,
            ),
            _buildDivider(),
            _buildStatItem(
              icon: Icons.trending_up,
              label: 'Moyenne',
              value: CurrencyUtils.formatCompact(averageTransaction),
              color: AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.space8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: AppDimensions.borderRadiusSM,
          ),
          child: Icon(icon, color: color, size: AppDimensions.iconMD),
        ),
        AppDimensions.verticalSpace(AppDimensions.space8),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        AppDimensions.verticalSpace(AppDimensions.space4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 60, color: AppColors.grey200);
  }
}
