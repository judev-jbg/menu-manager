import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/meal_day.dart';
import '../models/shopping_item.dart';

// Helper para gestionar la base de datos SQLite
// Implementa el patrón Singleton para tener una única instancia
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Getter para obtener la instancia de la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('menu_manager.db');
    return _database!;
  }

  // Inicializa la base de datos
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Crea las tablas de la base de datos
  Future<void> _createDB(Database db, int version) async {
    // Tabla de comidas (meal_days)
    // Una fila representa todas las comidas de un día específico
    await db.execute('''
      CREATE TABLE meal_days (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        breakfast TEXT,
        lunch TEXT,
        dinner TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Tabla de lista de compras (shopping_items)
    await db.execute('''
      CREATE TABLE shopping_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // ==================== OPERACIONES CRUD PARA MEAL_DAYS ====================

  // Crea un nuevo día de comidas
  // Retorna el id del registro creado
  Future<int> createMealDay(MealDay mealDay) async {
    final db = await database;
    return await db.insert('meal_days', mealDay.toMap());
  }

  // Obtiene todos los días de comidas ordenados por fecha (más antigua primero)
  Future<List<MealDay>> getAllMealDays() async {
    final db = await database;
    final result = await db.query(
      'meal_days',
      orderBy: 'date ASC', // Ordenar por fecha más antigua primero
    );
    return result.map((map) => MealDay.fromMap(map)).toList();
  }

  // Obtiene un día de comidas por su ID
  Future<MealDay?> getMealDayById(int id) async {
    final db = await database;
    final result = await db.query(
      'meal_days',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return MealDay.fromMap(result.first);
    }
    return null;
  }

  // Verifica si ya existe un MealDay para una fecha específica
  // Retorna el MealDay existente o null si no existe
  Future<MealDay?> getMealDayByDate(DateTime date) async {
    final db = await database;
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final result = await db.query(
      'meal_days',
      where: 'date = ?',
      whereArgs: [dateString],
    );

    if (result.isNotEmpty) {
      return MealDay.fromMap(result.first);
    }
    return null;
  }

  // Actualiza un día de comidas existente
  // Retorna el número de filas afectadas (debería ser 1)
  Future<int> updateMealDay(MealDay mealDay) async {
    final db = await database;
    return await db.update(
      'meal_days',
      mealDay.toMap(),
      where: 'id = ?',
      whereArgs: [mealDay.id],
    );
  }

  // Elimina un día de comidas por su ID
  // Retorna el número de filas eliminadas (debería ser 1)
  Future<int> deleteMealDay(int id) async {
    final db = await database;
    return await db.delete(
      'meal_days',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== OPERACIONES CRUD PARA SHOPPING_ITEMS ====================

  // Crea un nuevo item de compra
  // Retorna el id del registro creado
  Future<int> createShoppingItem(ShoppingItem item) async {
    final db = await database;
    return await db.insert('shopping_items', item.toMap());
  }

  // Obtiene todos los items de compra ordenados por fecha de creación
  Future<List<ShoppingItem>> getAllShoppingItems() async {
    final db = await database;
    final result = await db.query(
      'shopping_items',
      orderBy: 'created_at ASC', // Ordenar por orden de creación
    );
    return result.map((map) => ShoppingItem.fromMap(map)).toList();
  }

  // Obtiene un item de compra por su ID
  Future<ShoppingItem?> getShoppingItemById(int id) async {
    final db = await database;
    final result = await db.query(
      'shopping_items',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return ShoppingItem.fromMap(result.first);
    }
    return null;
  }

  // Actualiza un item de compra existente
  // Retorna el número de filas afectadas (debería ser 1)
  Future<int> updateShoppingItem(ShoppingItem item) async {
    final db = await database;
    return await db.update(
      'shopping_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Elimina un item de compra por su ID
  // Retorna el número de filas eliminadas (debería ser 1)
  Future<int> deleteShoppingItem(int id) async {
    final db = await database;
    return await db.delete(
      'shopping_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== UTILIDADES ====================

  // Cierra la base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // Elimina todas las tablas (útil para testing)
  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete('meal_days');
    await db.delete('shopping_items');
  }
}
