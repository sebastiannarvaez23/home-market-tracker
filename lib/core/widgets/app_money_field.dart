import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/formatters/money_input_formatter.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_radii.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';

class AppMoneyField extends StatelessWidget {
  const AppMoneyField({
    super.key,
    this.controller,
    this.errorText,
    this.onDark = false,
    this.autofocus = false,
    this.onSubmitted,
    this.hint = AppStrings.addProductPriceHint,
  });

  final TextEditingController? controller;
  final String? errorText;
  final bool onDark;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final fill = onDark ? const Color(0x14FFFFFF) : AppColors.surface;
    final textColor = onDark ? AppColors.iconOnGradient : AppColors.textPrimary;
    final hintColor = onDark
        ? AppColors.iconOnGradient.withValues(alpha: 0.55)
        : AppColors.textMuted;
    final idleBorder = onDark
        ? const Color(0x73FFFFFF)
        : AppColors.purple.withValues(alpha: 0.18);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onSubmitted: onSubmitted,
          autofocus: autofocus,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            const MoneyInputTextFormatter(),
          ],
          textInputAction: TextInputAction.done,
          cursorColor: onDark ? AppColors.teal : AppColors.purple,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: hintColor,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: fill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              borderSide: BorderSide(color: idleBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              borderSide: BorderSide(color: idleBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              borderSide: BorderSide(
                color: onDark ? AppColors.teal : AppColors.purple,
                width: 1.4,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              borderSide: const BorderSide(color: AppColors.danger),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            errorText!,
            style: const TextStyle(
              color: Color(0xFFFFC2D0),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
