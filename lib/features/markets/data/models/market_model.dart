import 'package:home_market_tracker/core/database/database_tables.dart';
import 'package:home_market_tracker/features/markets/domain/entities/market.dart';

class MarketModel {
  const MarketModel({
    required this.id,
    required this.name,
    required this.nameNormalized,
    required this.location,
    required this.notes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String nameNormalized;
  final String? location;
  final String? notes;
  final bool isActive;
  final int createdAt;
  final int updatedAt;

  factory MarketModel.fromMap(Map<String, Object?> map) {
    return MarketModel(
      id: map[MarketColumns.id]! as String,
      name: map[MarketColumns.name]! as String,
      nameNormalized: map[MarketColumns.nameNormalized]! as String,
      location: map[MarketColumns.location] as String?,
      notes: map[MarketColumns.notes] as String?,
      isActive: (map[MarketColumns.isActive] as int) == 1,
      createdAt: map[MarketColumns.createdAt]! as int,
      updatedAt: map[MarketColumns.updatedAt]! as int,
    );
  }

  Map<String, Object?> toMap() {
    return {
      MarketColumns.id: id,
      MarketColumns.name: name,
      MarketColumns.nameNormalized: nameNormalized,
      MarketColumns.location: location,
      MarketColumns.notes: notes,
      MarketColumns.isActive: isActive ? 1 : 0,
      MarketColumns.createdAt: createdAt,
      MarketColumns.updatedAt: updatedAt,
    };
  }

  factory MarketModel.fromEntity(Market market) {
    return MarketModel(
      id: market.id,
      name: market.name,
      nameNormalized: market.nameNormalized,
      location: market.location,
      notes: market.notes,
      isActive: market.isActive,
      createdAt: market.createdAt,
      updatedAt: market.updatedAt,
    );
  }

  Market toEntity() {
    return Market(
      id: id,
      name: name,
      nameNormalized: nameNormalized,
      location: location,
      notes: notes,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
