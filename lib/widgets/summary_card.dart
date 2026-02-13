import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_dimensions.dart';
import '../utils/currency_utils.dart';

/// Widget de carte de résumé pour afficher les statistiques
class SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Gradient gradient;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showCurrency;
  final Color? textColor;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.gradient,
    this.subtitle,
    this.onTap,
    this.showCurrency = true,
    this.textColor,
  });

  // Constructeurs nommés pour les types courants
  factory SummaryCard.income({
    required double amount,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return SummaryCard(
      title: 'Revenus',
      amount: amount,
      icon: Icons.trending_up,
      gradient: AppColors.incomeGradient,
      subtitle: subtitle,
      onTap: onTap,
    );
  }

  factory SummaryCard.expense({
    required double amount,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return SummaryCard(
      title: 'Dépenses',
      amount: amount,
      icon: Icons.trending_down,
      gradient: AppColors.expenseGradient,
      subtitle: subtitle,
      onTap: onTap,
    );
  }

  factory SummaryCard.balance({
    required double amount,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return SummaryCard(
      title: 'Solde',
      amount: amount,
      icon: Icons.account_balance_wallet,
      gradient: AppColors.primaryGradient,
      subtitle: subtitle,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusCard,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.borderRadiusCard,
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: AppDimensions.borderRadiusCard,
          ),
          padding: AppDimensions.paddingCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône et titre
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.space8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: AppDimensions.borderRadiusSM,
                    ),
                    child: Icon(
                      icon,
                      color: textColor ?? AppColors.white,
                      size: AppDimensions.iconMD,
                    ),
                  ),
                  AppDimensions.horizontalSpace(AppDimensions.space12),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: (textColor ?? AppColors.white).withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              AppDimensions.verticalSpace(AppDimensions.space16),

              // Montant
              Text(
                showCurrency
                    ? CurrencyUtils.format(amount)
                    : amount.toStringAsFixed(0),
                style: AppTextStyles.currencyLarge.copyWith(
                  color: textColor ?? AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),

              // Sous-titre optionnel
              if (subtitle != null) ...[
                AppDimensions.verticalSpace(AppDimensions.space4),
                Text(
                  subtitle!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: (textColor ?? AppColors.white).withOpacity(0.85),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget de carte de statistique compacte
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor = AppColors.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusCard,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.borderRadiusCard,
        child: Padding(
          padding: AppDimensions.paddingCardSmall,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.space8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: AppDimensions.borderRadiusSM,
                ),
                child: Icon(icon, color: iconColor, size: AppDimensions.iconMD),
              ),
              AppDimensions.horizontalSpace(AppDimensions.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    AppDimensions.verticalSpace(AppDimensions.space4),
                    Text(
                      value,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget de carte de pourcentage (budget)
class PercentageCard extends StatelessWidget {
  final String title;
  final double percentage;
  final double spent;
  final double limit;
  final Color color;
  final VoidCallback? onTap;

  const PercentageCard({
    super.key,
    required this.title,
    required this.percentage,
    required this.spent,
    required this.limit,
    this.color = AppColors.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isExceeded = percentage > 100;
    final displayColor = isExceeded ? AppColors.error : color;

    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusCard,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.borderRadiusCard,
        child: Padding(
          padding: AppDimensions.paddingCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre et pourcentage
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: displayColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              AppDimensions.verticalSpace(AppDimensions.space12),

              // Barre de progression
              ClipRRect(
                borderRadius: AppDimensions.borderRadiusXS,
                child: LinearProgressIndicator(
                  value: (percentage / 100).clamp(0.0, 1.0),
                  backgroundColor: AppColors.grey200,
                  valueColor: AlwaysStoppedAnimation<Color>(displayColor),
                  minHeight: 8,
                ),
              ),

              AppDimensions.verticalSpace(AppDimensions.space12),

              // Montants
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dépensé: ${CurrencyUtils.format(spent)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Limite: ${CurrencyUtils.format(limit)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
