import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../app/routes.dart';
import '../../widgets/common/empty_view.dart';

/// Page de liste des transactions (PLACEHOLDER - ÉTAPE 2)
class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implémenter la recherche (ÉTAPE 2)
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implémenter les filtres (ÉTAPE 2)
            },
          ),
        ],
      ),
      body: _buildPlaceholder(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AppRoutes.navigateTo(context, AppRoutes.transactionAdd);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return EmptyView.noTransactions(
      onAction: () {
        AppRoutes.navigateTo(context, AppRoutes.transactionAdd);
      },
      fullScreen: false,
    );
  }
}
