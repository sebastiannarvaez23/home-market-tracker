import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/value/uom_ladder.dart';
import 'package:home_market_tracker/features/products/domain/entities/product.dart';
import 'package:home_market_tracker/features/products/domain/entities/product_purchase_history_entry.dart';
import 'package:home_market_tracker/features/products/domain/usecases/get_product.dart';
import 'package:home_market_tracker/features/products/domain/usecases/list_product_purchase_history.dart';
import 'package:home_market_tracker/features/products/domain/usecases/suggest_product.dart';
import 'package:home_market_tracker/features/products/domain/usecases/unsuggest_product.dart';
import 'package:home_market_tracker/features/products/domain/usecases/update_product.dart';
import 'package:home_market_tracker/features/products/presentation/bloc/product_detail_state.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit(
    this.productId,
    this._getProduct,
    this._updateProduct,
    this._listHistory,
    this._suggestProduct,
    this._unsuggestProduct,
  ) : super(const ProductDetailState());

  final String productId;
  final GetProduct _getProduct;
  final UpdateProduct _updateProduct;
  final ListProductPurchaseHistory _listHistory;
  final SuggestProduct _suggestProduct;
  final UnsuggestProduct _unsuggestProduct;

  Future<void> started() => _load();

  Future<void> retried() => _load();

  void editFormOpened() {
    emit(state.copyWith(clearSaveFailure: true, isSaving: false));
  }

  Future<bool> saveProduct({
    required String name,
    String? notes,
    UomLadderDraft? uomLadder,
  }) async {
    emit(state.copyWith(isSaving: true, clearSaveFailure: true));
    final result = await _updateProduct(
      UpdateProductParams(
        id: productId,
        name: name,
        notes: notes,
        uomLadder: uomLadder,
      ),
    );
    if (isClosed) return false;

    switch (result) {
      case FailureResult<Product>(:final failure):
        emit(state.copyWith(isSaving: false, saveFailure: failure));
        return false;
      case Success<Product>(:final value):
        emit(
          state.copyWith(
            isSaving: false,
            clearSaveFailure: true,
            product: value,
            status: ProductDetailStatus.data,
          ),
        );
        return true;
    }
  }

  Future<void> suggestionToggled() async {
    final product = state.product;
    if (product == null) return;
    final result = product.isSuggested
        ? await _unsuggestProduct(product.id)
        : await _suggestProduct(product.id);
    if (isClosed) return;
    switch (result) {
      case FailureResult<Product>(:final failure):
        emit(state.copyWith(saveFailure: failure));
      case Success<Product>(:final value):
        emit(
          state.copyWith(
            product: value,
            clearSaveFailure: true,
            status: ProductDetailStatus.data,
          ),
        );
    }
  }

  Future<void> _load() async {
    emit(
      state.copyWith(
        status: ProductDetailStatus.loading,
        clearFailure: true,
      ),
    );
    final productResult = await _getProduct(productId);
    if (isClosed) return;
    if (productResult is FailureResult<Product>) {
      emit(
        state.copyWith(
          status: ProductDetailStatus.error,
          failure: productResult.failure,
        ),
      );
      return;
    }
    final product = (productResult as Success<Product>).value;

    final historyResult = await _listHistory(productId);
    if (isClosed) return;
    if (historyResult is FailureResult<List<ProductPurchaseHistoryEntry>>) {
      emit(
        state.copyWith(
          status: ProductDetailStatus.error,
          failure: historyResult.failure,
        ),
      );
      return;
    }
    final history =
        (historyResult as Success<List<ProductPurchaseHistoryEntry>>).value;

    emit(
      state.copyWith(
        status: ProductDetailStatus.data,
        product: product,
        history: history,
      ),
    );
  }
}
