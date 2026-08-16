import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/theme/app_icons.dart';
import 'package:home_market_tracker/core/widgets/app_app_bar.dart';
import 'package:home_market_tracker/core/widgets/app_bottom_sheet.dart';
import 'package:home_market_tracker/core/widgets/app_button.dart';
import 'package:home_market_tracker/core/widgets/app_empty.dart';
import 'package:home_market_tracker/core/widgets/app_error.dart';
import 'package:home_market_tracker/core/widgets/app_list.dart';
import 'package:home_market_tracker/core/widgets/app_loading.dart';
import 'package:home_market_tracker/core/widgets/app_scaffold.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';
import 'package:home_market_tracker/features/products/domain/entities/product.dart';
import 'package:home_market_tracker/features/products/domain/entities/product_purchase_history_entry.dart';
import 'package:home_market_tracker/features/products/presentation/bloc/product_detail_cubit.dart';
import 'package:home_market_tracker/features/products/presentation/bloc/product_detail_state.dart';
import 'package:home_market_tracker/features/products/presentation/widgets/edit_product_sheet.dart';
import 'package:home_market_tracker/features/products/presentation/widgets/product_detail_header.dart';
import 'package:home_market_tracker/features/products/presentation/widgets/product_purchase_history_item.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailCubit, ProductDetailState>(
      builder: (context, state) {
        final cubit = context.read<ProductDetailCubit>();
        final product = state.product;
        return AppScaffold(
          appBar: AppAppBar(
            title: product?.name ?? AppStrings.productDetailTitle,
            onAction: product == null ? null : () => _openEdit(context, cubit, product),
          ),
          body: _body(state, cubit),
        );
      },
    );
  }

  void _openEdit(
    BuildContext context,
    ProductDetailCubit cubit,
    Product product,
  ) {
    cubit.editFormOpened();
    AppBottomSheet.show<void>(
      context: context,
      child: BlocProvider.value(
        value: cubit,
        child: EditProductSheet(product: product),
      ),
    );
  }

  Widget _body(ProductDetailState state, ProductDetailCubit cubit) {
    return switch (state.status) {
      ProductDetailStatus.initial || ProductDetailStatus.loading =>
        const AppLoading(),
      ProductDetailStatus.error => AppError(
          message: state.failure?.message ?? AppStrings.errorLoadProduct,
          onRetry: cubit.retried,
        ),
      ProductDetailStatus.data => _content(state.product!, state.history, cubit),
    };
  }

  Widget _content(
    Product product,
    List<ProductPurchaseHistoryEntry> history,
    ProductDetailCubit cubit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.sm,
            AppSpacing.xl,
            AppSpacing.md,
          ),
          child: ProductDetailHeader(product: product),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.md,
          ),
          child: AppButton(
            label: product.isSuggested
                ? AppStrings.unsuggestForNextShopping
                : AppStrings.suggestForNextShopping,
            icon: AppIcons.fire,
            variant: product.isSuggested
                ? AppButtonVariant.secondary
                : AppButtonVariant.primary,
            onPressed: cubit.suggestionToggled,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: const AppText(
            AppStrings.purchaseHistoryTitle,
            variant: AppTextVariant.title,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: history.isEmpty
              ? const AppEmpty(message: AppStrings.emptyPurchaseHistory)
              : AppList<ProductPurchaseHistoryEntry>(
                  items: history,
                  itemBuilder: (context, entry, index) =>
                      ProductPurchaseHistoryItem(entry: entry),
                ),
        ),
      ],
    );
  }
}
