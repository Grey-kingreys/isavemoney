/// Modèle pour un élément d'onboarding
class OnboardingItem {
  final String image; // Emoji ou path vers l'image
  final String title;
  final String description;

  const OnboardingItem({
    required this.image,
    required this.title,
    required this.description,
  });
}

/// Données des slides d'onboarding
class OnboardingData {
  static const List<OnboardingItem> items = [
    OnboardingItem(
      image: '💰',
      title: 'Gérez votre budget',
      description:
          'Suivez facilement vos revenus et dépenses au quotidien. '
          'Gardez le contrôle total de vos finances personnelles.',
    ),
    OnboardingItem(
      image: '📊',
      title: 'Visualisez vos finances',
      description:
          'Analysez vos habitudes de dépenses avec des graphiques clairs. '
          'Comprenez où va votre argent en un coup d\'œil.',
    ),
    OnboardingItem(
      image: '🎯',
      title: 'Définissez vos objectifs',
      description:
          'Créez des budgets par catégorie et recevez des alertes. '
          'Atteignez vos objectifs financiers plus facilement.',
    ),
    OnboardingItem(
      image: '🔒',
      title: 'Vos données en sécurité',
      description:
          'Toutes vos données restent sur votre appareil. '
          'Aucune connexion internet requise, confidentialité garantie.',
    ),
  ];
}
