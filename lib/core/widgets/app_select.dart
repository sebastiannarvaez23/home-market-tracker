import 'package:flutter/material.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_icons.dart';
import 'package:home_market_tracker/core/theme/app_radii.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';

class AppSelect<T> extends StatelessWidget {
  const AppSelect({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.labelOf,
    this.onDark = false,
    this.selectedLabelOf,
  });

  final T value;
  final List<T> items;
  final ValueChanged<T> onChanged;
  final String Function(T value) labelOf;
  final String Function(T value)? selectedLabelOf;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final fill = onDark ? const Color(0x40FFFFFF) : AppColors.purpleSoft;
    final textColor = onDark ? AppColors.iconOnGradient : AppColors.textPrimary;
    final uniqueItems = <T>[];
    for (final item in items) {
      if (!uniqueItems.contains(item)) uniqueItems.add(item);
    }
    if (uniqueItems.isEmpty) {
      return const SizedBox.shrink();
    }
    final selected =
        uniqueItems.contains(value) ? value : uniqueItems.first;
    final selectedLabel = selectedLabelOf ?? labelOf;
    return Container(
      height: 52,
      padding: const EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.md),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: selected,
          isExpanded: true,
          isDense: true,
          dropdownColor: onDark ? const Color(0xFF5B3BB5) : AppColors.surface,
          icon: Icon(AppIcons.expandMore, color: textColor, size: 22),
          selectedItemBuilder: (context) => [
            for (final item in uniqueItems)
              Align(
                alignment: Alignment.centerLeft,
                child: AppText(
                  selectedLabel(item),
                  color: textColor,
                  maxLines: 1,
                ),
              ),
          ],
          items: [
            for (final item in uniqueItems)
              DropdownMenuItem<T>(
                value: item,
                child: AppText(labelOf(item), color: textColor, maxLines: 1),
              ),
          ],
          onChanged: (next) {
            if (next != null) onChanged(next);
          },
        ),
      ),
    );
  }
}
