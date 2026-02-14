import 'package:flutter/material.dart';
import '../models/onboarding_item.dart';
import '../widgets/onboarding_slide.dart';
import '../services/onboarding_service.dart';
import '../app/routes.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_dimensions.dart';
import '../utils/app_animations.dart';

/// Page d'onboarding affichée au premier lancement
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final OnboardingService _onboardingService = OnboardingService();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeOnboarding() async {
    await _onboardingService.completeOnboarding();
    if (mounted) {
      // Navigation vers le nouveau dashboard
      AppRoutes.navigateAndRemoveUntil(context, AppRoutes.dashboard);
    }
  }

  void _nextPage() {
    if (_currentPage < OnboardingData.items.length - 1) {
      _pageController.nextPage(
        duration: AppAnimations.durationNormal,
        curve: AppAnimations.curveFastStart,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Bouton "Passer" en haut à droite
            Padding(
              padding: AppDimensions.paddingLG,
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Passer',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            // PageView avec les slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: OnboardingData.items.length,
                itemBuilder: (context, index) {
                  return OnboardingSlide(
                    item: OnboardingData.items[index],
                    isLastSlide: index == OnboardingData.items.length - 1,
                  );
                },
              ),
            ),

            // Indicateurs de page
            Padding(
              padding: AppDimensions.paddingVerticalLG,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  OnboardingData.items.length,
                  (index) => _buildPageIndicator(index),
                ),
              ),
            ),

            // Bouton "Suivant" ou "Commencer"
            Padding(
              padding: EdgeInsets.only(
                left: AppDimensions.space24,
                right: AppDimensions.space24,
                bottom: AppDimensions.space32,
              ),
              child: SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeightLG,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDimensions.borderRadiusButton,
                    ),
                  ),
                  child: Text(
                    _currentPage == OnboardingData.items.length - 1
                        ? 'Commencer'
                        : 'Suivant',
                    style: AppTextStyles.buttonPrimary.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = index == _currentPage;

    return AnimatedContainer(
      duration: AppAnimations.durationQuick,
      curve: AppAnimations.curveDefault,
      margin: EdgeInsets.symmetric(horizontal: AppDimensions.space4),
      width: isActive ? AppDimensions.space32 : AppDimensions.space8,
      height: AppDimensions.space8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.grey300,
        borderRadius: AppDimensions.borderRadiusXS,
      ),
    );
  }
}
