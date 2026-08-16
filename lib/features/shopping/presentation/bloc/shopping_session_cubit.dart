import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/formatters/money_input_formatter.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/core/value/unit_of_measure.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_catalog_refs.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_session.dart';
import 'package:home_market_tracker/features/shopping/domain/usecases/cancel_shopping.dart';
import 'package:home_market_tracker/features/shopping/domain/usecases/complete_shopping.dart';
import 'package:home_market_tracker/features/shopping/domain/usecases/get_in_progress_shopping.dart';
import 'package:home_market_tracker/features/shopping/domain/usecases/list_shopping_catalog.dart';
import 'package:home_market_tracker/features/shopping/domain/usecases/upsert_shopping_item.dart';
import 'package:home_market_tracker/features/shopping/presentation/bloc/shopping_session_state.dart';

class ShoppingSessionCubit extends Cubit<ShoppingSessionState> {
  ShoppingSessionCubit({
    required GetInProgressShopping getInProgress,
    required ListShoppingCatalog listCatalog,
    required UpsertShoppingItem upsertItem,
    required CompleteShopping completeShopping,
    required CancelShopping cancelShopping,
  })  : _getInProgress = getInProgress,
        _listCatalog = listCatalog,
        _upsertItem = upsertItem,
        _completeShopping = completeShopping,
        _cancelShopping = cancelShopping,
        super(const ShoppingSessionState());

  final GetInProgressShopping _getInProgress;
  final ListShoppingCatalog _listCatalog;
  final UpsertShoppingItem _upsertItem;
  final CompleteShopping _completeShopping;
  final CancelShopping _cancelShopping;

  Future<void> started() => _load();

  Future<void> retried() => _load();

  Future<void> refreshed() =>
      _loadCatalog(session: state.session, silent: true);

  Future<void> queryChanged(String query) async {
    emit(state.copyWith(query: query));
    await _loadCatalog(session: state.session, silent: true);
  }

  void addFormOpened() {
    emit(state.copyWith(clearAddFailure: true, isAdding: false));
  }

  Future<bool> addItem({
    required String productId,
    required String unitPrice,
    String quantity = '1',
    UnitOfMeasure? uom,
    num? uomFactor,
  }) async {
    final price = MoneyInputFormatter.parsePesos(unitPrice);
    final qty = _parseAmount(quantity);
    if (price == null || qty == null) {
      emit(
        state.copyWith(
          addFailure: const Failure.validation(AppStrings.invalidPrice),
        ),
      );
      return false;
    }

    emit(state.copyWith(isAdding: true, clearAddFailure: true));
    final result = await _upsertItem(
      UpsertShoppingItemParams(
        productId: productId,
        unitPrice: price,
        quantity: qty,
        uom: uom,
        uomFactor: uomFactor,
      ),
    );
    if (isClosed) return false;

    switch (result) {
      case FailureResult<ShoppingSession>(:final failure):
        emit(state.copyWith(isAdding: false, addFailure: failure));
        return false;
      case Success<ShoppingSession>(:final value):
        emit(
          state.copyWith(
            isAdding: false,
            session: value,
            clearAddFailure: true,
          ),
        );
        return true;
    }
  }

  Future<bool> completed() async {
    emit(state.copyWith(isCompleting: true, clearActionFailure: true));
    final result = await _completeShopping(const NoParams());
    if (isClosed) return false;

    switch (result) {
      case FailureResult<ShoppingSession>(:final failure):
        emit(state.copyWith(isCompleting: false, actionFailure: failure));
        return false;
      case Success<ShoppingSession>():
        emit(state.copyWith(isCompleting: false, clearActionFailure: true));
        return true;
    }
  }

  Future<bool> discarded() async {
    emit(state.copyWith(clearActionFailure: true));
    final result = await _cancelShopping(const NoParams());
    if (isClosed) return false;

    switch (result) {
      case FailureResult<void>(:final failure):
        emit(state.copyWith(actionFailure: failure));
        return false;
      case Success<void>():
        return true;
    }
  }

  Future<void> _load() async {
    emit(state.copyWith(status: ShoppingViewStatus.loading, clearFailure: true));
    final sessionResult = await _getInProgress(const NoParams());
    if (isClosed) return;
    if (sessionResult is FailureResult<ShoppingSession?>) {
      emit(
        state.copyWith(
          status: ShoppingViewStatus.error,
          failure: sessionResult.failure,
        ),
      );
      return;
    }
    final session = (sessionResult as Success<ShoppingSession?>).value;
    if (session == null) {
      emit(
        state.copyWith(
          status: ShoppingViewStatus.error,
          failure: const Failure.precondition(AppStrings.errorLoadShopping),
        ),
      );
      return;
    }

    await _loadCatalog(session: session);
  }

  Future<void> _loadCatalog({
    required ShoppingSession? session,
    bool silent = false,
  }) async {
    final catalogResult = await _listCatalog(
      ListShoppingCatalogParams(
        nameQuery: state.query.isEmpty ? null : state.query,
      ),
    );
    if (isClosed) return;
    switch (catalogResult) {
      case FailureResult<List<ShoppingProductRef>>(:final failure):
        emit(
          state.copyWith(
            status: ShoppingViewStatus.error,
            session: session,
            failure: failure,
          ),
        );
      case Success<List<ShoppingProductRef>>(:final value):
        emit(
          state.copyWith(
            status: value.isEmpty
                ? ShoppingViewStatus.empty
                : ShoppingViewStatus.data,
            session: session,
            products: value,
            clearFailure: !silent,
          ),
        );
    }
  }

  num? _parseAmount(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return num.tryParse(normalized);
  }
}
