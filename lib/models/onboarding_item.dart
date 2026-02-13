/// Modèle pour un élément d'onboarding
class OnboardingItem {
  final String title;
  final String description;
  final String image;
  final String? icon;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.image,
    this.icon,
  });
}

/// Liste des slides d'onboarding
class OnboardingData {
  static const List<OnboardingItem> items = [
    OnboardingItem(
      title: 'Gérez votre Budget',
      description:
          'Prenez le contrôle de vos finances avec un suivi simple et efficace de vos revenus et dépenses.',
      image: '💰',
      icon: null,
    ),
    OnboardingItem(
      title: 'Suivez vos Dépenses',
      description:
          'Visualisez où va votre argent avec des graphiques clairs et des catégories personnalisables.',
      image: '📊',
      icon: null,
    ),
    OnboardingItem(
      title: 'Atteignez vos Objectifs',
      description:
          'Définissez des objectifs d\'épargne et suivez votre progression pour réaliser vos projets.',
      image: '🎯',
      icon: null,
    ),
  ];
}
