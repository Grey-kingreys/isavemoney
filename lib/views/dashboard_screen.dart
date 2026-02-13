import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_dimensions.dart';

/// Écran Dashboard principal (version temporaire)
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: AppDimensions.paddingPage,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.dashboard,
                    size: 50,
                    color: AppColors.white,
                  ),
                ),
              ),

              AppDimensions.verticalSpace(AppDimensions.space32),

              // Titre
              Text(
                'Bienvenue sur BudgetBuddy! 🎉',
                style: AppTextStyles.headlineMedium,
                textAlign: TextAlign.center,
              ),

              AppDimensions.verticalSpace(AppDimensions.space16),

              // Message
              Text(
                'Votre dashboard sera bientôt disponible ici.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              AppDimensions.verticalSpace(AppDimensions.space48),

              // Bouton pour réinitialiser l'onboarding (pour tester)
              OutlinedButton.icon(
                onPressed: () async {
                  // Pour tester : réinitialiser l'onboarding
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('has_seen_onboarding');

                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/');
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Revoir l\'onboarding'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
