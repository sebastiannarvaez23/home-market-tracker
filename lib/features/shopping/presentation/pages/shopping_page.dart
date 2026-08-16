import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/theme/app_icons.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_app_bar.dart';
import 'package:home_market_tracker/core/widgets/app_bottom_sheet.dart';
import 'package:home_market_tracker/core/widgets/app_button.dart';
import 'package:home_market_tracker/core/widgets/app_confirm_dialog.dart';
import 'package:home_market_tracker/core/widgets/app_empty.dart';
import 'package:home_market_tracker/core/widgets/app_error.dart';
import 'package:home_market_tracker/core/widgets/app_fab.dart';
import 'package:home_market_tracker/core/widgets/app_list.dart';
import 'package:home_market_tracker/core/widgets/app_loading.dart';
import 'package:home_market_tracker/core/widgets/app_navigator.dart';
import 'package:home_market_tracker/core/widgets/app_playful_backdrop.dart';
import 'package:home_market_tracker/core/widgets/app_scaffold.dart';
import 'package:home_market_tracker/core/widgets/app_search_field.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';
import 'package:home_market_tracker/core/widgets/app_total_badge.dart';
import 'package:home_market_tracker/core/widgets/app_urgency_divider.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_catalog_refs.dart';
import 'package:home_market_tracker/features/shopping/presentation/bloc/shopping_session_cubit.dart';
import 'package:home_market_tracker/features/shopping/presentation/bloc/shopping_session_state.dart';
import 'package:home_market_tracker/features/shopping/presentation/widgets/add_shopping_item_sheet.dart';
import 'package:home_market_tracker/features/shopping/presentation/widgets/shopping_catalog_item.dart';

class ShoppingPage extends StatelessWidget {
  const ShoppingPage({
    super.key,
    required this.onCreateProduct,
    required this.onEditProduct,
  });

  final Future<void> Function(BuildContext context) onCreateProduct;
  final Future<void> Function(BuildContext context, String productId)
      onEditProduct;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShoppingSessionCubit, ShoppingSessionState>(
      builder: (context, state) {
        final cubit = context.read<ShoppingSessionCubit>();
        final session = state.session;
        return AppScaffold(
          appBar: AppAppBar(
            title: session?.marketNameSnapshot ?? AppStrings.shoppingTitle,
            trailing: AppTotalBadge(total: state.total),
          ),
          body: AppPlayfulBackdrop(
            child: Column(
              children: [
                if (state.status == ShoppingViewStatus.data ||
                    state.status == ShoppingViewStatus.empty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.sm,
                      AppSpacing.xl,
                      AppSpacing.sm,
                    ),
                    child: AppSearchField(onChanged: cubit.queryChanged),
                  ),
                ],
                Expanded(child: _body(context, state, cubit)),
              ],
            ),
          ),
          floatingActionButton: session == null
              ? null
              : AppFab(onPressed: () => _createProduct(context, cubit)),
          bottomNavigationBar: session == null
              ? null
              : _ShoppingFooter(
                  canComplete: session.items.isNotEmpty,
                  isCompleting: state.isCompleting,
                  actionMessage: state.actionFailure?.message,
                  onComplete: () => _complete(context, cubit),
                  onDiscard: () => _discard(context, cubit),
                ),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    ShoppingSessionState state,
    ShoppingSessionCubit cubit,
  ) {
    return switch (state.status) {
      ShoppingViewStatus.initial || ShoppingViewStatus.loading =>
        const AppLoading(),
      ShoppingViewStatus.error => AppError(
          message: state.failure?.message ?? AppStrings.errorLoadShopping,
          onRetry: cubit.retried,
        ),
      ShoppingViewStatus.empty => AppEmpty(message: state.emptyMessage),
      ShoppingViewStatus.data => AppList<ShoppingProductRef>(
          items: state.products,
          separatorBuilder: (context, index) {
            if (state.urgencyDividerAfterIndex == index) {
              return const AppUrgencyDivider();
            }
            return const SizedBox(height: AppSpacing.xs);
          },
          itemBuilder: (context, product, index) {
            final tile = ShoppingCatalogItem(
              product: product,
              item: state.itemFor(product.id),
              onAdd: () => _openAdd(context, cubit, product),
            );
            if (index == 0 && product.isSuggested) {
              return Column(
                children: [
                  const AppUrgencyDivider(label: AppStrings.suggestedProducts),
                  tile,
                ],
              );
            }
            return tile;
          },
        ),
    };
  }

  void _openAdd(
    BuildContext context,
    ShoppingSessionCubit cubit,
    ShoppingProductRef product,
  ) {
    cubit.addFormOpened();
    AppBottomSheet.show<void>(
      context: context,
      child: BlocProvider.value(
        value: cubit,
        child: AddShoppingItemSheet(
          product: product,
          existing: cubit.state.itemFor(product.id),
          onEditProduct: (productId) => _editProduct(context, cubit, productId),
        ),
      ),
    );
  }

  Future<void> _createProduct(
    BuildContext context,
    ShoppingSessionCubit cubit,
  ) async {
    await onCreateProduct(context);
    if (context.mounted) {
      await cubit.refreshed();
    }
  }

  Future<void> _editProduct(
    BuildContext context,
    ShoppingSessionCubit cubit,
    String productId,
  ) async {
    await onEditProduct(context, productId);
    if (context.mounted) {
      await cubit.refreshed();
    }
  }

  Future<void> _complete(
    BuildContext context,
    ShoppingSessionCubit cubit,
  ) async {
    final done = await cubit.completed();
    if (done && context.mounted) {
      AppNavigator.pop(context);
    }
  }

  Future<void> _discard(
    BuildContext context,
    ShoppingSessionCubit cubit,
  ) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: AppStrings.discardShoppingConfirm,
      confirmLabel: AppStrings.discardShopping,
    );
    if (!confirmed || !context.mounted) return;
    final discarded = await cubit.discarded();
    if (discarded && context.mounted) {
      AppNavigator.pop(context);
    }
  }
}

class _ShoppingFooter extends StatelessWidget {
  const _ShoppingFooter({
    required this.canComplete,
    required this.isCompleting,
    required this.onComplete,
    required this.onDiscard,
    this.actionMessage,
  });

  final bool canComplete;
  final bool isCompleting;
  final String? actionMessage;
  final VoidCallback onComplete;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (actionMessage != null) ...[
            AppText(
              actionMessage!,
              variant: AppTextVariant.caption,
              align: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (canComplete) ...[
            AppButton(
              label: AppStrings.completeShopping,
              icon: AppIcons.check,
              onPressed: isCompleting ? null : onComplete,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          AppButton(
            label: AppStrings.discardShopping,
            variant: AppButtonVariant.secondary,
            onPressed: isCompleting ? null : onDiscard,
          ),
        ],
      ),
    );
  }
}
