import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/shopping_item.dart';
import '../services/shopping_suggestions_service.dart';

// BottomSheet para crear o editar un ShoppingItem
class CreateShoppingDialog extends StatefulWidget {
  final ShoppingItem? item; // Si es null, es creación; si no, es edición

  const CreateShoppingDialog({super.key, this.item});

  @override
  State<CreateShoppingDialog> createState() => _CreateShoppingDialogState();
}

class _CreateShoppingDialogState extends State<CreateShoppingDialog> {
  late TextEditingController _descriptionController;
  final ShoppingSuggestionsService _suggestionsService = ShoppingSuggestionsService();

  // Estado para las sugerencias
  List<String> _suggestions = [];

  // FocusNode para detectar cuando el campo está activo
  final FocusNode _descriptionFocus = FocusNode();

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();

    // Si estamos editando, usar el valor existente
    _descriptionController = TextEditingController(
      text: widget.item?.description ?? '',
    );

    // Listener para actualizar las sugerencias
    _descriptionController.addListener(_updateSuggestions);
  }

  // Actualiza las sugerencias según el texto ingresado
  Future<void> _updateSuggestions() async {
    final query = _descriptionController.text;
    final suggestions = await _suggestionsService.searchSuggestions(query);

    if (!mounted) return;

    setState(() {
      _suggestions = suggestions;
    });
  }

  // Selecciona una sugerencia y la establece en el campo
  void _selectSuggestion(String suggestion) {
    setState(() {
      _descriptionController.text = suggestion;
      _suggestions = [];
      _descriptionFocus.unfocus();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  // Valida y guarda el ShoppingItem
  Future<void> _save() async {
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

    // Guardar la descripción en las sugerencias
    await _suggestionsService.addSuggestion(description);

    // Crear o actualizar el ShoppingItem
    final item = ShoppingItem(
      id: widget.item?.id,
      description: description,
    );

    // Retornar el ShoppingItem al llamador
    if (mounted) {
      Navigator.of(context).pop(item);
    }
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
                Column(
                  children: [
                    TextField(
                      controller: _descriptionController,
                      focusNode: _descriptionFocus,
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
                    // Dropdown de sugerencias
                    if (_suggestions.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _suggestions.length,
                          itemBuilder: (context, index) {
                            final suggestion = _suggestions[index];
                            return InkWell(
                              onTap: () => _selectSuggestion(suggestion),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: index < _suggestions.length - 1
                                          ? Colors.grey[200]!
                                          : Colors.transparent,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  suggestion,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
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
