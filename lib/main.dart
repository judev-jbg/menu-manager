import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Provider se importará en la Fase 3

// Imports para Fase 2
import 'database/database_helper.dart';
import 'models/meal_day.dart';
import 'models/shopping_item.dart';

void main() {
  runApp(const MenuManagerApp());
}

class MenuManagerApp extends StatelessWidget {
  const MenuManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider se agregará en la Fase 3 cuando tengamos los providers
    return MaterialApp(
      title: 'Menu Manager',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const HomeScreen(),
    );
  }

  // Tema personalizado de la aplicación
  ThemeData _buildTheme() {
    return ThemeData(
      // Colores principales
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      primaryColor: const Color(0xFF54D3C2),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF54D3C2),
        primary: const Color(0xFF54D3C2),
        background: const Color(0xFFF5F5F5),
      ),

      // Tema de AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: GoogleFonts.inter(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Tema de Cards
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Tema de FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF54D3C2),
        foregroundColor: Colors.white,
      ),

      // Tema de inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF54D3C2), width: 2),
        ),
      ),

      // Fuente Inter para toda la app
      textTheme: GoogleFonts.interTextTheme(),
    );
  }
}

// Pantalla principal temporal (se implementará en la siguiente fase)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _dbHelper = DatabaseHelper.instance;
  String _testResult = 'Presiona el botón para probar la base de datos';
  bool _isLoading = false;

  // Prueba las operaciones CRUD de la base de datos
  Future<void> _testDatabase() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Probando base de datos...';
    });

    try {
      final results = <String>[];

      // 1. Crear un MealDay de prueba
      results.add('--- PRUEBA MEAL_DAYS ---');
      final today = DateTime.now();
      final mealDay = MealDay(
        date: today,
        breakfast: 'Huevos con tocino',
        lunch: 'Pasta con pollo',
        dinner: 'Ensalada César',
      );

      final mealId = await _dbHelper.createMealDay(mealDay);
      results.add('✅ MealDay creado con ID: $mealId');

      // 2. Leer el MealDay creado
      final retrievedMeal = await _dbHelper.getMealDayById(mealId);
      results.add('✅ MealDay leído: ${retrievedMeal?.breakfast}');

      // 3. Actualizar el MealDay
      if (retrievedMeal != null) {
        final updatedMeal = retrievedMeal.copyWith(
          breakfast: 'Huevos revueltos (actualizado)',
        );
        await _dbHelper.updateMealDay(updatedMeal);
        results.add('✅ MealDay actualizado');
      }

      // 4. Verificar fecha única
      final existingMeal = await _dbHelper.getMealDayByDate(today);
      results.add(
          '✅ Verificación fecha única: ${existingMeal != null ? "Existe" : "No existe"}');

      // 5. Crear un ShoppingItem de prueba
      results.add('\n--- PRUEBA SHOPPING_ITEMS ---');
      final shoppingItem = ShoppingItem(
        description: 'Leche entera',
      );

      final shoppingId = await _dbHelper.createShoppingItem(shoppingItem);
      results.add('✅ ShoppingItem creado con ID: $shoppingId');

      // 6. Leer el ShoppingItem creado
      final retrievedItem = await _dbHelper.getShoppingItemById(shoppingId);
      results.add('✅ ShoppingItem leído: ${retrievedItem?.description}');

      // 7. Listar todos los registros
      final allMeals = await _dbHelper.getAllMealDays();
      final allShopping = await _dbHelper.getAllShoppingItems();
      results.add('\n--- RESUMEN ---');
      results.add('Total MealDays: ${allMeals.length}');
      results.add('Total ShoppingItems: ${allShopping.length}');

      setState(() {
        _testResult = results.join('\n');
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Pruebas completadas exitosamente'),
            backgroundColor: Color(0xFF54D3C2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _testResult = '❌ Error: $e';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Limpia todos los datos de prueba
  Future<void> _clearDatabase() async {
    try {
      await _dbHelper.deleteAllData();
      setState(() {
        _testResult = '🗑️ Base de datos limpiada';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Base de datos limpiada'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al limpiar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Menu Manager',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Fase 2: Base de datos',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.storage,
              size: 60,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Prueba de Base de Datos',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Botones de prueba
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testDatabase,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.play_arrow),
                  label: const Text('Probar DB'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF54D3C2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _clearDatabase,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Limpiar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Resultados de las pruebas
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResult,
                    style: GoogleFonts.robotoMono(
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _testDatabase,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
