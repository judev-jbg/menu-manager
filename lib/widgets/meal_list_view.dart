import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/meals_provider.dart';
import '../models/meal_day.dart';
import 'meal_card.dart';
import 'create_meal_dialog.dart';

// ListView personalizada para mostrar MealDays
class MealListView extends StatelessWidget {
  const MealListView({super.key});

  // Muestra el diálogo de confirmación para eliminar
  Future<void> _confirmDelete(BuildContext context, MealDay mealDay) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '¿Eliminar comida?',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar este registro?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                color: Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text(
              'Eliminar',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final provider = context.read<MealsProvider>();
      final success = await provider.deleteMealDay(mealDay.id!);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comida eliminada'),
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

  // Muestra el diálogo para editar
  Future<void> _editMealDay(BuildContext context, MealDay mealDay) async {
    // Obtener la lista de meals antes del async gap
    final existingMeals = context.read<MealsProvider>().mealDays;

    final result = await showModalBottomSheet<MealDay>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateMealDialog(
        mealDay: mealDay,
        existingMeals: existingMeals,
      ),
    );

    if (result != null && context.mounted) {
      final provider = context.read<MealsProvider>();
      final success = await provider.updateMealDay(result);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comida actualizada'),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF54D3C2),
                    ),
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

        // Lista con datos
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: mealsProvider.mealDays.length,
          itemBuilder: (context, index) {
            final mealDay = mealsProvider.mealDays[index];
            return MealCard(
              mealDay: mealDay,
              onEdit: () => _editMealDay(context, mealDay),
              onDelete: () => _confirmDelete(context, mealDay),
            );
          },
        );
      },
    );
  }
}
