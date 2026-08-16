import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/id/id_generator.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/core/value/quantity.dart';
import 'package:home_market_tracker/core/value/unit_of_measure.dart';
import 'package:home_market_tracker/core/value/uom_ladder.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_catalog_refs.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_item.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_session.dart';
import 'package:home_market_tracker/features/shopping/domain/repositories/shopping_repository.dart';

class UpsertShoppingItemParams {
  const UpsertShoppingItemParams({
    required this.productId,
    required this.unitPrice,
    this.quantity = 1,
    this.uom,
    this.uomFactor,
  });

  final String productId;
  final num unitPrice;
  final num quantity;
  final UnitOfMeasure? uom;
  final num? uomFactor;
}

class UpsertShoppingItem
    extends UseCase<ShoppingSession, UpsertShoppingItemParams> {
  UpsertShoppingItem(
    this._repository, {
    required IdGenerator idGenerator,
  }) : _idGenerator = idGenerator;

  final ShoppingRepository _repository;
  final IdGenerator _idGenerator;

  @override
  Future<Result<ShoppingSession>> call(UpsertShoppingItemParams params) async {
    final quantityResult = Quantity.parse(params.quantity);
    if (quantityResult is FailureResult<Quantity>) {
      return Result.failure(quantityResult.failure);
    }
    final priceResult = Money.parse(params.unitPrice);
    if (priceResult is FailureResult<Money>) {
      return Result.failure(priceResult.failure);
    }
    final quantity = (quantityResult as Success<Quantity>).value;
    final unitPrice = (priceResult as Success<Money>).value;

    final sessionResult = await _repository.findInProgress();
    if (sessionResult is FailureResult<ShoppingSession?>) {
      return Result.failure(sessionResult.failure);
    }
    final session = (sessionResult as Success<ShoppingSession?>).value;
    if (session == null) {
      return const Result.failure(
        Failure.precondition(
          'Configura un mercado antes de agregar productos.',
        ),
      );
    }

    final productResult = await _repository.getProduct(params.productId);
    if (productResult is FailureResult<ShoppingProductRef>) {
      return Result.failure(productResult.failure);
    }
    final product = (productResult as Success<ShoppingProductRef>).value;
    if (!product.isActive) {
      return const Result.failure(
        Failure.inactive('No se puede agregar un producto eliminado.'),
      );
    }

    Quantity? packagingFactor;
    if (params.uomFactor != null) {
      final factorResult = Quantity.parse(params.uomFactor!);
      if (factorResult is FailureResult<Quantity>) {
        return Result.failure(factorResult.failure);
      }
      packagingFactor = (factorResult as Success<Quantity>).value;
    }
    final selection = product.uomLadder.resolve(
      uom: params.uom,
      factor: packagingFactor,
    );
    if (selection is FailureResult<UomLadderStep>) {
      return Result.failure(selection.failure);
    }
    final chosen = (selection as Success<UomLadderStep>).value;

    final existing = session.items.where((item) => item.productId == product.id);
    final itemId = existing.isEmpty ? _idGenerator.next() : existing.first.id;

    return _repository.upsertItem(
      sessionId: session.id,
      item: ShoppingItem(
        id: itemId,
        sessionId: session.id,
        productId: product.id,
        productNameSnapshot: product.name,
        quantity: quantity,
        uom: chosen.uom,
        uomFactor: chosen.factor,
        unitPrice: unitPrice,
      ),
    );
  }
}
