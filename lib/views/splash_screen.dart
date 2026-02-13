import 'package:flutter/material.dart';
import '../services/onboarding_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_animations.dart';

/// Écran de démarrage qui vérifie si l'onboarding a été vu
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final OnboardingService _onboardingService = OnboardingService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkOnboardingStatus();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: AppAnimations.durationSlow,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.curveDefault,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.curveFastStart,
      ),
    );

    _animationController.forward();
  }

  Future<void> _checkOnboardingStatus() async {
    // Attendre que l'animation soit terminée
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Vérifier si l'onboarding a été vu
    final hasSeenOnboarding = await _onboardingService.hasSeenOnboarding();

    if (!mounted) return;

    // Naviguer vers la bonne page
    if (hasSeenOnboarding) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icône de l'app
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('💰', style: TextStyle(fontSize: 60)),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Nom de l'app
                  const Text(
                    'BudgetBuddy',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Slogan
                  Text(
                    'Gérez votre argent intelligemment',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
