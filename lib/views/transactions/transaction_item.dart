import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../../providers/category_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/currency_utils.dart';

/// Widget pour afficher un élément de transaction dans la liste
class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final CategoryProvider categoryProvider;
  final bool isLast;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.categoryProvider,
    this.isLast = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final categoryName = categoryProvider.getCategoryName(
      transaction.categoryId,
    );
    final categoryIcon = categoryProvider.getCategoryIcon(
      transaction.categoryId,
    );

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
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
            // Icône de catégorie
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (isIncome ? AppColors.income : AppColors.expense)
                    .withOpacity(0.1),
                borderRadius: AppDimensions.borderRadiusSM,
              ),
              child: Center(
                child: Text(categoryIcon, style: const TextStyle(fontSize: 24)),
              ),
            ),

            AppDimensions.horizontalSpace(AppDimensions.space16),

            // Informations de la transaction
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: AppTextStyles.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppDimensions.verticalSpace(AppDimensions.space4),
                  Row(
                    children: [
                      Text(
                        categoryName,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (transaction.description != null) ...[
                    AppDimensions.verticalSpace(AppDimensions.space4),
                    Text(
                      transaction.description!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            AppDimensions.horizontalSpace(AppDimensions.space12),

            // Montant
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'} ${CurrencyUtils.format(transaction.amount)}',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isIncome ? AppColors.income : AppColors.expense,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (transaction.isRecurring) ...[
                  AppDimensions.verticalSpace(AppDimensions.space4),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.space8,
                      vertical: AppDimensions.space4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: AppDimensions.borderRadiusXS,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.repeat, size: 12, color: AppColors.info),
                        AppDimensions.horizontalSpace(AppDimensions.space4),
                        Text(
                          'Récurrent',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'cash':
        return 'Espèces';
      case 'card':
        return 'Carte';
      case 'bank_transfer':
        return 'Virement';
      case 'check':
        return 'Chèque';
      case 'mobile_money':
        return 'Mobile Money';
      default:
        return method;
    }
  }
}
