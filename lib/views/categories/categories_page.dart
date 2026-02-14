import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/common/empty_view.dart';

/// Page de gestion des catégories (PLACEHOLDER - ÉTAPE 5)
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Catégories')),
      body: EmptyView(
        emoji: '🏷️',
        title: 'Gestion des catégories',
        message:
            'Cette page sera disponible à l\'ÉTAPE 5\n\n'
            'Vous pourrez créer, modifier et organiser\n'
            'vos catégories de transactions.',
        fullScreen: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showComingSoon(context);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Disponible à l\'ÉTAPE 5'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
