import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_market_tracker/app/dependency_injection.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/theme/app_icons.dart';
import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/core/widgets/app_bottom_sheet.dart';
import 'package:home_market_tracker/core/widgets/app_nav_bar.dart';
import 'package:home_market_tracker/core/widgets/app_navigator.dart';
import 'package:home_market_tracker/core/widgets/app_scaffold.dart';
import 'package:home_market_tracker/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:home_market_tracker/features/dashboard/presentation/bloc/market_suggestions_cubit.dart';
import 'package:home_market_tracker/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:home_market_tracker/features/dashboard/presentation/pages/market_suggestions_page.dart';
import 'package:home_market_tracker/features/history/presentation/bloc/history_detail_cubit.dart';
import 'package:home_market_tracker/features/history/presentation/bloc/history_list_cubit.dart';
import 'package:home_market_tracker/features/history/presentation/pages/history_detail_page.dart';
import 'package:home_market_tracker/features/history/presentation/pages/history_list_page.dart';
import 'package:home_market_tracker/features/markets/presentation/bloc/pick_market_cubit.dart';
import 'package:home_market_tracker/features/markets/presentation/widgets/pick_market_sheet.dart';
import 'package:home_market_tracker/features/products/presentation/bloc/product_detail_cubit.dart';
import 'package:home_market_tracker/features/products/presentation/bloc/products_list_cubit.dart';
import 'package:home_market_tracker/features/products/presentation/pages/product_detail_page.dart';
import 'package:home_market_tracker/features/products/presentation/pages/products_list_page.dart';
import 'package:home_market_tracker/features/products/presentation/widgets/create_product_sheet.dart';
import 'package:home_market_tracker/features/products/presentation/widgets/edit_product_sheet.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_session.dart';
import 'package:home_market_tracker/features/shopping/domain/usecases/get_in_progress_shopping.dart';
import 'package:home_market_tracker/features/shopping/domain/usecases/start_shopping.dart';
import 'package:home_market_tracker/features/shopping/presentation/bloc/shopping_session_cubit.dart';
import 'package:home_market_tracker/features/shopping/presentation/pages/shopping_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  var _index = 0;

  static const _navItems = [
    AppNavItem(icon: AppIcons.home, label: AppStrings.navHome),
    AppNavItem(icon: AppIcons.grocery, label: AppStrings.navProducts),
    AppNavItem(icon: AppIcons.history, label: AppStrings.navHistory),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<DashboardCubit>()..started()),
        BlocProvider(create: (_) => sl<ProductsListCubit>()..started()),
        BlocProvider(create: (_) => sl<HistoryListCubit>()..started()),
      ],
      child: Builder(
        builder: (context) {
          return AppScaffold(
            body: IndexedStack(
              index: _index,
              children: [
                DashboardPage(
                  onOpenProducts: () => _select(context, 1),
                  onOpenHistory: () => _select(context, 2),
                  onOpenSuggestions: () => _openMarketSuggestions(context),
                  onStartShopping: () => _startShopping(context),
                ),
                ProductsListPage(
                  onProductSelected: (productId) =>
                      _openProductDetail(context, productId),
                ),
                HistoryListPage(
                  onEntrySelected: (sessionId) =>
                      _openHistoryDetail(context, sessionId),
                ),
              ],
            ),
            bottomNavigationBar: AppNavBar(
              items: _navItems,
              currentIndex: _index,
              onChanged: (index) => _select(context, index),
            ),
          );
        },
      ),
    );
  }

  void _select(BuildContext context, int index) {
    setState(() => _index = index);
    if (index == 0) {
      context.read<DashboardCubit>().refreshed();
    }
    if (index == 2) {
      context.read<HistoryListCubit>().refreshed();
    }
  }

  Future<void> _openMarketSuggestions(BuildContext context) async {
    await AppNavigator.push<void>(
      context,
      BlocProvider(
        create: (_) => sl<MarketSuggestionsCubit>()..started(),
        child: const MarketSuggestionsPage(),
      ),
    );
  }

  Future<void> _openProductDetail(
    BuildContext context,
    String productId,
  ) async {
    final products = context.read<ProductsListCubit>();
    final dashboard = context.read<DashboardCubit>();
    await AppNavigator.push<void>(
      context,
      BlocProvider(
        create: (_) => sl<ProductDetailCubit>(param1: productId)..started(),
        child: const ProductDetailPage(),
      ),
    );
    await products.refreshed();
    await dashboard.refreshed();
  }

  Future<void> _openHistoryDetail(
    BuildContext context,
    String sessionId,
  ) async {
    final history = context.read<HistoryListCubit>();
    final dashboard = context.read<DashboardCubit>();
    await AppNavigator.push<void>(
      context,
      BlocProvider(
        create: (_) => sl<HistoryDetailCubit>(param1: sessionId)..started(),
        child: const HistoryDetailPage(),
      ),
    );
    await history.refreshed();
    await dashboard.refreshed();
  }

  Future<void> _startShopping(BuildContext context) async {
    final current = await sl<GetInProgressShopping>()(const NoParams());
    if (!context.mounted) return;
    switch (current) {
      case Success<ShoppingSession?>(:final value) when value != null:
        await _openShopping(context);
      case Success<ShoppingSession?>():
        final marketId = await _pickMarket(context);
        if (marketId == null || !context.mounted) return;
        final started = await sl<StartShopping>()(
          StartShoppingParams(marketId: marketId),
        );
        if (!context.mounted) return;
        switch (started) {
          case Success<ShoppingSession>():
            await _openShopping(context);
          case FailureResult<ShoppingSession>(:final failure)
              when failure.code == FailureCode.conflict:
            await _openShopping(context);
          case FailureResult<ShoppingSession>():
            break;
        }
      case FailureResult<ShoppingSession?>():
        break;
    }
  }

  Future<String?> _pickMarket(BuildContext context) {
    return AppBottomSheet.show<String>(
      context: context,
      child: BlocProvider(
        create: (_) => sl<PickMarketCubit>()..started(),
        child: const PickMarketSheet(),
      ),
    );
  }

  Future<void> _openShopping(BuildContext context) async {
    final dashboard = context.read<DashboardCubit>();
    final history = context.read<HistoryListCubit>();
    final products = context.read<ProductsListCubit>();
    await AppNavigator.push<void>(
      context,
      BlocProvider(
        create: (_) => sl<ShoppingSessionCubit>()..started(),
        child: ShoppingPage(
          onCreateProduct: (sheetContext) =>
              _createProductFromShopping(sheetContext, products),
          onEditProduct: (sheetContext, productId) =>
              _editProductFromShopping(sheetContext, productId, products),
        ),
      ),
    );
    await products.refreshed();
    await dashboard.refreshed();
    await history.refreshed();
  }

  Future<void> _createProductFromShopping(
    BuildContext sheetContext,
    ProductsListCubit products,
  ) async {
    products.createFormOpened();
    await AppBottomSheet.show<void>(
      context: sheetContext,
      child: BlocProvider.value(
        value: products,
        child: const CreateProductSheet(),
      ),
    );
    await products.refreshed();
  }

  Future<void> _editProductFromShopping(
    BuildContext sheetContext,
    String productId,
    ProductsListCubit products,
  ) async {
    final cubit = sl<ProductDetailCubit>(param1: productId);
    await cubit.started();
    final product = cubit.state.product;
    if (product == null) {
      await cubit.close();
      return;
    }
    cubit.editFormOpened();
    if (!sheetContext.mounted) {
      await cubit.close();
      return;
    }
    await AppBottomSheet.show<void>(
      context: sheetContext,
      child: BlocProvider.value(
        value: cubit,
        child: EditProductSheet(product: product),
      ),
    );
    await cubit.close();
    await products.refreshed();
  }
}
