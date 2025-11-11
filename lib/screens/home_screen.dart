import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/meals_provider.dart';
import '../providers/shopping_provider.dart';

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
  void _onFabPressed() {
    if (_tabController.index == 0) {
      // TODO: Fase 4 - Mostrar diálogo para crear MealDay
      _showTemporaryMessage('Crear Comida (próxima fase)');
    } else {
      // TODO: Fase 4 - Mostrar diálogo para crear ShoppingItem
      _showTemporaryMessage('Crear Item de Compra (próxima fase)');
    }
  }

  // Mensaje temporal para la Fase 3
  void _showTemporaryMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
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
          // Tab 1: Lista de comidas (implementación temporal)
          _MealsListView(),
          // Tab 2: Lista de compras (implementación temporal)
          _ShoppingListView(),
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

// ==================== VISTA TEMPORAL DE COMIDAS ====================
class _MealsListView extends StatelessWidget {
  const _MealsListView();

  @override
  Widget build(BuildContext context) {
    return Consumer<MealsProvider>(
      builder: (context, mealsProvider, child) {
        // Estado de carga
        if (mealsProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF54D3C2),
            ),
          );
        }

        // Mensaje de error
        if (mealsProvider.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    mealsProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => mealsProvider.loadMealDays(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        // Lista vacía
        if (mealsProvider.mealDays.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay comidas registradas',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Presiona + para crear una',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          );
        }

        // Lista con datos (vista temporal simple)
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: mealsProvider.mealDays.length,
          itemBuilder: (context, index) {
            final mealDay = mealsProvider.mealDays[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Opacity(
                opacity: mealDay.isPastDate ? 0.5 : 1.0,
                child: ListTile(
                  leading: Icon(
                    Icons.calendar_today,
                    color: mealDay.isPastDate
                        ? Colors.grey
                        : const Color(0xFF54D3C2),
                  ),
                  title: Text(
                    '${mealDay.date.day}/${mealDay.date.month}/${mealDay.date.year}',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      decoration: mealDay.isPastDate
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    'D: ${mealDay.breakfast ?? "—"} | C: ${mealDay.lunch ?? "—"} | Ce: ${mealDay.dinner ?? "—"}',
                    style: GoogleFonts.inter(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ==================== VISTA TEMPORAL DE COMPRAS ====================
class _ShoppingListView extends StatelessWidget {
  const _ShoppingListView();

  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingProvider>(
      builder: (context, shoppingProvider, child) {
        // Estado de carga
        if (shoppingProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF54D3C2),
            ),
          );
        }

        // Mensaje de error
        if (shoppingProvider.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    shoppingProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => shoppingProvider.loadShoppingItems(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        // Lista vacía
        if (shoppingProvider.shoppingItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Lista de compras vacía',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Presiona + para agregar items',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          );
        }

        // Lista con datos (vista temporal simple)
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: shoppingProvider.shoppingItems.length,
          itemBuilder: (context, index) {
            final item = shoppingProvider.shoppingItems[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(
                  Icons.shopping_basket,
                  color: Color(0xFF54D3C2),
                ),
                title: Text(
                  item.description,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          },
        );
      },
    );
  }
}
