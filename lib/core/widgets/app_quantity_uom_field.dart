import 'package:flutter/widgets.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_select.dart';
import 'package:home_market_tracker/core/widgets/app_text_field.dart';

class AppQuantityUomField<T> extends StatelessWidget {
  const AppQuantityUomField({
    super.key,
    required this.quantityController,
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onUomChanged,
    this.onDark = false,
    this.quantityHint = AppStrings.addProductQuantityHint,
  });

  final TextEditingController quantityController;
  final T value;
  final List<T> items;
  final String Function(T value) labelOf;
  final ValueChanged<T> onUomChanged;
  final bool onDark;
  final String quantityHint;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: AppTextField(
            controller: quantityController,
            hint: quantityHint,
            onDark: onDark,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          flex: 3,
          child: AppSelect<T>(
            value: value,
            items: items,
            onDark: onDark,
            labelOf: labelOf,
            onChanged: onUomChanged,
          ),
        ),
      ],
    );
  }
}
