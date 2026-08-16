import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_bottom_sheet.dart';
import 'package:home_market_tracker/core/widgets/app_button.dart';
import 'package:home_market_tracker/core/widgets/app_gradient_icon.dart';
import 'package:home_market_tracker/core/widgets/app_text_field.dart';
import 'package:home_market_tracker/features/products/domain/entities/product.dart';
import 'package:home_market_tracker/features/products/presentation/widgets/product_uom_ladder_editor.dart';
import 'package:home_market_tracker/features/products/presentation/bloc/product_detail_cubit.dart';
import 'package:home_market_tracker/features/products/presentation/bloc/product_detail_state.dart';

class EditProductSheet extends StatefulWidget {
  const EditProductSheet({super.key, required this.product});

  final Product product;

  @override
  State<EditProductSheet> createState() => _EditProductSheetState();
}

class _EditProductSheetState extends State<EditProductSheet> {
  late final TextEditingController _name;
  late final TextEditingController _notes;
  final _ladderKey = GlobalKey<ProductUomLadderEditorState>();

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.product.name);
    _notes = TextEditingController(text: widget.product.notes ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final cubit = context.read<ProductDetailCubit>();
    final saved = await cubit.saveProduct(
      name: _name.text,
      notes: _notes.text,
      uomLadder: _ladderKey.currentState?.draft,
    );
    if (saved && mounted) {
      AppBottomSheet.close(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailCubit, ProductDetailState>(
      builder: (context, state) {
        return AppSheetScaffold(
          glyph: AppGradientIcon.product(
            seed: widget.product.id.hashCode,
            size: 72,
          ),
          title: AppStrings.editProductTitle,
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: _name,
                hint: AppStrings.createProductHint,
                onDark: true,
                autofocus: true,
                errorText: state.saveFailure?.message,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _notes,
                hint: AppStrings.productNotesHint,
                onDark: true,
              ),
              const SizedBox(height: AppSpacing.lg),
              ProductUomLadderEditor(
                key: _ladderKey,
                initial: widget.product.uomLadder,
              ),
            ],
          ),
          actions: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: AppStrings.cancel,
                  variant: AppButtonVariant.ghost,
                  onPressed: state.isSaving
                      ? null
                      : () => AppBottomSheet.close(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: AppStrings.save,
                  onPressed: state.isSaving ? null : _submit,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
