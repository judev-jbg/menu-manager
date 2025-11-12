import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/shopping_item.dart';

// BottomSheet para crear o editar un ShoppingItem
class CreateShoppingDialog extends StatefulWidget {
  final ShoppingItem? item; // Si es null, es creación; si no, es edición

  const CreateShoppingDialog({super.key, this.item});

  @override
  State<CreateShoppingDialog> createState() => _CreateShoppingDialogState();
}

class _CreateShoppingDialogState extends State<CreateShoppingDialog> {
  late TextEditingController _descriptionController;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();

    // Si estamos editando, usar el valor existente
    _descriptionController = TextEditingController(
      text: widget.item?.description ?? '',
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // Valida y guarda el ShoppingItem
  void _save() {
    final description = _descriptionController.text.trim();

    // Validar que la descripción no esté vacía
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La descripción no puede estar vacía'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Crear o actualizar el ShoppingItem
    final item = ShoppingItem(
      id: widget.item?.id,
      description: description,
    );

    // Retornar el ShoppingItem al llamador
    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              _isEditing ? 'Editar Item' : 'Nuevo Item',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Campo de descripción
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_basket,
                      size: 18,
                      color: Color(0xFF54D3C2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Descripción',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Ej: Leche entera 1L',
                    hintStyle: GoogleFonts.inter(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF54D3C2), width: 2),
                    ),
                  ),
                  style: GoogleFonts.inter(fontSize: 14),
                  onSubmitted: (_) => _save(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF54D3C2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _isEditing ? 'Actualizar' : 'Crear',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
