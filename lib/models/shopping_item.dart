// Modelo para representar un item de la lista de compras
class ShoppingItem {
  final int? id;
  final String description; // Descripción del item (texto libre)
  final DateTime createdAt; // Fecha de creación para ordenamiento

  ShoppingItem({
    this.id,
    required this.description,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Validación: la descripción no debe estar vacía
  bool get isValid => description.trim().isNotEmpty;

  // Convierte el modelo a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Crea un modelo desde un Map de SQLite
  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'] as int?,
      description: map['description'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Crea una copia del modelo con campos actualizados
  ShoppingItem copyWith({
    int? id,
    String? description,
    DateTime? createdAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ShoppingItem{id: $id, description: $description, createdAt: $createdAt}';
  }
}
