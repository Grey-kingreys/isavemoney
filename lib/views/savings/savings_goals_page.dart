import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/savings_goal_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/common/loading_view.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/empty_view.dart';

class SavingsGoalsPage extends StatefulWidget {
  const SavingsGoalsPage({super.key});

  @override
  State<SavingsGoalsPage> createState() => _SavingsGoalsPageState();
}

class _SavingsGoalsPageState extends State<SavingsGoalsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGoals();
    });
  }

  Future<void> _loadGoals() async {
    final provider = context.read<SavingsGoalProvider>();
    await provider.loadGoals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<SavingsGoalProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingView(
              message: 'Chargement des objectifs...',
              fullScreen: false,
            );
          }

          if (provider.error != null) {
            return ErrorView.loading(
              message: provider.error,
              onRetry: _loadGoals,
              fullScreen: false,
            );
          }

          if (provider.goals.isEmpty) {
            return EmptyView(
              emoji: '🎯',
              title: 'Aucun objectif',
              message:
                  'Créez des objectifs d\'épargne pour atteindre vos rêves',
              actionLabel: 'Créer un objectif',
              onAction: _showAddGoalDialog,
              fullScreen: false,
            );
          }

          return _buildGoalsList(provider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      title: const Text('Objectifs d\'épargne'),
      elevation: 0,
    );
  }

  Widget _buildGoalsList(SavingsGoalProvider provider) {
    return RefreshIndicator(
      onRefresh: _loadGoals,
      child: ListView.builder(
        padding: AppDimensions.paddingPage,
        itemCount: provider.goals.length,
        itemBuilder: (context, index) {
          final goal = provider.goals[index];
          final progress = (goal.currentAmount / goal.targetAmount) * 100;
          final isCompleted = progress >= 100;

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
                  // En-tête
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          goal.name,
                          style: AppTextStyles.headlineSmall,
                        ),
                      ),
                      if (isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.space8,
                            vertical: AppDimensions.space4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusSM,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 16,
                                color: AppColors.success,
                              ),
                              AppDimensions.horizontalSpace(
                                AppDimensions.space4,
                              ),
                              Text(
                                'Atteint',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  if (goal.description != null) ...[
                    AppDimensions.verticalSpace(AppDimensions.space8),
                    Text(
                      goal.description!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  AppDimensions.verticalSpace(AppDimensions.space16),

                  // Montants
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${goal.currentAmount.toStringAsFixed(0)} FCFA',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'sur ${goal.targetAmount.toStringAsFixed(0)} FCFA',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  AppDimensions.verticalSpace(AppDimensions.space12),

                  // Barre de progression
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusSM,
                    ),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 8,
                      backgroundColor: AppColors.grey200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted ? AppColors.success : AppColors.primary,
                      ),
                    ),
                  ),

                  AppDimensions.verticalSpace(AppDimensions.space8),

                  // Pourcentage et deadline
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${progress.toStringAsFixed(1)}% atteint',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (goal.deadline != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            AppDimensions.horizontalSpace(AppDimensions.space4),
                            Text(
                              goal.deadline!.toString().split(' ')[0],
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  AppDimensions.verticalSpace(AppDimensions.space12),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showContributeDialog(goal.id),
                          icon: const Icon(Icons.add_circle_outline, size: 18),
                          label: const Text('Contribuer'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ),
                      AppDimensions.horizontalSpace(AppDimensions.space8),
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => _showEditGoalDialog(goal.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () => _showDeleteConfirmation(goal.id),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer un objectif'),
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

  void _showEditGoalDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier l\'objectif'),
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

  void _showContributeDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une contribution'),
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
        content: const Text('Voulez-vous vraiment supprimer cet objectif ?'),
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
