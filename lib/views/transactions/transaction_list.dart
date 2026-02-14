import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/common/loading_view.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/empty_view.dart';

class TransactionListPage extends StatefulWidget {
  final bool showAppBar;

  const TransactionListPage({super.key, this.showAppBar = true});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransactions();
    });
  }

  Future<void> _loadTransactions() async {
    final provider = context.read<TransactionProvider>();
    await provider.loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.showAppBar ? _buildAppBar() : null,
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingView(
              message: 'Chargement des transactions...',
              fullScreen: false,
            );
          }

          if (provider.error != null) {
            return ErrorView.loading(
              message: provider.error,
              onRetry: _loadTransactions,
              fullScreen: false,
            );
          }

          if (provider.transactions.isEmpty) {
            return EmptyView.noTransactions(
              onAction: () => Navigator.pushNamed(context, '/transactions/add'),
              fullScreen: false,
            );
          }

          return _buildTransactionList(provider);
        },
      ),
      floatingActionButton: widget.showAppBar
          ? FloatingActionButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/transactions/add'),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      title: const Text('Transactions'),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterDialog,
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _showSearchDialog,
        ),
      ],
    );
  }

  Widget _buildTransactionList(TransactionProvider provider) {
    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.builder(
        padding: AppDimensions.paddingPage,
        itemCount: provider.transactions.length,
        itemBuilder: (context, index) {
          final transaction = provider.transactions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppDimensions.space12),
            elevation: AppDimensions.cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: AppDimensions.borderRadiusCard,
            ),
            child: ListTile(
              contentPadding: AppDimensions.paddingCard,
              leading: CircleAvatar(
                backgroundColor: transaction.type == 'expense'
                    ? AppColors.error.withOpacity(0.1)
                    : AppColors.success.withOpacity(0.1),
                child: Icon(
                  transaction.type == 'expense'
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color: transaction.type == 'expense'
                      ? AppColors.error
                      : AppColors.success,
                ),
              ),
              title: Text(
                transaction.description,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                transaction.date.toString().split(' ')[0],
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              trailing: Text(
                '${transaction.type == 'expense' ? '-' : '+'}${transaction.amount.toStringAsFixed(2)} FCFA',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: transaction.type == 'expense'
                      ? AppColors.error
                      : AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => _showTransactionDetails(transaction.id),
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    // TODO: Implémenter le dialogue de filtre
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtres'),
        content: const Text('Fonctionnalité à venir'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    // TODO: Implémenter la recherche
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechercher'),
        content: const Text('Fonctionnalité à venir'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(int id) {
    Navigator.pushNamed(context, '/transactions/details', arguments: id);
  }
}
