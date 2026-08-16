import 'package:equatable/equatable.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_catalog_refs.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_item.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_session.dart';

enum ShoppingViewStatus { initial, loading, empty, data, error }

class ShoppingSessionState extends Equatable {
  const ShoppingSessionState({
    this.status = ShoppingViewStatus.initial,
    this.session,
    this.products = const [],
    this.query = '',
    this.failure,
    this.isAdding = false,
    this.addFailure,
    this.isCompleting = false,
    this.actionFailure,
  });

  final ShoppingViewStatus status;
  final ShoppingSession? session;
  final List<ShoppingProductRef> products;
  final String query;
  final Failure? failure;
  final bool isAdding;
  final Failure? addFailure;
  final bool isCompleting;
  final Failure? actionFailure;

  String get emptyMessage {
    if (query.isNotEmpty) return AppStrings.emptySearch;
    return AppStrings.emptyShoppingCatalog;
  }

  Money get total => session?.total ?? Money.zero();

  int? get urgencyDividerAfterIndex {
    for (var i = 0; i < products.length - 1; i++) {
      if (products[i].isSuggested && !products[i + 1].isSuggested) {
        return i;
      }
    }
    return null;
  }

  ShoppingProductRef? productById(String productId) {
    for (final product in products) {
      if (product.id == productId) return product;
    }
    return null;
  }

  ShoppingItem? itemFor(String productId) {
    final items = session?.items ?? const [];
    for (final item in items) {
      if (item.productId == productId) return item;
    }
    return null;
  }

  ShoppingSessionState copyWith({
    ShoppingViewStatus? status,
    ShoppingSession? session,
    List<ShoppingProductRef>? products,
    String? query,
    Failure? failure,
    bool clearFailure = false,
    bool? isAdding,
    Failure? addFailure,
    bool clearAddFailure = false,
    bool? isCompleting,
    Failure? actionFailure,
    bool clearActionFailure = false,
  }) {
    return ShoppingSessionState(
      status: status ?? this.status,
      session: session ?? this.session,
      products: products ?? this.products,
      query: query ?? this.query,
      failure: clearFailure ? null : (failure ?? this.failure),
      isAdding: isAdding ?? this.isAdding,
      addFailure: clearAddFailure ? null : (addFailure ?? this.addFailure),
      isCompleting: isCompleting ?? this.isCompleting,
      actionFailure:
          clearActionFailure ? null : (actionFailure ?? this.actionFailure),
    );
  }

  @override
  List<Object?> get props => [
        status,
        session,
        products,
        query,
        failure,
        isAdding,
        addFailure,
        isCompleting,
        actionFailure,
      ];
}
