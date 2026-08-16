import 'package:equatable/equatable.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/features/products/domain/entities/product_with_last_purchase.dart';

enum ProductsListStatus { initial, loading, empty, data, error }

class ProductsListState extends Equatable {
  const ProductsListState({
    this.status = ProductsListStatus.initial,
    this.products = const [],
    this.query = '',
    this.searchVisible = false,
    this.failure,
    this.isCreating = false,
    this.createFailure,
  });

  final ProductsListStatus status;
  final List<ProductWithLastPurchase> products;
  final String query;
  final bool searchVisible;
  final Failure? failure;
  final bool isCreating;
  final Failure? createFailure;

  String get emptyMessage {
    if (query.isNotEmpty && products.isEmpty) {
      return AppStrings.emptySearch;
    }
    return AppStrings.emptyProducts;
  }

  ProductsListState copyWith({
    ProductsListStatus? status,
    List<ProductWithLastPurchase>? products,
    String? query,
    bool? searchVisible,
    Failure? failure,
    bool clearFailure = false,
    bool? isCreating,
    Failure? createFailure,
    bool clearCreateFailure = false,
  }) {
    return ProductsListState(
      status: status ?? this.status,
      products: products ?? this.products,
      query: query ?? this.query,
      searchVisible: searchVisible ?? this.searchVisible,
      failure: clearFailure ? null : (failure ?? this.failure),
      isCreating: isCreating ?? this.isCreating,
      createFailure:
          clearCreateFailure ? null : (createFailure ?? this.createFailure),
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        query,
        searchVisible,
        failure,
        isCreating,
        createFailure,
      ];
}
