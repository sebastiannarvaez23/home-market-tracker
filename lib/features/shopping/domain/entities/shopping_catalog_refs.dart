import 'package:equatable/equatable.dart';
import 'package:home_market_tracker/core/value/uom_ladder.dart';

class ShoppingMarketRef extends Equatable {
  const ShoppingMarketRef({
    required this.id,
    required this.name,
    required this.isActive,
  });

  final String id;
  final String name;
  final bool isActive;

  @override
  List<Object?> get props => [id, name, isActive];
}

class ShoppingProductRef extends Equatable {
  const ShoppingProductRef({
    required this.id,
    required this.name,
    required this.isActive,
    this.uomLadder = UomLadder.unitOnly,
    this.isSuggested = false,
    this.photoPath,
  });

  final String id;
  final String name;
  final bool isActive;
  final UomLadder uomLadder;
  final bool isSuggested;
  final String? photoPath;

  ShoppingProductRef copyWith({bool? isSuggested, String? photoPath}) {
    return ShoppingProductRef(
      id: id,
      name: name,
      isActive: isActive,
      uomLadder: uomLadder,
      isSuggested: isSuggested ?? this.isSuggested,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, isActive, uomLadder, isSuggested, photoPath];
}
