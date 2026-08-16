import 'package:equatable/equatable.dart';
import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/features/products/domain/entities/product.dart';
import 'package:home_market_tracker/features/products/domain/entities/product_purchase_history_entry.dart';

enum ProductDetailStatus { initial, loading, data, error }

class ProductDetailState extends Equatable {
  const ProductDetailState({
    this.status = ProductDetailStatus.initial,
    this.product,
    this.history = const [],
    this.failure,
    this.isSaving = false,
    this.saveFailure,
  });

  final ProductDetailStatus status;
  final Product? product;
  final List<ProductPurchaseHistoryEntry> history;
  final Failure? failure;
  final bool isSaving;
  final Failure? saveFailure;

  ProductDetailState copyWith({
    ProductDetailStatus? status,
    Product? product,
    List<ProductPurchaseHistoryEntry>? history,
    Failure? failure,
    bool clearFailure = false,
    bool? isSaving,
    Failure? saveFailure,
    bool clearSaveFailure = false,
  }) {
    return ProductDetailState(
      status: status ?? this.status,
      product: product ?? this.product,
      history: history ?? this.history,
      failure: clearFailure ? null : (failure ?? this.failure),
      isSaving: isSaving ?? this.isSaving,
      saveFailure:
          clearSaveFailure ? null : (saveFailure ?? this.saveFailure),
    );
  }

  @override
  List<Object?> get props => [
        status,
        product,
        history,
        failure,
        isSaving,
        saveFailure,
      ];
}
