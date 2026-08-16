import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/value/uom_ladder.dart';
import 'package:home_market_tracker/features/products/domain/entities/product.dart';
import 'package:home_market_tracker/features/products/domain/entities/product_with_last_purchase.dart';
import 'package:home_market_tracker/features/products/domain/usecases/create_product.dart';
import 'package:home_market_tracker/features/products/domain/usecases/list_products_with_last_purchase.dart';
import 'package:home_market_tracker/features/products/presentation/bloc/products_list_state.dart';

class ProductsListCubit extends Cubit<ProductsListState> {
  ProductsListCubit(
    this._listProducts,
    this._createProduct,
  ) : super(const ProductsListState());

  final ListProductsWithLastPurchase _listProducts;
  final CreateProduct _createProduct;

  Future<void> started() => _load();

  Future<void> retried() => _load();

  Future<void> refreshed() => _load(silent: true);

  void createFormOpened() {
    emit(state.copyWith(clearCreateFailure: true, isCreating: false));
  }

  void searchToggled() {
    final show = !state.searchVisible;
    if (!show && state.query.isNotEmpty) {
      emit(
        state.copyWith(
          searchVisible: false,
          query: '',
        ),
      );
      _load();
      return;
    }
    emit(state.copyWith(searchVisible: show));
  }

  Future<void> queryChanged(String query) async {
    emit(state.copyWith(query: query));
    await _load();
  }

  Future<bool> createProduct({
    required String name,
    required String photoSourcePath,
    UomLadderDraft? uomLadder,
  }) async {
    emit(state.copyWith(isCreating: true, clearCreateFailure: true));
    final result = await _createProduct(
      CreateProductParams(
        name: name,
        photoSourcePath: photoSourcePath,
        uomLadder: uomLadder ?? const UomLadderDraft(),
      ),
    );
    if (isClosed) return false;

    switch (result) {
      case FailureResult<Product>(:final failure):
        emit(state.copyWith(isCreating: false, createFailure: failure));
        return false;
      case Success<Product>():
        emit(state.copyWith(isCreating: false, clearCreateFailure: true));
        await _load(silent: true);
        return true;
    }
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(status: ProductsListStatus.loading, clearFailure: true));
    }
    final result = await _listProducts(
      ListProductsWithLastPurchaseParams(
        nameQuery: state.query.isEmpty ? null : state.query,
      ),
    );
    if (isClosed) return;

    switch (result) {
      case Success<List<ProductWithLastPurchase>>(:final value):
        emit(
          state.copyWith(
            status: value.isEmpty
                ? ProductsListStatus.empty
                : ProductsListStatus.data,
            products: value,
          ),
        );
      case FailureResult(:final failure):
        emit(
          state.copyWith(
            status: ProductsListStatus.error,
            failure: failure,
          ),
        );
    }
  }
}
