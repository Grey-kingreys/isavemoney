import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/app_button.dart';

/// Page de formulaire de transaction (PLACEHOLDER - ÉTAPE 2)
class TransactionFormPage extends StatefulWidget {
  final int? transactionId;

  const TransactionFormPage({super.key, this.transactionId});

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transactionId != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier' : 'Nouvelle transaction'),
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
            Icon(
              Icons.construction,
              size: AppDimensions.icon3XL,
              color: AppColors.primary,
            ),
            AppDimensions.verticalSpace(AppDimensions.space24),
            Text(
              'Formulaire de transaction',
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            AppDimensions.verticalSpace(AppDimensions.space16),
            Text(
              'Cette page sera développée à l\'ÉTAPE 2',
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
