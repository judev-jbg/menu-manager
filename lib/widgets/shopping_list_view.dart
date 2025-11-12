import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_provider.dart';
import '../models/shopping_item.dart';
import 'shopping_card.dart';
import 'create_shopping_dialog.dart';

// ListView personalizada para mostrar ShoppingItems
class ShoppingListView extends StatelessWidget {
  const ShoppingListView({super.key});

  // Muestra el diálogo de confirmación para eliminar
  Future<void> _confirmDelete(BuildContext context, ShoppingItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '¿Eliminar item?',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${item.description}"?',
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
      final provider = context.read<ShoppingProvider>();
      final success = await provider.deleteShoppingItem(item.id!);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item eliminado'),
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
  Future<void> _editShoppingItem(
      BuildContext context, ShoppingItem item) async {
    final result = await showModalBottomSheet<ShoppingItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateShoppingDialog(item: item),
    );

    if (result != null && context.mounted) {
      final provider = context.read<ShoppingProvider>();
      final success = await provider.updateShoppingItem(result);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item actualizado'),
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

        // Lista con datos
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: shoppingProvider.shoppingItems.length,
          itemBuilder: (context, index) {
            final item = shoppingProvider.shoppingItems[index];
            return ShoppingCard(
              item: item,
              onEdit: () => _editShoppingItem(context, item),
              onDelete: () => _confirmDelete(context, item),
            );
          },
        );
      },
    );
  }
}
