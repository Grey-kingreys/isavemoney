import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/budget_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/currency_utils.dart';
import '../../app/routes.dart';
import '../../widgets/common/empty_view.dart';
import '../../widgets/common/loading_view.dart';
import '../../widgets/common/error_view.dart';

/// Page de liste des budgets (contenu uniquement avec tabs intégrés)
class BudgetList extends StatefulWidget {
  const BudgetList({super.key});

  @override
  State<BudgetList> createState() => _BudgetListState();
}

class _BudgetListState extends State<BudgetList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final budgetProvider = context.read<BudgetProvider>();
    final categoryProvider = context.read<CategoryProvider>();

    await Future.wait([
      budgetProvider.loadBudgets(),
      categoryProvider.loadCategories(),
    ]);
  }

  Future<void> _refreshData() async {
    await context.read<BudgetProvider>().loadBudgets();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TabBar intégré dans le contenu
        Container(
          color: AppColors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Actifs'),
              Tab(text: 'Tous'),
            ],
          ),
        ),

        // Contenu des tabs
        Expanded(
          child: Consumer2<BudgetProvider, CategoryProvider>(
            builder: (context, budgetProvider, categoryProvider, child) {
              if (budgetProvider.isLoading && !budgetProvider.hasBudgets) {
                return const LoadingView(
                  message: 'Chargement des budgets...',
                  fullScreen: false,
                );
              }

              if (budgetProvider.error != null) {
                return ErrorView.loading(
                  message: budgetProvider.error,
                  onRetry: _loadData,
                  fullScreen: false,
                );
              }

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildBudgetList(
                    budgetProvider.activeBudgets,
                    categoryProvider,
                    budgetProvider,
                  ),
                  _buildBudgetList(
                    budgetProvider.budgets,
                    categoryProvider,
                    budgetProvider,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetList(
    List<BudgetModel> budgets,
    CategoryProvider categoryProvider,
    BudgetProvider budgetProvider,
  ) {
    if (budgets.isEmpty) {
      return EmptyView.noBudgets(
        onAction: () async {
          final result = await AppRoutes.navigateTo(
            context,
            AppRoutes.budgetAdd,
          );
          if (result == true) {
            _refreshData();
          }
        },
        fullScreen: false,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Column(
        children: [
          // Résumé des budgets
          if (budgetProvider.summary != null &&
              budgetProvider.summary!['has_budgets'])
            _buildBudgetSummary(budgetProvider.summary!),

          // Liste des budgets
          Expanded(
            child: ListView.builder(
              padding: AppDimensions.paddingPage,
              itemCount: budgets.length,
              itemBuilder: (context, index) {
                final budget = budgets[index];
                return _buildBudgetCard(budget, categoryProvider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSummary(Map<String, dynamic> summary) {
    final totalLimit = (summary['total_limit'] as num).toDouble();
    final totalSpent = (summary['total_spent'] as num).toDouble();
    final percentageUsed = (summary['percentage_used'] as num).toDouble();
    final exceededCount = summary['exceeded_count'] as int;
    final warningCount = summary['warning_count'] as int;

    return Container(
      margin: AppDimensions.paddingPage,
      padding: AppDimensions.paddingCard,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.budget.withOpacity(0.1), AppColors.budgetLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppDimensions.borderRadiusCard,
        border: Border.all(color: AppColors.budget.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Résumé global', style: AppTextStyles.titleMedium),
              Text(
                '${percentageUsed.toStringAsFixed(0)}%',
                style: AppTextStyles.titleLarge.copyWith(
                  color: _getPercentageColor(percentageUsed),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          AppDimensions.verticalSpace(AppDimensions.space12),

          ClipRRect(
            borderRadius: AppDimensions.borderRadiusXS,
            child: LinearProgressIndicator(
              value: (percentageUsed / 100).clamp(0.0, 1.0),
              backgroundColor: AppColors.grey200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getPercentageColor(percentageUsed),
              ),
              minHeight: 8,
            ),
          ),

          AppDimensions.verticalSpace(AppDimensions.space12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dépensé',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    CurrencyUtils.formatCompact(totalSpent),
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Limite totale',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    CurrencyUtils.formatCompact(totalLimit),
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (exceededCount > 0 || warningCount > 0) ...[
            AppDimensions.verticalSpace(AppDimensions.space12),
            Wrap(
              spacing: AppDimensions.space8,
              children: [
                if (exceededCount > 0)
                  _buildAlertChip(
                    '$exceededCount dépassé${exceededCount > 1 ? 's' : ''}',
                    AppColors.error,
                    Icons.error,
                  ),
                if (warningCount > 0)
                  _buildAlertChip(
                    '$warningCount en alerte',
                    AppColors.warning,
                    Icons.warning,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlertChip(String label, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.space4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: AppDimensions.borderRadiusXS,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          AppDimensions.horizontalSpace(AppDimensions.space4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(
    BudgetModel budget,
    CategoryProvider categoryProvider,
  ) {
    final categoryName = categoryProvider.getCategoryName(budget.categoryId);
    final categoryIcon = categoryProvider.getCategoryIcon(budget.categoryId);
    final percentage = budget.percentageUsed;
    final progressColor = _getPercentageColor(percentage);

    return Card(
      margin: EdgeInsets.only(bottom: AppDimensions.space16),
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusCard,
        side: BorderSide(
          color: budget.isExceeded
              ? AppColors.error.withOpacity(0.3)
              : budget.isThresholdReached
              ? AppColors.warning.withOpacity(0.3)
              : Colors.transparent,
          width: budget.isExceeded || budget.isThresholdReached ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: () async {
          final result = await AppRoutes.navigateTo(
            context,
            AppRoutes.budgetEdit,
            arguments: {'id': budget.id},
          );
          if (result == true) {
            _refreshData();
          }
        },
        borderRadius: AppDimensions.borderRadiusCard,
        child: Padding(
          padding: AppDimensions.paddingCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec icône et nom
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.budget.withOpacity(0.15),
                      borderRadius: AppDimensions.borderRadiusSM,
                    ),
                    child: Center(
                      child: Text(
                        categoryIcon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),

                  AppDimensions.horizontalSpace(AppDimensions.space16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(categoryName, style: AppTextStyles.titleMedium),
                        AppDimensions.verticalSpace(AppDimensions.space4),
                        Text(
                          _getPeriodLabel(budget.periodType),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Pourcentage
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.space12,
                      vertical: AppDimensions.space8,
                    ),
                    decoration: BoxDecoration(
                      color: progressColor.withOpacity(0.15),
                      borderRadius: AppDimensions.borderRadiusXS,
                    ),
                    child: Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: progressColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  // Menu
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(value, budget),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Modifier'),
                      ),
                      const PopupMenuItem(
                        value: 'toggle',
                        child: Text('Activer/Désactiver'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Supprimer',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              AppDimensions.verticalSpace(AppDimensions.space16),

              // Barre de progression
              ClipRRect(
                borderRadius: AppDimensions.borderRadiusXS,
                child: LinearProgressIndicator(
                  value: (percentage / 100).clamp(0.0, 1.0),
                  backgroundColor: AppColors.grey200,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: 8,
                ),
              ),

              AppDimensions.verticalSpace(AppDimensions.space12),

              // Montants
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dépensé',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        CurrencyUtils.format(budget.currentSpent),
                        style: AppTextStyles.titleMedium.copyWith(
                          color: progressColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        budget.isExceeded ? 'Dépassement' : 'Restant',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        CurrencyUtils.format(budget.remainingAmount.abs()),
                        style: AppTextStyles.titleMedium.copyWith(
                          color: budget.isExceeded
                              ? AppColors.error
                              : AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Limite',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        CurrencyUtils.format(budget.amountLimit),
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Alertes
              if (budget.isExceeded || budget.isThresholdReached) ...[
                AppDimensions.verticalSpace(AppDimensions.space12),
                Container(
                  padding: AppDimensions.paddingSM,
                  decoration: BoxDecoration(
                    color:
                        (budget.isExceeded
                                ? AppColors.error
                                : AppColors.warning)
                            .withOpacity(0.1),
                    borderRadius: AppDimensions.borderRadiusXS,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        budget.isExceeded ? Icons.error : Icons.warning,
                        size: 16,
                        color: budget.isExceeded
                            ? AppColors.error
                            : AppColors.warning,
                      ),
                      AppDimensions.horizontalSpace(AppDimensions.space8),
                      Expanded(
                        child: Text(
                          budget.isExceeded
                              ? 'Budget dépassé !'
                              : 'Attention : ${budget.notificationThreshold.toInt()}% atteint',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: budget.isExceeded
                                ? AppColors.error
                                : AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Statut inactif
              if (!budget.isActive) ...[
                AppDimensions.verticalSpace(AppDimensions.space12),
                Container(
                  padding: AppDimensions.paddingSM,
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: AppDimensions.borderRadiusXS,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.pause_circle_outline, size: 16),
                      AppDimensions.horizontalSpace(AppDimensions.space8),
                      const Text('Budget désactivé'),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 100) return AppColors.error;
    if (percentage >= 80) return AppColors.warning;
    return AppColors.success;
  }

  String _getPeriodLabel(String periodType) {
    switch (periodType) {
      case 'daily':
        return 'Quotidien';
      case 'weekly':
        return 'Hebdomadaire';
      case 'monthly':
        return 'Mensuel';
      case 'yearly':
        return 'Annuel';
      default:
        return periodType;
    }
  }

  Future<void> _handleMenuAction(String action, BudgetModel budget) async {
    switch (action) {
      case 'edit':
        final result = await AppRoutes.navigateTo(
          context,
          AppRoutes.budgetEdit,
          arguments: {'id': budget.id},
        );
        if (result == true) {
          _refreshData();
        }
        break;

      case 'toggle':
        final budgetProvider = context.read<BudgetProvider>();
        await budgetProvider.toggleBudgetStatus(budget.id!, !budget.isActive);
        break;

      case 'delete':
        _confirmDelete(budget);
        break;
    }
  }

  Future<void> _confirmDelete(BudgetModel budget) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le budget ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<BudgetProvider>().deleteBudget(
        budget.id!,
      );
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budget supprimé'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}
