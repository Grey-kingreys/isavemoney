import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/budget_controller.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_textfield.dart';
import '../../widgets/category_chip.dart';

/// Page de formulaire de budget
class BudgetFormPage extends StatefulWidget {
  final int? budgetId;

  const BudgetFormPage({super.key, this.budgetId});

  @override
  State<BudgetFormPage> createState() => _BudgetFormPageState();
}

class _BudgetFormPageState extends State<BudgetFormPage> {
  final _formKey = GlobalKey<FormState>();
  late BudgetController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    final budgetProvider = context.read<BudgetProvider>();
    final categoryProvider = context.read<CategoryProvider>();

    _controller = BudgetController(
      budgetProvider: budgetProvider,
      categoryProvider: categoryProvider,
    );

    if (widget.budgetId != null) {
      _loadBudget();
    } else {
      _controller.initializeForNew();
    }
  }

  Future<void> _loadBudget() async {
    setState(() => _isLoading = true);

    final budget = await context.read<BudgetProvider>().getBudgetById(
      widget.budgetId!,
    );

    if (budget != null) {
      _controller.initializeForEdit(budget);
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.budgetId != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier le budget' : 'Créer un budget'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: AppDimensions.paddingPage,
        children: [
          // Information card
          _buildInfoCard(),

          AppDimensions.verticalSpace(AppDimensions.space24),

          // Sélection de catégorie
          _buildCategorySection(),

          AppDimensions.verticalSpace(AppDimensions.space24),

          // Montant limite
          AmountTextField(
            controller: _controller.amountController,
            label: 'Montant limite',
            hint: 'Ex: 500',
            validator: (value) => _controller.validateForm()['amount'],
          ),

          AppDimensions.verticalSpace(AppDimensions.space24),

          // Type de période
          _buildPeriodSelector(),

          AppDimensions.verticalSpace(AppDimensions.space16),

          // Date de début
          DateTextField(
            controller: TextEditingController(
              text:
                  '${_controller.startDate.day}/${_controller.startDate.month}/${_controller.startDate.year}',
            ),
            label: 'Date de début',
            onDateSelected: (date) {
              setState(() => _controller.setStartDate(date));
            },
          ),

          AppDimensions.verticalSpace(AppDimensions.space24),

          // Section notifications
          _buildNotificationSection(),

          AppDimensions.verticalSpace(AppDimensions.space24),

          // État actif
          _buildActiveSwitch(),

          AppDimensions.verticalSpace(AppDimensions.space32),

          // Boutons d'action
          _buildActionButtons(),

          AppDimensions.verticalSpace(AppDimensions.space32),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: AppDimensions.cardElevation,
      color: AppColors.infoLight,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusCard,
      ),
      child: Padding(
        padding: AppDimensions.paddingCard,
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.info,
              size: AppDimensions.iconLG,
            ),
            AppDimensions.horizontalSpace(AppDimensions.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'À propos des budgets',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppDimensions.verticalSpace(AppDimensions.space4),
                  Text(
                    'Définissez une limite de dépenses pour\nune catégorie et recevez des alertes.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final categories = _controller.getExpenseCategories();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catégorie de dépense',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppDimensions.verticalSpace(AppDimensions.space12),

            if (categories.isEmpty)
              Text(
                'Aucune catégorie de dépense disponible',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            else
              Wrap(
                spacing: AppDimensions.space8,
                runSpacing: AppDimensions.space8,
                children: categories.map((category) {
                  return CategoryChip(
                    category: category,
                    isSelected: _controller.selectedCategoryId == category.id,
                    onTap: () {
                      // ✅ CORRECTION: Utiliser addPostFrameCallback
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(
                          () => _controller.selectCategory(category.id!),
                        );
                      });
                    },
                    compact: false,
                  );
                }).toList(),
              ),

            if (_controller.selectedCategoryId == null)
              Padding(
                padding: AppDimensions.paddingVerticalSM,
                child: Text(
                  'Veuillez sélectionner une catégorie',
                  style: AppTextStyles.error,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPeriodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Période du budget',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppDimensions.verticalSpace(AppDimensions.space12),

        Card(
          elevation: AppDimensions.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusCard,
          ),
          child: Padding(
            padding: AppDimensions.paddingCard,
            child: Column(
              children: [
                _buildPeriodButton('Journalier', 'daily', Icons.today),
                _buildPeriodButton('Hebdomadaire', 'weekly', Icons.view_week),
                _buildPeriodButton('Mensuel', 'monthly', Icons.calendar_month),
                _buildPeriodButton('Annuel', 'yearly', Icons.calendar_today),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodButton(String label, String value, IconData icon) {
    final isSelected = _controller.periodType == value;

    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.space8),
      child: InkWell(
        onTap: () {
          // ✅ Pas besoin de addPostFrameCallback ici (pas dans un Consumer)
          setState(() => _controller.setPeriodType(value));
        },
        borderRadius: AppDimensions.borderRadiusSM,
        child: Container(
          padding: AppDimensions.paddingMD,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.budget.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: AppDimensions.borderRadiusSM,
            border: Border.all(
              color: isSelected ? AppColors.budget : AppColors.grey300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.budget : AppColors.textSecondary,
                size: AppDimensions.iconMD,
              ),
              AppDimensions.horizontalSpace(AppDimensions.space16),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isSelected
                        ? AppColors.budget
                        : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.budget,
                  size: AppDimensions.iconMD,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusCard,
      ),
      child: Padding(
        padding: AppDimensions.paddingCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Activer les notifications'),
              subtitle: const Text('Recevoir des alertes'),
              value: _controller.notificationsEnabled,
              onChanged: (value) {
                setState(() => _controller.toggleNotifications(value));
              },
              contentPadding: EdgeInsets.zero,
            ),

            if (_controller.notificationsEnabled) ...[
              AppDimensions.verticalSpace(AppDimensions.space16),

              Text(
                'Seuil d\'alerte : ${_controller.notificationThreshold.toInt()}%',
                style: AppTextStyles.labelLarge,
              ),

              AppDimensions.verticalSpace(AppDimensions.space8),

              Slider(
                value: _controller.notificationThreshold,
                min: 50,
                max: 100,
                divisions: 10,
                label: '${_controller.notificationThreshold.toInt()}%',
                onChanged: (value) {
                  setState(() => _controller.setNotificationThreshold(value));
                },
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '50%',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '100%',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              AppDimensions.verticalSpace(AppDimensions.space8),

              Container(
                padding: AppDimensions.paddingSM,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: AppDimensions.borderRadiusXS,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_active,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    AppDimensions.horizontalSpace(AppDimensions.space8),
                    Expanded(
                      child: Text(
                        'Vous serez alerté quand vous atteignez ${_controller.notificationThreshold.toInt()}% du budget',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSwitch() {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusCard,
      ),
      child: SwitchListTile(
        title: const Text('Budget actif'),
        subtitle: const Text('Le budget est pris en compte'),
        value: _controller.isActive,
        onChanged: (value) {
          setState(() => _controller.toggleActive(value));
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    final isEditing = widget.budgetId != null;

    return Row(
      children: [
        Expanded(
          child: AppButton.outlined(
            text: 'Annuler',
            onPressed: () => Navigator.pop(context),
          ),
        ),
        AppDimensions.horizontalSpace(AppDimensions.space16),
        Expanded(
          flex: 2,
          child: AppButton.primary(
            text: isEditing ? 'Enregistrer' : 'Créer',
            icon: isEditing ? Icons.check : Icons.add,
            onPressed: _saveBudget,
            isLoading: _isLoading,
          ),
        ),
      ],
    );
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate() ||
        _controller.selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs requis'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await _controller.saveBudget(id: widget.budgetId);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.budgetId != null
                ? 'Budget modifié avec succès'
                : 'Budget créé avec succès',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } else {
      final errorMessage =
          context.read<BudgetProvider>().error ??
          'Erreur lors de l\'enregistrement';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le budget ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _deleteBudget();
    }
  }

  Future<void> _deleteBudget() async {
    setState(() => _isLoading = true);

    final success = await _controller.deleteBudget(widget.budgetId!);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Budget supprimé'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la suppression'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
