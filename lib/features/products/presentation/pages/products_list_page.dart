import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_app_bar.dart';
import 'package:home_market_tracker/core/widgets/app_bottom_sheet.dart';
import 'package:home_market_tracker/core/widgets/app_empty.dart';
import 'package:home_market_tracker/core/widgets/app_error.dart';
import 'package:home_market_tracker/core/widgets/app_fab.dart';
import 'package:home_market_tracker/core/widgets/app_list.dart';
import 'package:home_market_tracker/core/widgets/app_loading.dart';
import 'package:home_market_tracker/core/widgets/app_scaffold.dart';
import 'package:home_market_tracker/core/widgets/app_search_field.dart';
import 'package:home_market_tracker/features/products/domain/entities/product_with_last_purchase.dart';
import 'package:home_market_tracker/features/products/presentation/bloc/products_list_cubit.dart';
import 'package:home_market_tracker/features/products/presentation/bloc/products_list_state.dart';
import 'package:home_market_tracker/features/products/presentation/widgets/create_product_sheet.dart';
import 'package:home_market_tracker/features/products/presentation/widgets/product_list_item.dart';

class ProductsListPage extends StatelessWidget {
  const ProductsListPage({
    super.key,
    required this.onProductSelected,
  });

  final ValueChanged<String> onProductSelected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsListCubit, ProductsListState>(
      builder: (context, state) {
        final cubit = context.read<ProductsListCubit>();
        return AppScaffold(
          appBar: AppAppBar(
            title: AppStrings.productsTitle,
            showBack: false,
            onSearch: cubit.searchToggled,
          ),
          floatingActionButton: AppFab(
            onPressed: () => _openCreateSheet(context, cubit),
          ),
          body: Column(
            children: [
              if (state.searchVisible) ...[
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: AppSearchField(onChanged: cubit.queryChanged),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              Expanded(child: _body(state, cubit, onProductSelected)),
            ],
          ),
        );
      },
    );
  }

  void _openCreateSheet(BuildContext context, ProductsListCubit cubit) {
    cubit.createFormOpened();
    AppBottomSheet.show<void>(
      context: context,
      child: BlocProvider.value(
        value: cubit,
        child: const CreateProductSheet(),
      ),
    );
  }

  Widget _body(
    ProductsListState state,
    ProductsListCubit cubit,
    ValueChanged<String> onProductSelected,
  ) {
    return switch (state.status) {
      ProductsListStatus.initial || ProductsListStatus.loading =>
        const AppLoading(),
      ProductsListStatus.error => AppError(
          message: state.failure?.message ?? AppStrings.errorLoadProducts,
          onRetry: cubit.retried,
        ),
      ProductsListStatus.empty => AppEmpty(message: state.emptyMessage),
      ProductsListStatus.data => _list(
          state.products,
          state.emptyMessage,
          onProductSelected,
        ),
    };
  }

  Widget _list(
    List<ProductWithLastPurchase> items,
    String emptyMessage,
    ValueChanged<String> onProductSelected,
  ) {
    if (items.isEmpty) {
      return AppEmpty(message: emptyMessage);
    }
    return AppList<ProductWithLastPurchase>(
      items: items,
      itemBuilder: (context, item, index) => ProductListItem(
        key: ValueKey(item.product.id),
        item: item,
        onTap: () => onProductSelected(item.product.id),
      ),
    );
  }
}
