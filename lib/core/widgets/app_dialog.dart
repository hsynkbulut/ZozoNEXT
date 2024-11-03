import 'package:flutter/material.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';
import 'package:teachmate_pro/core/widgets/app_button.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String? message;
  final List<Widget>? actions;
  final Widget? content;
  final bool showCloseButton;

  const AppDialog({
    super.key,
    required this.title,
    this.message,
    this.actions,
    this.content,
    this.showCloseButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.headlineSmall,
                  ),
                ),
                if (showCloseButton)
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (content != null) ...[
              const SizedBox(height: 16),
              content!,
            ],
            if (actions != null) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!
                    .map((action) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: action,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? message,
    List<Widget>? actions,
    Widget? content,
    bool showCloseButton = true,
    bool barrierDismissible = true,
    Color? barrierColor,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      builder: (context) => AppDialog(
        title: title,
        message: message,
        actions: actions,
        content: content,
        showCloseButton: showCloseButton,
      ),
    );
  }

  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    String? message,
    String confirmText = 'Onayla',
    String cancelText = 'İptal',
    bool isDestructive = false,
  }) {
    return show<bool>(
      context: context,
      title: title,
      message: message,
      actions: [
        AppButton(
          text: cancelText,
          onPressed: () => Navigator.of(context).pop(false),
          variant: AppButtonVariant.text,
          fullWidth: false,
        ),
        AppButton(
          text: confirmText,
          onPressed: () => Navigator.of(context).pop(true),
          variant:
              isDestructive ? AppButtonVariant.text : AppButtonVariant.primary,
          fullWidth: false,
        ),
      ],
    );
  }
}
