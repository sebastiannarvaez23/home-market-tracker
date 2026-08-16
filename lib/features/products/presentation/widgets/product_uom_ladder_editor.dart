import 'package:flutter/widgets.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_icons.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/value/unit_of_measure.dart';
import 'package:home_market_tracker/core/value/uom_ladder.dart';
import 'package:home_market_tracker/core/widgets/app_button.dart';
import 'package:home_market_tracker/core/widgets/app_icon_button.dart';
import 'package:home_market_tracker/core/widgets/app_select.dart';
import 'package:home_market_tracker/core/widgets/app_tag.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';
import 'package:home_market_tracker/core/widgets/app_text_field.dart';

class ProductUomLadderEditor extends StatefulWidget {
  const ProductUomLadderEditor({
    super.key,
    this.initial = UomLadder.unitOnly,
    this.onDark = true,
  });

  final UomLadder initial;
  final bool onDark;

  @override
  State<ProductUomLadderEditor> createState() => ProductUomLadderEditorState();
}

class ProductUomLadderEditorState extends State<ProductUomLadderEditor> {
  late UnitOfMeasure _base;
  late List<_StepForm> _steps;

  @override
  void initState() {
    super.initState();
    _base = widget.initial.base;
    _steps = [
      for (final step in widget.initial.steps)
        _StepForm(
          uom: step.uom,
          factor: TextEditingController(text: _format(step.factor.value)),
        ),
    ];
  }

  @override
  void dispose() {
    for (final step in _steps) {
      step.factor.dispose();
    }
    super.dispose();
  }

  UomLadderDraft get draft {
    return UomLadderDraft(
      base: _base,
      steps: [
        for (final step in _steps)
          UomStepDraft(
            uom: step.uom,
            factor: num.tryParse(step.factor.text.replaceAll(',', '.')) ?? 0,
          ),
      ],
    );
  }

  String _format(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toString();
  }

  String _unitLabel(UnitOfMeasure unit) => '${unit.code}  ·  ${unit.label}';

  List<UnitOfMeasure> get _stepUomOptions {
    return [
      for (final unit in UnitOfMeasure.catalog)
        if (unit != _base) unit,
    ];
  }

  UnitOfMeasure get _preferredNewStepUom {
    const pack = UnitOfMeasure.pack;
    if (_stepUomOptions.contains(pack)) return pack;
    return _stepUomOptions.first;
  }

  Color get _labelColor {
    return widget.onDark ? AppColors.iconOnGradient : AppColors.textPrimary;
  }

  Color get _hintColor {
    return widget.onDark
        ? AppColors.iconOnGradient.withValues(alpha: 0.72)
        : AppColors.textMuted;
  }

  void _setBase(UnitOfMeasure base) {
    setState(() {
      _base = base;
      final removed = _steps.where((step) => step.uom == base).toList();
      for (final step in removed) {
        step.factor.dispose();
      }
      _steps.removeWhere((step) => step.uom == base);
    });
  }

  void _addStep() {
    final options = _stepUomOptions;
    if (options.isEmpty) return;
    setState(() {
      _steps.add(
        _StepForm(
          uom: _preferredNewStepUom,
          factor: TextEditingController(text: '1'),
        ),
      );
    });
  }

  void _removeStep(int index) {
    setState(() {
      _steps[index].factor.dispose();
      _steps.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          AppStrings.uomLadderTitle,
          variant: AppTextVariant.title,
          color: _labelColor,
        ),
        const SizedBox(height: 6),
        AppText(
          AppStrings.uomLadderHint,
          variant: AppTextVariant.subtitle,
          color: _hintColor,
          maxLines: 2,
        ),
        const SizedBox(height: AppSpacing.md),
        AppText(
          AppStrings.minUomLabel,
          variant: AppTextVariant.caption,
          color: _hintColor,
        ),
        const SizedBox(height: 8),
        AppSelect<UnitOfMeasure>(
          value: _base,
          items: UnitOfMeasure.catalog,
          onDark: widget.onDark,
          labelOf: _unitLabel,
          selectedLabelOf: (unit) => unit.code,
          onChanged: _setBase,
        ),
        for (var i = 0; i < _steps.length; i++) ...[
          const SizedBox(height: AppSpacing.sm),
          _stepRow(i),
        ],
        if (_stepUomOptions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: AppStrings.addUomStep,
            variant: AppButtonVariant.outline,
            icon: AppIcons.add,
            onPressed: _addStep,
          ),
        ],
      ],
    );
  }

  Widget _stepRow(int index) {
    final step = _steps[index];
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: AppSelect<UnitOfMeasure>(
            value: step.uom,
            items: _stepUomOptions,
            onDark: widget.onDark,
            labelOf: _unitLabel,
            selectedLabelOf: (unit) => unit.code,
            onChanged: (uom) => setState(() => step.uom = uom),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: AppText(
            AppStrings.uomContainsLabel,
            variant: AppTextVariant.caption,
            color: _hintColor,
          ),
        ),
        Expanded(
          flex: 2,
          child: AppTextField(
            controller: step.factor,
            hint: AppStrings.uomFactorHint,
            onDark: widget.onDark,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        const SizedBox(width: 8),
        AppTag(
          label: _base.code,
          backgroundColor: const Color(0x40FFFFFF),
          foregroundColor: AppColors.iconOnGradient,
        ),
        const SizedBox(width: 4),
        AppIconButton(
          icon: AppIcons.remove,
          size: 36,
          backgroundColor: const Color(0x33FFFFFF),
          iconColor: AppColors.iconOnGradient,
          onPressed: () => _removeStep(index),
        ),
      ],
    );
  }
}

class _StepForm {
  _StepForm({required this.uom, required this.factor});

  UnitOfMeasure uom;
  final TextEditingController factor;
}
