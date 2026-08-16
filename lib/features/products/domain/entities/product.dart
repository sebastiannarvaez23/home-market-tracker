import 'package:equatable/equatable.dart';
import 'package:home_market_tracker/core/value/uom_ladder.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.nameNormalized,
    required this.notes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.uomLadder = UomLadder.unitOnly,
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
  final UomLadder uomLadder;
  final bool isSuggested;

  /// Ruta relativa en documentos de la app (`product_photos/{id}.jpg`).
  /// Nula solo en productos creados antes de exigir foto.
  final String? photoPath;

  Product copyWith({
    String? name,
    String? nameNormalized,
    String? notes,
    bool clearNotes = false,
    bool? isActive,
    int? updatedAt,
    UomLadder? uomLadder,
    bool? isSuggested,
    String? photoPath,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      nameNormalized: nameNormalized ?? this.nameNormalized,
      notes: clearNotes ? null : (notes ?? this.notes),
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      uomLadder: uomLadder ?? this.uomLadder,
      isSuggested: isSuggested ?? this.isSuggested,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nameNormalized,
        notes,
        isActive,
        createdAt,
        updatedAt,
        uomLadder,
        isSuggested,
        photoPath,
      ];
}
