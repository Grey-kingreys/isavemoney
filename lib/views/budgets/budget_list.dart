import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../app/routes.dart';
import '../../widgets/common/empty_view.dart';

/// Page de liste des budgets (PLACEHOLDER - ÉTAPE 3)
class BudgetListPage extends StatefulWidget {
  const BudgetListPage({super.key});

  @override
  State<BudgetListPage> createState() => _BudgetListPageState();
}

class _BudgetListPageState extends State<BudgetListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showBudgetInfo(context);
            },
          ),
        ],
      ),
      body: _buildPlaceholder(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AppRoutes.navigateTo(context, AppRoutes.budgetAdd);
        },
        backgroundColor: AppColors.budget,
        icon: const Icon(Icons.add),
        label: const Text('Créer un budget'),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return EmptyView.noBudgets(
      onAction: () {
        AppRoutes.navigateTo(context, AppRoutes.budgetAdd);
      },
      fullScreen: false,
    );
  }

  void _showBudgetInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('À propos des budgets'),
        content: const Text(
          'Les budgets vous aident à contrôler vos dépenses par catégorie.\n\n'
          'Cette fonctionnalité sera disponible à l\'ÉTAPE 3.',
        ),
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
