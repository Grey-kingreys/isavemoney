import 'package:flutter/material.dart';
import '../models/onboarding_item.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_dimensions.dart';

/// Widget pour afficher un slide d'onboarding
class OnboardingSlide extends StatelessWidget {
  final OnboardingItem item;
  final bool isLastSlide;

  const OnboardingSlide({
    super.key,
    required this.item,
    this.isLastSlide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimensions.paddingPageHorizontal,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image/Emoji
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(item.image, style: const TextStyle(fontSize: 100)),
            ),
          ),

          AppDimensions.verticalSpace(AppDimensions.space48),

          // Titre
          Text(
            item.title,
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          AppDimensions.verticalSpace(AppDimensions.space24),

          // Description
          Padding(
            padding: AppDimensions.paddingHorizontalXL,
            child: Text(
              item.description,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
