import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/app_button.dart';

/// Page de formulaire de budget (PLACEHOLDER - ÉTAPE 3)
class BudgetFormPage extends StatefulWidget {
  final int? budgetId;

  const BudgetFormPage({super.key, this.budgetId});

  @override
  State<BudgetFormPage> createState() => _BudgetFormPageState();
}

class _BudgetFormPageState extends State<BudgetFormPage> {
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.budgetId != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier le budget' : 'Créer un budget'),
      ),
      body: _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Padding(
        padding: AppDimensions.paddingPage,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.budgetLight,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🎯', style: TextStyle(fontSize: 60)),
              ),
            ),
            AppDimensions.verticalSpace(AppDimensions.space24),
            Text(
              'Formulaire de budget',
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            AppDimensions.verticalSpace(AppDimensions.space16),
            Text(
              'Cette page sera développée à l\'ÉTAPE 3\n\n'
              'Vous pourrez définir des limites de dépenses\n'
              'par catégorie et période.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            AppDimensions.verticalSpace(AppDimensions.space32),
            AppButton.primary(
              text: 'Retour',
              icon: Icons.arrow_back,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
