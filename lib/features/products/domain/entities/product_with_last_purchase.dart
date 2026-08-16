import 'package:equatable/equatable.dart';
import 'package:home_market_tracker/features/products/domain/entities/product.dart';
import 'package:home_market_tracker/features/products/domain/entities/product_last_purchase.dart';

class ProductWithLastPurchase extends Equatable {
  const ProductWithLastPurchase({
    required this.product,
    required this.lastPurchase,
  });

  final Product product;
  final ProductLastPurchase? lastPurchase;

  @override
  List<Object?> get props => [product, lastPurchase];
}
