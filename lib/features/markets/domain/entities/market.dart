import 'package:equatable/equatable.dart';

class Market extends Equatable {
  const Market({
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

  Market copyWith({
    String? name,
    String? nameNormalized,
    String? location,
    bool clearLocation = false,
    String? notes,
    bool clearNotes = false,
    bool? isActive,
    int? updatedAt,
  }) {
    return Market(
      id: id,
      name: name ?? this.name,
      nameNormalized: nameNormalized ?? this.nameNormalized,
      location: clearLocation ? null : (location ?? this.location),
      notes: clearNotes ? null : (notes ?? this.notes),
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nameNormalized,
        location,
        notes,
        isActive,
        createdAt,
        updatedAt,
      ];
}
