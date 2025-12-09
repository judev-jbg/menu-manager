import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/meal_day.dart';
import '../models/shopping_item.dart';
import '../providers/meals_provider.dart';
import '../providers/shopping_provider.dart';
import '../widgets/meal_list_view.dart';
import '../widgets/shopping_list_view.dart';
import '../widgets/create_meal_dialog.dart';
import '../widgets/create_shopping_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Listener para actualizar el título cuando cambia el tab
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Obtiene el título dinámico según el tab seleccionado
  String get _currentTitle {
    return _tabController.index == 0 ? 'Mis Menús' : 'Mi Lista de Compras';
  }

  // Obtiene el número de elementos según el tab seleccionado
  int get _currentItemCount {
    if (_tabController.index == 0) {
      return context.watch<MealsProvider>().itemCount;
    } else {
      return context.watch<ShoppingProvider>().itemCount;
    }
  }

  // Callback para el botón FAB
  Future<void> _onFabPressed() async {
    if (_tabController.index == 0) {
      // Mostrar diálogo para crear MealDay
      await _createMealDay();
    } else {
      // Mostrar diálogo para crear ShoppingItem
      await _createShoppingItem();
    }
  }

  // Muestra el diálogo para crear un nuevo MealDay
  Future<void> _createMealDay() async {
    MealDay? result;
    bool shouldClose = false;

    while (!shouldClose) {
      // Obtener la lista actual de meals para calcular la fecha inicial
      final existingMeals = context.read<MealsProvider>().mealDays;

      result = await showModalBottomSheet<MealDay>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: true,
        builder: (context) => CreateMealDialog(
          mealDay: result,
          existingMeals: existingMeals,
        ),
      );

      if (result == null) {
        shouldClose = true;
        break;
      }

      if (mounted) {
        final provider = context.read<MealsProvider>();
        final success = await provider.createMealDay(result);

        if (success) {
          shouldClose = true;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Comida creada exitosamente'),
                backgroundColor: Color(0xFF54D3C2),
              ),
            );
          }
        } else {
          // Error: mostrar mensaje pero NO cerrar el modal
          if (mounted && provider.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.errorMessage!),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
            // El loop continúa, el modal se volverá a mostrar con los datos
          } else {
            shouldClose = true;
          }
        }
      }
    }
  }

  // Muestra el diálogo para crear un nuevo ShoppingItem
  Future<void> _createShoppingItem() async {
    final result = await showModalBottomSheet<ShoppingItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateShoppingDialog(),
    );

    if (result != null && mounted) {
      final provider = context.read<ShoppingProvider>();
      final success = await provider.createShoppingItem(result);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item agregado exitosamente'),
              backgroundColor: Color(0xFF54D3C2),
            ),
          );
        } else if (provider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentTitle,
              style: GoogleFonts.inter(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            Text(
              '$_currentItemCount elementos',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF54D3C2),
          labelColor: const Color(0xFF54D3C2),
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Comidas'),
            Tab(text: 'Lista de Compras'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          // Tab 1: Lista de comidas con cards personalizadas
          MealListView(),
          // Tab 2: Lista de compras con cards personalizadas
          ShoppingListView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF54D3C2),
        foregroundColor: Colors.white,
        onPressed: _onFabPressed,
        child: const Icon(Icons.add),
      ),
    );
  }
}
