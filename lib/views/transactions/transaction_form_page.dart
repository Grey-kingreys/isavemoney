import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/account_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_textfield.dart';

class TransactionFormPage extends StatefulWidget {
  final bool isEdit;
  final int? transactionId;

  const TransactionFormPage({
    super.key,
    this.isEdit = false,
    this.transactionId,
  });

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  // Valeurs du formulaire
  String _selectedType = 'expense';
  int? _selectedCategoryId;
  int? _selectedAccountId;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.transactionId != null) {
      _loadTransaction();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
      context.read<AccountProvider>().loadAccounts();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadTransaction() async {
    // TODO: Charger la transaction existante
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppDimensions.paddingPage,
          children: [
            // Sélecteur de type
            _buildTypeSelector(),

            AppDimensions.verticalSpace(AppDimensions.space24),

            // Montant
            AppTextField(
              controller: _amountController,
              label: 'Montant (FCFA)',
              hint: '0',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.attach_money,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un montant';
                }
                if (double.tryParse(value) == null) {
                  return 'Montant invalide';
                }
                return null;
              },
            ),

            AppDimensions.verticalSpace(AppDimensions.space16),

            // Description
            AppTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Ex: Courses au supermarché',
              prefixIcon: Icons.description,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une description';
                }
                return null;
              },
            ),

            AppDimensions.verticalSpace(AppDimensions.space16),

            // Catégorie
            _buildCategorySelector(),

            AppDimensions.verticalSpace(AppDimensions.space16),

            // Compte
            _buildAccountSelector(),

            AppDimensions.verticalSpace(AppDimensions.space16),

            // Date
            _buildDateSelector(),

            AppDimensions.verticalSpace(AppDimensions.space16),

            // Notes (optionnel)
            AppTextField(
              controller: _notesController,
              label: 'Notes (optionnel)',
              hint: 'Ajoutez des notes...',
              maxLines: 3,
              prefixIcon: Icons.note,
            ),

            AppDimensions.verticalSpace(AppDimensions.space16),

            // Transaction récurrente
            _buildRecurringSwitch(),

            AppDimensions.verticalSpace(AppDimensions.space32),

            // Bouton de soumission
            AppButton.primary(
              text: widget.isEdit ? 'Modifier' : 'Ajouter',
              onPressed: _submitForm,
              icon: widget.isEdit ? Icons.save : Icons.add,
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      title: Text(
        widget.isEdit ? 'Modifier la transaction' : 'Nouvelle transaction',
      ),
      elevation: 0,
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space4),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMD),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeButton(
              'Dépense',
              'expense',
              Icons.arrow_downward,
              AppColors.error,
            ),
          ),
          Expanded(
            child: _buildTypeButton(
              'Revenu',
              'income',
              Icons.arrow_upward,
              AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = value;
          _selectedCategoryId = null; // Reset category when type changes
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.space16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSM),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.white : AppColors.textSecondary,
              size: AppDimensions.iconSM,
            ),
            AppDimensions.horizontalSpace(AppDimensions.space8),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        final categories = provider.categories
            .where((cat) => cat.type == _selectedType)
            .toList();

        return DropdownButtonFormField<int>(
          value: _selectedCategoryId,
          decoration: InputDecoration(
            labelText: 'Catégorie',
            prefixIcon: const Icon(Icons.category),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMD),
            ),
          ),
          items: categories.map((category) {
            return DropdownMenuItem<int>(
              value: category.id,
              child: Text(category.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategoryId = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Veuillez sélectionner une catégorie';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildAccountSelector() {
    return Consumer<AccountProvider>(
      builder: (context, provider, child) {
        return DropdownButtonFormField<int>(
          value: _selectedAccountId,
          decoration: InputDecoration(
            labelText: 'Compte',
            prefixIcon: const Icon(Icons.account_balance),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMD),
            ),
          ),
          items: provider.accounts.map((account) {
            return DropdownMenuItem<int>(
              value: account.id,
              child: Text(account.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedAccountId = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Veuillez sélectionner un compte';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date',
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMD),
          ),
        ),
        child: Text(
          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
          style: AppTextStyles.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildRecurringSwitch() {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusCard,
      ),
      child: SwitchListTile(
        value: _isRecurring,
        onChanged: (value) {
          setState(() {
            _isRecurring = value;
          });
        },
        title: const Text('Transaction récurrente'),
        subtitle: const Text('Cette transaction se répète chaque mois'),
        activeColor: AppColors.primary,
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // TODO: Implémenter la sauvegarde
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEdit ? 'Transaction modifiée' : 'Transaction ajoutée',
          ),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context);
    }
  }
}
