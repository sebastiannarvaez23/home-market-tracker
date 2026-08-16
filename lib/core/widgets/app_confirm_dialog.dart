import 'package:flutter/material.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_radii.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_button.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';

abstract final class AppConfirmDialog {
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String confirmLabel,
    String cancelLabel = AppStrings.cancel,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x59000000),
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  title,
                  variant: AppTextVariant.title,
                  align: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: confirmLabel,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: cancelLabel,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
          ),
        );
      },
    );
    return confirmed ?? false;
  }
}
