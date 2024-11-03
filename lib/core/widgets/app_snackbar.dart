import 'package:flutter/material.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';

enum AppSnackBarType {
  success,
  error,
  warning,
  info,
}

class AppSnackBar extends SnackBar {
  AppSnackBar({
    super.key,
    required String message,
    AppSnackBarType type = AppSnackBarType.info,
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 4),
  }) : super(
          content: Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: _getBackgroundColor(type),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: duration,
          action: actionLabel != null && onAction != null
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: Colors.white,
                  onPressed: onAction,
                )
              : null,
        );

  static Color _getBackgroundColor(AppSnackBarType type) {
    switch (type) {
      case AppSnackBarType.success:
        return AppColors.success;
      case AppSnackBarType.error:
        return AppColors.error;
      case AppSnackBarType.warning:
        return AppColors.warning;
      case AppSnackBarType.info:
        return AppColors.primary;
    }
  }

  static void show({
    required BuildContext context,
    required String message,
    AppSnackBarType type = AppSnackBarType.info,
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      AppSnackBar(
        message: message,
        type: type,
        onAction: onAction,
        actionLabel: actionLabel,
        duration: duration,
      ),
    );
  }

  static void showSuccess({
    required BuildContext context,
    required String message,
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context: context,
      message: message,
      type: AppSnackBarType.success,
      onAction: onAction,
      actionLabel: actionLabel,
      duration: duration,
    );
  }

  static void showError({
    required BuildContext context,
    required String message,
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context: context,
      message: message,
      type: AppSnackBarType.error,
      onAction: onAction,
      actionLabel: actionLabel,
      duration: duration,
    );
  }

  static void showWarning({
    required BuildContext context,
    required String message,
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context: context,
      message: message,
      type: AppSnackBarType.warning,
      onAction: onAction,
      actionLabel: actionLabel,
      duration: duration,
    );
  }

  static void showInfo({
    required BuildContext context,
    required String message,
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context: context,
      message: message,
      type: AppSnackBarType.info,
      onAction: onAction,
      actionLabel: actionLabel,
      duration: duration,
    );
  }
}
