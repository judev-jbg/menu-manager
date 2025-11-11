// Modelo para representar las comidas de un día completo
class MealDay {
  final int? id;
  final DateTime date; // Fecha del día (sin hora)
  final String? breakfast; // Desayuno (opcional)
  final String? lunch; // Comida (opcional)
  final String? dinner; // Cena (opcional)
  final DateTime createdAt; // Fecha de creación del registro

  MealDay({
    this.id,
    required this.date,
    this.breakfast,
    this.lunch,
    this.dinner,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Validación: Al menos una comida debe estar asignada
  bool get isValid =>
      (breakfast != null && breakfast!.isNotEmpty) ||
      (lunch != null && lunch!.isNotEmpty) ||
      (dinner != null && dinner!.isNotEmpty);

  // Verifica si la fecha es anterior a hoy (para el efecto visual opaco)
  bool get isPastDate {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final mealDate = DateTime(date.year, date.month, date.day);
    return mealDate.isBefore(todayDate);
  }

  // Convierte el modelo a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': _dateToString(date),
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Crea un modelo desde un Map de SQLite
  factory MealDay.fromMap(Map<String, dynamic> map) {
    return MealDay(
      id: map['id'] as int?,
      date: _stringToDate(map['date'] as String),
      breakfast: map['breakfast'] as String?,
      lunch: map['lunch'] as String?,
      dinner: map['dinner'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Crea una copia del modelo con campos actualizados
  MealDay copyWith({
    int? id,
    DateTime? date,
    String? breakfast,
    String? lunch,
    String? dinner,
    DateTime? createdAt,
  }) {
    return MealDay(
      id: id ?? this.id,
      date: date ?? this.date,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Convierte DateTime a String formato YYYY-MM-DD (solo fecha, sin hora)
  static String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Convierte String YYYY-MM-DD a DateTime (solo fecha, sin hora)
  static DateTime _stringToDate(String dateString) {
    final parts = dateString.split('-');
    return DateTime(
      int.parse(parts[0]), // year
      int.parse(parts[1]), // month
      int.parse(parts[2]), // day
    );
  }

  @override
  String toString() {
    return 'MealDay{id: $id, date: ${_dateToString(date)}, breakfast: $breakfast, lunch: $lunch, dinner: $dinner}';
  }
}
