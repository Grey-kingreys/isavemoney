import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../app/routes.dart';
import '../../widgets/common/empty_view.dart';
import '../../widgets/common/loading_view.dart';
import '../../widgets/common/error_view.dart';
import 'transaction_item.dart';

/// Page de liste des transactions (contenu uniquement, sans Scaffold)
class TransactionList extends StatefulWidget {
  const TransactionList({super.key});

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  String? _selectedType;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final transactionProvider = context.read<TransactionProvider>();
    final categoryProvider = context.read<CategoryProvider>();

    await Future.wait([
      transactionProvider.loadTransactions(),
      categoryProvider.loadCategories(),
    ]);
  }

  Future<void> _refreshData() async {
    await context.read<TransactionProvider>().loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, CategoryProvider>(
      builder: (context, transactionProvider, categoryProvider, child) {
        if (transactionProvider.isLoading &&
            !transactionProvider.hasTransactions) {
          return const LoadingView(
            message: 'Chargement des transactions...',
            fullScreen: false,
          );
        }

        if (transactionProvider.error != null) {
          return ErrorView.loading(
            message: transactionProvider.error,
            onRetry: _loadData,
            fullScreen: false,
          );
        }

        if (!transactionProvider.hasTransactions) {
          return EmptyView.noTransactions(
            onAction: () =>
                AppRoutes.navigateTo(context, AppRoutes.transactionAdd),
            fullScreen: false,
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: Column(
            children: [
              // Filtres
              _buildFilters(categoryProvider),

              // Liste des transactions
              Expanded(
                child: _buildTransactionList(
                  transactionProvider,
                  categoryProvider,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilters(CategoryProvider categoryProvider) {
    return Container(
      padding: AppDimensions.paddingVerticalMD,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: AppDimensions.paddingHorizontalLG,
        child: Row(
          children: [
            // Filtre par type
            _buildFilterChip(
              label: 'Toutes',
              isSelected: _selectedType == null,
              onTap: () {
                setState(() => _selectedType = null);
                context.read<TransactionProvider>().filterByType(null);
              },
            ),
            AppDimensions.horizontalSpace(AppDimensions.space8),
            _buildFilterChip(
              label: 'Revenus',
              isSelected: _selectedType == 'income',
              color: AppColors.income,
              onTap: () {
                setState(() => _selectedType = 'income');
                context.read<TransactionProvider>().filterByType('income');
              },
            ),
            AppDimensions.horizontalSpace(AppDimensions.space8),
            _buildFilterChip(
              label: 'Dépenses',
              isSelected: _selectedType == 'expense',
              color: AppColors.expense,
              onTap: () {
                setState(() => _selectedType = 'expense');
                context.read<TransactionProvider>().filterByType('expense');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    Color? color,
    required VoidCallback onTap,
  }) {
    final chipColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
          vertical: AppDimensions.space8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : AppColors.white,
          borderRadius: AppDimensions.borderRadiusSM,
          border: Border.all(
            color: isSelected ? chipColor : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(
    TransactionProvider transactionProvider,
    CategoryProvider categoryProvider,
  ) {
    final transactions = transactionProvider.transactions;

    if (transactions.isEmpty) {
      return Center(
        child: Text(
          'Aucune transaction trouvée',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    // Grouper par date
    final groupedTransactions = _groupTransactionsByDate(transactions);

    return ListView.builder(
      padding: AppDimensions.paddingPage,
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        final date = groupedTransactions.keys.elementAt(index);
        final dayTransactions = groupedTransactions[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête de date
            Padding(
              padding: AppDimensions.paddingVerticalMD,
              child: Text(
                _formatDateHeader(date),
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Transactions du jour
            Card(
              elevation: AppDimensions.cardElevation,
              shape: RoundedRectangleBorder(
                borderRadius: AppDimensions.borderRadiusCard,
              ),
              child: Column(
                children: dayTransactions.asMap().entries.map((entry) {
                  final transaction = entry.value;
                  final isLast = entry.key == dayTransactions.length - 1;

                  return TransactionItem(
                    transaction: transaction,
                    categoryProvider: categoryProvider,
                    isLast: isLast,
                    onTap: () => _onTransactionTap(transaction.id!),
                  );
                }).toList(),
              ),
            ),

            AppDimensions.verticalSpace(AppDimensions.space16),
          ],
        );
      },
    );
  }

  Map<DateTime, List<dynamic>> _groupTransactionsByDate(
    List<dynamic> transactions,
  ) {
    final Map<DateTime, List<dynamic>> grouped = {};

    for (final transaction in transactions) {
      final date = transaction.date;
      final dateKey = DateTime(date.year, date.month, date.day);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Aujourd\'hui';
    } else if (date == yesterday) {
      return 'Hier';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _onTransactionTap(int transactionId) {
    AppRoutes.navigateTo(
      context,
      AppRoutes.transactionEdit,
      arguments: {'id': transactionId},
    );
  }
}
