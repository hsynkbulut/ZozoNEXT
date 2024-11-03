import 'package:flutter/material.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool readOnly;
  final FocusNode? focusNode;
  final String? initialValue;
  final TextCapitalization textCapitalization;
  final EdgeInsets? contentPadding;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onTap,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
    this.suffix,
    this.readOnly = false,
    this.focusNode,
    this.initialValue,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
  });

  @override
  Widget build(BuildContext context) {
    final isMultiline = maxLines != 1 || minLines != null;
    final effectiveMinLines = minLines ?? 1;
    final effectiveMaxLines = maxLines ?? 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label!,
              style: AppTextStyles.labelMedium,
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.surface
                : AppColors.textSecondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            initialValue: initialValue,
            focusNode: focusNode,
            maxLines: maxLines,
            minLines: minLines,
            keyboardType: isMultiline ? TextInputType.multiline : keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              errorText: errorText,
              errorStyle: AppTextStyles.caption.copyWith(
                color: AppColors.error,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      color: AppColors.textSecondary,
                      size: 20,
                    )
                  : null,
              suffixIcon: suffix,
              isDense: true,
              contentPadding: contentPadding ??
                  EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isMultiline ? 12 : 14,
                  ),
              filled: true,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              errorMaxLines: 2,
            ),
            style: enabled
                ? AppTextStyles.bodyMedium
                : AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
            textAlignVertical: TextAlignVertical.center,
            obscureText: obscureText,
            textInputAction:
                isMultiline ? TextInputAction.newline : textInputAction,
            onChanged: onChanged,
            onTap: onTap,
            validator: validator,
            enabled: enabled,
            readOnly: readOnly,
            textCapitalization: textCapitalization,
            autofocus: autofocus,
          ),
        ),
      ],
    );
  }
}
