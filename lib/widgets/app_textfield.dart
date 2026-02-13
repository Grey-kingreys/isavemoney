import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_dimensions.dart';

/// Widget de champ de texte personnalisé
class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final String? errorText;
  final String? helperText;
  final bool autofocus;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.initialValue,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.errorText,
    this.helperText,
    this.autofocus = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppDimensions.verticalSpace(AppDimensions.space8),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTextStyles.hint,
            errorText: widget.errorText,
            helperText: widget.helperText,
            helperStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: AppColors.textSecondary)
                : null,
            suffixIcon: _buildSuffixIcon(),
            filled: true,
            fillColor: widget.enabled ? AppColors.grey100 : AppColors.grey200,
            contentPadding: AppDimensions.inputPadding,
            border: OutlineInputBorder(
              borderRadius: AppDimensions.borderRadiusInput,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppDimensions.borderRadiusInput,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppDimensions.borderRadiusInput,
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: AppDimensions.borderMedium,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppDimensions.borderRadiusInput,
              borderSide: const BorderSide(
                color: AppColors.error,
                width: AppDimensions.borderMedium,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppDimensions.borderRadiusInput,
              borderSide: const BorderSide(
                color: AppColors.error,
                width: AppDimensions.borderMedium,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: AppDimensions.borderRadiusInput,
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textSecondary,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(widget.suffixIcon, color: AppColors.textSecondary),
        onPressed: widget.onSuffixIconTap,
      );
    }

    return null;
  }
}

/// TextField spécialisé pour les montants
class AmountTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final String currencySymbol;

  const AmountTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.currencySymbol = '€',
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      hint: hint ?? 'Entrez le montant',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      prefixIcon: Icons.euro_rounded,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
    );
  }
}

/// TextField spécialisé pour la recherche
class SearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;

  const SearchTextField({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      hint: hint ?? 'Rechercher...',
      prefixIcon: Icons.search,
      suffixIcon: controller?.text.isNotEmpty == true ? Icons.clear : null,
      onSuffixIconTap: onClear ?? () => controller?.clear(),
      onChanged: onChanged,
    );
  }
}

/// TextField spécialisé pour les dates
class DateTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final void Function(DateTime)? onDateSelected;

  const DateTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      hint: hint ?? 'Sélectionner une date',
      readOnly: true,
      prefixIcon: Icons.calendar_today,
      onSuffixIconTap: () => _selectDate(context),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = '${picked.day}/${picked.month}/${picked.year}';
      onDateSelected?.call(picked);
    }
  }
}
