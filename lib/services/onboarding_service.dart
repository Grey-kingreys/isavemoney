import 'package:shared_preferences/shared_preferences.dart';

/// Service pour gérer l'état de l'onboarding
class OnboardingService {
  static const String _onboardingKey = 'has_seen_onboarding';

  /// Vérifie si l'utilisateur a déjà vu l'onboarding
  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  /// Marque l'onboarding comme vu
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  /// Réinitialise l'onboarding (pour les tests)
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingKey);
  }
}
