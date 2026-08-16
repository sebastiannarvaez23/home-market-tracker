import 'package:home_market_tracker/core/database/database_tables.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/core/value/quantity.dart';
import 'package:home_market_tracker/core/value/unit_of_measure.dart';
import 'package:home_market_tracker/core/value/uom_ladder.dart';
import 'package:home_market_tracker/features/products/domain/entities/product.dart';
import 'package:home_market_tracker/features/products/domain/entities/product_last_purchase.dart';
import 'package:home_market_tracker/features/products/domain/entities/product_with_last_purchase.dart';

class ProductUomStepModel {
  const ProductUomStepModel({
    required this.uom,
    required this.factor,
    required this.sortOrder,
  });

  final String uom;
  final double factor;
  final int sortOrder;

  factory ProductUomStepModel.fromMap(Map<String, Object?> map) {
    return ProductUomStepModel(
      uom: map[ProductUomStepColumns.uom]! as String,
      factor: (map[ProductUomStepColumns.factor] as num).toDouble(),
      sortOrder: map[ProductUomStepColumns.sortOrder]! as int,
    );
  }

  UomLadderStep toEntity() {
    return UomLadderStep(
      uom: UnitOfMeasure.fromStorage(uom),
      factor: Quantity.milli((factor * 1000).round()),
    );
  }
}

class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.nameNormalized,
    required this.notes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.baseUom = 'Und',
    this.steps = const [],
    this.lastMarketName,
    this.lastUnitPrice,
    this.lastUom,
    this.lastUomFactor,
    this.lastPurchasedAt,
    this.isSuggested = false,
    this.photoPath,
  });

  final String id;
  final String name;
  final String nameNormalized;
  final String? notes;
  final bool isActive;
  final int createdAt;
  final int updatedAt;
  final String baseUom;
  final List<ProductUomStepModel> steps;
  final String? lastMarketName;
  final double? lastUnitPrice;
  final String? lastUom;
  final double? lastUomFactor;
  final int? lastPurchasedAt;
  final bool isSuggested;
  final String? photoPath;

  ProductModel withSteps(List<ProductUomStepModel> steps) {
    return ProductModel(
      id: id,
      name: name,
      nameNormalized: nameNormalized,
      notes: notes,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      baseUom: baseUom,
      steps: steps,
      lastMarketName: lastMarketName,
      lastUnitPrice: lastUnitPrice,
      lastUom: lastUom,
      lastUomFactor: lastUomFactor,
      lastPurchasedAt: lastPurchasedAt,
      isSuggested: isSuggested,
      photoPath: photoPath,
    );
  }

  factory ProductModel.fromMap(Map<String, Object?> map) {
    return ProductModel(
      id: map[ProductColumns.id]! as String,
      name: map[ProductColumns.name]! as String,
      nameNormalized: map[ProductColumns.nameNormalized]! as String,
      notes: map[ProductColumns.notes] as String?,
      isActive: (map[ProductColumns.isActive] as int) == 1,
      createdAt: map[ProductColumns.createdAt]! as int,
      updatedAt: map[ProductColumns.updatedAt]! as int,
      baseUom: (map[ProductColumns.baseUom] as String?) ?? UnitOfMeasure.unit.code,
      lastMarketName: map[LastPurchaseColumns.marketNameSnapshot] as String?,
      lastUnitPrice: (map[LastPurchaseColumns.unitPrice] as num?)?.toDouble(),
      lastUom: map[LastPurchaseColumns.uom] as String?,
      lastUomFactor: (map[LastPurchaseColumns.uomFactor] as num?)?.toDouble(),
      lastPurchasedAt: map[LastPurchaseColumns.purchasedAt] as int?,
      isSuggested: (map[ProductColumns.isSuggested] as int?) == 1,
      photoPath: map[ProductColumns.photoPath] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      ProductColumns.id: id,
      ProductColumns.name: name,
      ProductColumns.nameNormalized: nameNormalized,
      ProductColumns.notes: notes,
      ProductColumns.isActive: isActive ? 1 : 0,
      ProductColumns.createdAt: createdAt,
      ProductColumns.updatedAt: updatedAt,
      ProductColumns.baseUom: baseUom,
      ProductColumns.isSuggested: isSuggested ? 1 : 0,
      ProductColumns.photoPath: photoPath,
    };
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      nameNormalized: product.nameNormalized,
      notes: product.notes,
      isActive: product.isActive,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      isSuggested: product.isSuggested,
      photoPath: product.photoPath,
      baseUom: product.uomLadder.base.code,
      steps: [
        for (var i = 0; i < product.uomLadder.steps.length; i++)
          ProductUomStepModel(
            uom: product.uomLadder.steps[i].uom.code,
            factor: product.uomLadder.steps[i].factor.value,
            sortOrder: i,
          ),
      ],
    );
  }

  UomLadder get ladder {
    return UomLadder(
      base: UnitOfMeasure.fromStorage(baseUom),
      steps: steps.map((step) => step.toEntity()).toList(growable: false),
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      nameNormalized: nameNormalized,
      notes: notes,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      uomLadder: ladder,
      isSuggested: isSuggested,
      photoPath: photoPath,
    );
  }

  ProductWithLastPurchase toEntityWithLastPurchase() {
    ProductLastPurchase? lastPurchase;
    if (lastMarketName != null &&
        lastUnitPrice != null &&
        lastPurchasedAt != null) {
      lastPurchase = ProductLastPurchase(
        marketName: lastMarketName!,
        unitPrice: Money.cents((lastUnitPrice! * 100).round()),
        uom: UnitOfMeasure.fromStorage(lastUom ?? UnitOfMeasure.unit.code),
        uomFactor: Quantity.milli(((lastUomFactor ?? 1) * 1000).round()),
        purchasedAt: lastPurchasedAt!,
      );
    }
    return ProductWithLastPurchase(
      product: toEntity(),
      lastPurchase: lastPurchase,
    );
  }
}
