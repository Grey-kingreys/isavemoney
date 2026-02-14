import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/transaction_controller.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/category_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_textfield.dart';
import '../../widgets/category_chip.dart';

/// Page de formulaire de transaction
class TransactionForm extends StatefulWidget {
  final int? transactionId;

  const TransactionForm({super.key, this.transactionId});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late TransactionController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    final transactionProvider = context.read<TransactionProvider>();
    final categoryProvider = context.read<CategoryProvider>();

    _controller = TransactionController(
      transactionProvider: transactionProvider,
      categoryProvider: categoryProvider,
    );

    if (widget.transactionId != null) {
      _loadTransaction();
    } else {
      _controller.initializeForNew();
    }
  }

  Future<void> _loadTransaction() async {
    setState(() => _isLoading = true);

    final transaction = context
        .read<TransactionProvider>()
        .allTransactions
        .firstWhere((t) => t.id == widget.transactionId);

    _controller.initializeForEdit(transaction);

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transactionId != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Modifier la transaction' : 'Nouvelle transaction',
        ),
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
          // Sélecteur de type (Revenu/Dépense)
          _buildTypeSelector(),

          AppDimensions.verticalSpace(AppDimensions.space24),

          // Titre
          AppTextField(
            controller: _controller.titleController,
            label: 'Titre',
            hint: 'Ex: Courses, Salaire...',
            prefixIcon: Icons.title,
            validator: (value) => _controller.validateForm()['title'],
            textCapitalization: TextCapitalization.sentences,
          ),

          AppDimensions.verticalSpace(AppDimensions.space16),

          // Montant
          AmountTextField(
            controller: _controller.amountController,
            label: 'Montant',
            validator: (value) => _controller.validateForm()['amount'],
          ),

          AppDimensions.verticalSpace(AppDimensions.space24),

          // Sélection de catégorie
          _buildCategorySection(),

          AppDimensions.verticalSpace(AppDimensions.space24),

          // Date
          _buildDatePicker(),

          AppDimensions.verticalSpace(AppDimensions.space16),

          // Mode de paiement
          _buildPaymentMethodDropdown(),

          AppDimensions.verticalSpace(AppDimensions.space16),

          // Description (optionnelle)
          AppTextField(
            controller: _controller.descriptionController,
            label: 'Description (optionnel)',
            hint: 'Ajoutez des détails...',
            maxLines: 3,
            prefixIcon: Icons.note,
          ),

          AppDimensions.verticalSpace(AppDimensions.space16),

          // Lieu (optionnel)
          AppTextField(
            controller: _controller.locationController,
            label: 'Lieu (optionnel)',
            hint: 'Où a eu lieu cette transaction ?',
            prefixIcon: Icons.location_on,
            textCapitalization: TextCapitalization.words,
          ),

          AppDimensions.verticalSpace(AppDimensions.space24),

          // Transaction récurrente
          _buildRecurringSection(),

          AppDimensions.verticalSpace(AppDimensions.space32),

          // Boutons d'action
          _buildActionButtons(),

          AppDimensions.verticalSpace(AppDimensions.space32),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusCard,
      ),
      child: Padding(
        padding: AppDimensions.paddingCard,
        child: Row(
          children: [
            Expanded(
              child: _buildTypeButton(
                label: 'Dépense',
                icon: Icons.trending_down,
                color: AppColors.expense,
                isSelected: _controller.transactionType == 'expense',
                onTap: () {
                  setState(() => _controller.setTransactionType('expense'));
                },
              ),
            ),
            AppDimensions.horizontalSpace(AppDimensions.space16),
            Expanded(
              child: _buildTypeButton(
                label: 'Revenu',
                icon: Icons.trending_up,
                color: AppColors.income,
                isSelected: _controller.transactionType == 'income',
                onTap: () {
                  setState(() => _controller.setTransactionType('income'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppDimensions.paddingMD,
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.white,
          borderRadius: AppDimensions.borderRadiusMD,
          border: Border.all(
            color: isSelected ? color : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.white : color,
              size: AppDimensions.iconLG,
            ),
            AppDimensions.verticalSpace(AppDimensions.space8),
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
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
        final categories = _controller.getAvailableCategories();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catégorie',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppDimensions.verticalSpace(AppDimensions.space12),

            Wrap(
              spacing: AppDimensions.space8,
              runSpacing: AppDimensions.space8,
              children: categories.map((category) {
                return CategoryChip(
                  category: category,
                  isSelected: _controller.selectedCategoryId == category.id,
                  onTap: () {
                    // ✅ Utilise un callback après le build
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() => _controller.selectCategory(category.id!));
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

  Widget _buildDatePicker() {
    return DateTextField(
      controller: TextEditingController(
        text:
            '${_controller.selectedDate.day}/${_controller.selectedDate.month}/${_controller.selectedDate.year}',
      ),
      label: 'Date',
      onDateSelected: (date) {
        setState(() => _controller.setDate(date));
      },
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mode de paiement',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppDimensions.verticalSpace(AppDimensions.space8),

        DropdownButtonFormField<String>(
          value: _controller.selectedPaymentMethod,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.grey100,
            prefixIcon: const Icon(Icons.payment),
            border: OutlineInputBorder(
              borderRadius: AppDimensions.borderRadiusInput,
              borderSide: BorderSide.none,
            ),
          ),
          hint: const Text('Sélectionner un mode'),
          items: const [
            DropdownMenuItem(value: 'cash', child: Text('Espèces')),
            DropdownMenuItem(value: 'card', child: Text('Carte bancaire')),
            DropdownMenuItem(value: 'bank_transfer', child: Text('Virement')),
            DropdownMenuItem(value: 'check', child: Text('Chèque')),
            DropdownMenuItem(
              value: 'mobile_money',
              child: Text('Mobile Money'),
            ),
          ],
          onChanged: (value) {
            setState(() => _controller.setPaymentMethod(value));
          },
        ),
      ],
    );
  }

  Widget _buildRecurringSection() {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusCard,
      ),
      child: Padding(
        padding: AppDimensions.paddingCard,
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Transaction récurrente'),
              subtitle: const Text('Se répète automatiquement'),
              value: _controller.isRecurring,
              onChanged: (value) {
                setState(() => _controller.toggleRecurring(value));
              },
              contentPadding: EdgeInsets.zero,
            ),

            if (_controller.isRecurring) ...[
              AppDimensions.verticalSpace(AppDimensions.space16),
              DropdownButtonFormField<String>(
                value: _controller.recurringPattern,
                decoration: const InputDecoration(
                  labelText: 'Fréquence',
                  prefixIcon: Icon(Icons.repeat),
                ),
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Quotidien')),
                  DropdownMenuItem(
                    value: 'weekly',
                    child: Text('Hebdomadaire'),
                  ),
                  DropdownMenuItem(value: 'monthly', child: Text('Mensuel')),
                  DropdownMenuItem(value: 'yearly', child: Text('Annuel')),
                ],
                onChanged: (value) {
                  setState(() => _controller.setRecurringPattern(value));
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final isEditing = widget.transactionId != null;

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
            text: isEditing ? 'Enregistrer' : 'Ajouter',
            icon: isEditing ? Icons.check : Icons.add,
            onPressed: _saveTransaction,
            isLoading: _isLoading,
          ),
        ),
      ],
    );
  }

  Future<void> _saveTransaction() async {
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

    final success = await _controller.saveTransaction(id: widget.transactionId);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.transactionId != null
                ? 'Transaction modifiée avec succès'
                : 'Transaction ajoutée avec succès',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'enregistrement'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la transaction ?'),
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
      _deleteTransaction();
    }
  }

  Future<void> _deleteTransaction() async {
    setState(() => _isLoading = true);

    final success = await _controller.deleteTransaction(widget.transactionId!);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction supprimée'),
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
