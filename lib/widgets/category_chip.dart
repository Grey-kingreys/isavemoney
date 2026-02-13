import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_dimensions.dart';

/// Widget pour afficher une catégorie sous forme de chip
class CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showIcon;
  final bool compact;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
    this.showIcon = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: compact ? AppDimensions.paddingSM : AppDimensions.paddingMD,
        decoration: BoxDecoration(
          color: isSelected
              ? category.getColor().withOpacity(0.15)
              : AppColors.white,
          borderRadius: AppDimensions.borderRadiusSM,
          border: Border.all(
            color: isSelected ? category.getColor() : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Text(
                category.icon,
                style: TextStyle(fontSize: compact ? 16 : 20),
              ),
              AppDimensions.horizontalSpace(AppDimensions.space8),
            ],
            Text(
              category.name,
              style:
                  (compact
                          ? AppTextStyles.labelMedium
                          : AppTextStyles.labelLarge)
                      .copyWith(
                        color: isSelected
                            ? category.getColor()
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget pour afficher une liste horizontale de chips de catégories
class CategoryChipList extends StatelessWidget {
  final List<CategoryModel> categories;
  final int? selectedCategoryId;
  final Function(int)? onCategorySelected;
  final bool showAll;

  const CategoryChipList({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    this.onCategorySelected,
    this.showAll = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppDimensions.paddingHorizontalLG,
        itemCount: showAll ? categories.length + 1 : categories.length,
        separatorBuilder: (context, index) =>
            AppDimensions.horizontalSpace(AppDimensions.space8),
        itemBuilder: (context, index) {
          if (showAll && index == 0) {
            return CategoryChip(
              category: CategoryModel(
                id: -1,
                name: 'Toutes',
                icon: '📊',
                color: '#6C63FF',
                categoryType: 'expense',
              ),
              isSelected: selectedCategoryId == null,
              onTap: () => onCategorySelected?.call(-1),
              compact: true,
            );
          }

          final categoryIndex = showAll ? index - 1 : index;
          final category = categories[categoryIndex];

          return CategoryChip(
            category: category,
            isSelected: selectedCategoryId == category.id,
            onTap: () => onCategorySelected?.call(category.id!),
            compact: true,
          );
        },
      ),
    );
  }
}

/// Widget pour afficher une catégorie avec un montant
class CategoryAmountChip extends StatelessWidget {
  final CategoryModel category;
  final double amount;
  final VoidCallback? onTap;

  const CategoryAmountChip({
    super.key,
    required this.category,
    required this.amount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppDimensions.paddingMD,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppDimensions.borderRadiusMD,
          border: Border.all(color: AppColors.grey200, width: 1),
        ),
        child: Row(
          children: [
            // Icône
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: category.getColor().withOpacity(0.15),
                borderRadius: AppDimensions.borderRadiusSM,
              ),
              child: Center(
                child: Text(
                  category.icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),

            AppDimensions.horizontalSpace(AppDimensions.space12),

            // Nom et montant
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.name, style: AppTextStyles.titleMedium),
                  AppDimensions.verticalSpace(AppDimensions.space4),
                  Text(
                    CurrencyUtils.format(amount),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: category.isExpense
                          ? AppColors.expense
                          : AppColors.income,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Indicateur de couleur
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: category.getColor(),
                borderRadius: AppDimensions.borderRadiusXS,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget pour afficher une catégorie avec progression (pour les budgets)
class CategoryProgressChip extends StatelessWidget {
  final CategoryModel category;
  final double spent;
  final double limit;
  final VoidCallback? onTap;

  const CategoryProgressChip({
    super.key,
    required this.category,
    required this.spent,
    required this.limit,
    this.onTap,
  });

  double get percentage {
    if (limit == 0) return 0;
    return (spent / limit * 100).clamp(0, 100);
  }

  Color get progressColor {
    if (percentage >= 100) return AppColors.error;
    if (percentage >= 80) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppDimensions.paddingMD,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppDimensions.borderRadiusMD,
          border: Border.all(
            color: percentage >= 80
                ? progressColor.withOpacity(0.3)
                : AppColors.grey200,
            width: percentage >= 80 ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec icône et montants
            Row(
              children: [
                // Icône
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: category.getColor().withOpacity(0.15),
                    borderRadius: AppDimensions.borderRadiusSM,
                  ),
                  child: Center(
                    child: Text(
                      category.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),

                AppDimensions.horizontalSpace(AppDimensions.space12),

                // Nom
                Expanded(
                  child: Text(category.name, style: AppTextStyles.titleMedium),
                ),

                // Pourcentage
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.space8,
                    vertical: AppDimensions.space4,
                  ),
                  decoration: BoxDecoration(
                    color: progressColor.withOpacity(0.15),
                    borderRadius: AppDimensions.borderRadiusXS,
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            AppDimensions.verticalSpace(AppDimensions.space12),

            // Barre de progression
            ClipRRect(
              borderRadius: AppDimensions.borderRadiusXS,
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: AppColors.grey200,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 6,
              ),
            ),

            AppDimensions.verticalSpace(AppDimensions.space8),

            // Montants
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dépensé: ${CurrencyUtils.formatCompact(spent)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Limite: ${CurrencyUtils.formatCompact(limit)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
