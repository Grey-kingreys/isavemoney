import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_dimensions.dart';

/// Types de boutons disponibles
enum AppButtonType { primary, secondary, text, outlined, danger }

/// Tailles de boutons disponibles
enum AppButtonSize { small, medium, large }

/// Widget bouton personnalisé et réutilisable
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final IconData? icon;
  final bool iconRight;
  final bool isLoading;
  final bool fullWidth;
  final Color? customColor;
  final double? customWidth;
  final double? customHeight;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.iconRight = false,
    this.isLoading = false,
    this.fullWidth = false,
    this.customColor,
    this.customWidth,
    this.customHeight,
  });

  // Constructeurs nommés pour faciliter l'utilisation
  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.iconRight = false,
    this.isLoading = false,
    this.fullWidth = false,
    this.customColor,
    this.customWidth,
    this.customHeight,
  }) : type = AppButtonType.primary;

  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.iconRight = false,
    this.isLoading = false,
    this.fullWidth = false,
    this.customColor,
    this.customWidth,
    this.customHeight,
  }) : type = AppButtonType.secondary;

  const AppButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.iconRight = false,
    this.isLoading = false,
    this.fullWidth = false,
    this.customColor,
    this.customWidth,
    this.customHeight,
  }) : type = AppButtonType.text;

  const AppButton.outlined({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.iconRight = false,
    this.isLoading = false,
    this.fullWidth = false,
    this.customColor,
    this.customWidth,
    this.customHeight,
  }) : type = AppButtonType.outlined;

  const AppButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.iconRight = false,
    this.isLoading = false,
    this.fullWidth = false,
    this.customColor,
    this.customWidth,
    this.customHeight,
  }) : type = AppButtonType.danger;

  @override
  Widget build(BuildContext context) {
    final height = customHeight ?? _getHeight();
    final width = fullWidth ? double.infinity : customWidth;

    return SizedBox(height: height, width: width, child: _buildButton(context));
  }

  Widget _buildButton(BuildContext context) {
    if (isLoading) {
      return _buildLoadingButton();
    }

    switch (type) {
      case AppButtonType.primary:
        return _buildPrimaryButton(context);
      case AppButtonType.secondary:
        return _buildSecondaryButton(context);
      case AppButtonType.text:
        return _buildTextButton(context);
      case AppButtonType.outlined:
        return _buildOutlinedButton(context);
      case AppButtonType.danger:
        return _buildDangerButton(context);
    }
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: customColor ?? AppColors.primary,
        foregroundColor: AppColors.white,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusButton,
        ),
        elevation: AppDimensions.cardElevation,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildSecondaryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: customColor ?? AppColors.secondary,
        foregroundColor: AppColors.white,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusButton,
        ),
        elevation: AppDimensions.cardElevation,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildTextButton(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: customColor ?? AppColors.primary,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusButton,
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: customColor ?? AppColors.primary,
        padding: _getPadding(),
        side: BorderSide(
          color: customColor ?? AppColors.primary,
          width: AppDimensions.borderMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusButton,
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildDangerButton(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: customColor ?? AppColors.error,
        foregroundColor: AppColors.white,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusButton,
        ),
        elevation: AppDimensions.cardElevation,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildLoadingButton() {
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.grey300,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusButton,
        ),
      ),
      child: SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == AppButtonType.text || type == AppButtonType.outlined
                ? AppColors.primary
                : AppColors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (icon == null) {
      return Text(text, style: _getTextStyle());
    }

    if (iconRight) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text, style: _getTextStyle()),
          AppDimensions.horizontalSpace(AppDimensions.space8),
          Icon(icon, size: _getIconSize()),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: _getIconSize()),
        AppDimensions.horizontalSpace(AppDimensions.space8),
        Text(text, style: _getTextStyle()),
      ],
    );
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return AppDimensions.buttonHeightSM;
      case AppButtonSize.medium:
        return AppDimensions.buttonHeightMD;
      case AppButtonSize.large:
        return AppDimensions.buttonHeightLG;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return AppDimensions.buttonPaddingSM;
      case AppButtonSize.medium:
        return AppDimensions.buttonPadding;
      case AppButtonSize.large:
        return AppDimensions.buttonPaddingLG;
    }
  }

  TextStyle _getTextStyle() {
    final baseStyle = size == AppButtonSize.small
        ? AppTextStyles.labelMedium
        : size == AppButtonSize.large
        ? AppTextStyles.labelLarge.copyWith(fontSize: 16)
        : AppTextStyles.buttonPrimary;

    return baseStyle.copyWith(fontWeight: FontWeight.w600);
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return AppDimensions.iconSM;
      case AppButtonSize.medium:
        return AppDimensions.iconMD;
      case AppButtonSize.large:
        return AppDimensions.iconLG;
    }
  }
}

/// Widget bouton icône (FAB style)
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final bool mini;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize =
        size ?? (mini ? AppDimensions.fabSizeSM : AppDimensions.fabSize);

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        gradient: backgroundColor == null ? AppColors.primaryGradient : null,
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Center(
            child: Icon(
              icon,
              color: iconColor ?? AppColors.white,
              size: mini ? AppDimensions.iconMD : AppDimensions.iconLG,
            ),
          ),
        ),
      ),
    );
  }
}
