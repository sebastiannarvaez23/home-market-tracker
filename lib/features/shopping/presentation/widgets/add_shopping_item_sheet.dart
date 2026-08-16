import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/formatters/money_input_formatter.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_icons.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/value/uom_ladder.dart';
import 'package:home_market_tracker/core/widgets/app_bottom_sheet.dart';
import 'package:home_market_tracker/core/widgets/app_button.dart';
import 'package:home_market_tracker/core/widgets/app_product_photo.dart';
import 'package:home_market_tracker/core/widgets/app_icon_button.dart';
import 'package:home_market_tracker/core/widgets/app_money_field.dart';
import 'package:home_market_tracker/core/widgets/app_quantity_uom_field.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_catalog_refs.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_item.dart';
import 'package:home_market_tracker/features/shopping/presentation/bloc/shopping_session_cubit.dart';
import 'package:home_market_tracker/features/shopping/presentation/bloc/shopping_session_state.dart';

class AddShoppingItemSheet extends StatefulWidget {
  const AddShoppingItemSheet({
    super.key,
    required this.product,
    this.existing,
    this.onEditProduct,
  });

  final ShoppingProductRef product;
  final ShoppingItem? existing;
  final Future<void> Function(String productId)? onEditProduct;

  @override
  State<AddShoppingItemSheet> createState() => _AddShoppingItemSheetState();
}

class _AddShoppingItemSheetState extends State<AddShoppingItemSheet> {
  late final TextEditingController _price;
  late final TextEditingController _quantity;
  late UomLadderStep _packaging;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final pesos = existing == null ? null : existing.unitPrice.cents ~/ 100;
    _price = TextEditingController(
      text: pesos == null || pesos == 0
          ? ''
          : MoneyInputFormatter.formatPesos(pesos),
    );
    _quantity = TextEditingController(
      text: existing == null ? '1' : existing.quantity.compact,
    );
    _packaging = _packagingFor(widget.product, existing);
  }

  UomLadderStep _packagingFor(
    ShoppingProductRef product,
    ShoppingItem? existing,
  ) {
    final selectable = product.uomLadder.selectable;
    if (existing != null) {
      for (final step in selectable) {
        if (step.uom == existing.uom && step.factor == existing.uomFactor) {
          return step;
        }
      }
    }
    return selectable.first;
  }

  void _syncPackaging(ShoppingProductRef product) {
    final selectable = product.uomLadder.selectable;
    if (selectable.contains(_packaging) || selectable.isEmpty) return;
    _packaging = selectable.first;
  }

  @override
  void dispose() {
    _price.dispose();
    _quantity.dispose();
    super.dispose();
  }

  Future<void> _submit(ShoppingProductRef product) async {
    final cubit = context.read<ShoppingSessionCubit>();
    final added = await cubit.addItem(
      productId: product.id,
      unitPrice: _price.text,
      quantity: _quantity.text,
      uom: _packaging.uom,
      uomFactor: _packaging.factor.value,
    );
    if (added && mounted) {
      AppBottomSheet.close(context);
    }
  }

  Future<void> _edit(String productId) async {
    await widget.onEditProduct?.call(productId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShoppingSessionCubit, ShoppingSessionState>(
      builder: (context, state) {
        final product = state.productById(widget.product.id) ?? widget.product;
        _syncPackaging(product);
        final existing = state.itemFor(product.id) ?? widget.existing;
        final ladder = product.uomLadder;
        return AppSheetScaffold(
          glyph: AppProductPhoto(
            path: product.photoPath,
            size: 72,
          ),
          title: product.name,
          trailing: widget.onEditProduct == null
              ? null
              : AppIconButton(
                  icon: AppIcons.edit,
                  size: 40,
                  backgroundColor: const Color(0x33FFFFFF),
                  iconColor: AppColors.iconOnGradient,
                  onPressed: () => _edit(product.id),
                ),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppMoneyField(
                controller: _price,
                onDark: true,
                autofocus: true,
                errorText: state.addFailure?.message,
                onSubmitted: (_) => _submit(product),
              ),
              const SizedBox(height: AppSpacing.md),
              AppQuantityUomField<UomLadderStep>(
                quantityController: _quantity,
                value: _packaging,
                items: ladder.selectable,
                onDark: true,
                labelOf: ladder.labelOf,
                onUomChanged: (step) => setState(() => _packaging = step),
              ),
            ],
          ),
          actions: AppButton(
            label: existing == null
                ? AppStrings.addToShopping
                : AppStrings.updateShoppingItem,
            onPressed: state.isAdding ? null : () => _submit(product),
          ),
        );
      },
    );
  }
}
