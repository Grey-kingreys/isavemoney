import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/common/loading_view.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/empty_view.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAccounts();
    });
  }

  Future<void> _loadAccounts() async {
    final provider = context.read<AccountProvider>();
    await provider.loadAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<AccountProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingView(
              message: 'Chargement des comptes...',
              fullScreen: false,
            );
          }

          if (provider.error != null) {
            return ErrorView.loading(
              message: provider.error,
              onRetry: _loadAccounts,
              fullScreen: false,
            );
          }

          if (provider.accounts.isEmpty) {
            return EmptyView(
              emoji: '🏦',
              title: 'Aucun compte',
              message: 'Ajoutez vos comptes bancaires',
              actionLabel: 'Ajouter un compte',
              onAction: _showAddAccountDialog,
              fullScreen: false,
            );
          }

          return _buildAccountList(provider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAccountDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      title: const Text('Comptes bancaires'),
      elevation: 0,
    );
  }

  Widget _buildAccountList(AccountProvider provider) {
    return RefreshIndicator(
      onRefresh: _loadAccounts,
      child: ListView.builder(
        padding: AppDimensions.paddingPage,
        itemCount: provider.accounts.length,
        itemBuilder: (context, index) {
          final account = provider.accounts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppDimensions.space16),
            elevation: AppDimensions.cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: AppDimensions.borderRadiusCard,
            ),
            child: Padding(
              padding: AppDimensions.paddingCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec nom et actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account.name,
                              style: AppTextStyles.headlineSmall,
                            ),
                            if (account.type != null) ...[
                              AppDimensions.verticalSpace(AppDimensions.space4),
                              Text(
                                _getAccountTypeLabel(account.type!),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () => _showEditAccountDialog(account.id),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: AppColors.error,
                            ),
                            onPressed: () =>
                                _showDeleteConfirmation(account.id),
                          ),
                        ],
                      ),
                    ],
                  ),

                  AppDimensions.verticalSpace(AppDimensions.space16),

                  // Solde
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.space16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadiusMD,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Solde',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${account.balance.toStringAsFixed(0)} FCFA',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getAccountTypeLabel(String type) {
    switch (type) {
      case 'checking':
        return 'Compte courant';
      case 'savings':
        return 'Compte épargne';
      case 'credit':
        return 'Carte de crédit';
      case 'cash':
        return 'Espèces';
      default:
        return type;
    }
  }

  void _showAddAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un compte'),
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

  void _showEditAccountDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le compte'),
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

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Voulez-vous vraiment supprimer ce compte ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implémenter la suppression
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
