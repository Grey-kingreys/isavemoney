import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/common/empty_view.dart';

/// Page de gestion des comptes bancaires (PLACEHOLDER - ÉTAPE 5)
class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Comptes bancaires')),
      body: EmptyView(
        emoji: '🏦',
        title: 'Gestion des comptes',
        message:
            'Cette page sera disponible à l\'ÉTAPE 5\n\n'
            'Vous pourrez gérer vos différents comptes\n'
            'bancaires et cartes de crédit.',
        fullScreen: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showComingSoon(context);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter un compte'),
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
