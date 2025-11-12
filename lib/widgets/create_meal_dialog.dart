import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/meal_day.dart';

// BottomSheet para crear o editar un MealDay
class CreateMealDialog extends StatefulWidget {
  final MealDay? mealDay; // Si es null, es creación; si no, es edición

  const CreateMealDialog({super.key, this.mealDay});

  @override
  State<CreateMealDialog> createState() => _CreateMealDialogState();
}

class _CreateMealDialogState extends State<CreateMealDialog> {
  late TextEditingController _breakfastController;
  late TextEditingController _lunchController;
  late TextEditingController _dinnerController;
  late DateTime _selectedDate;
  bool _canSave = false;

  bool get _isEditing => widget.mealDay != null;

  @override
  void initState() {
    super.initState();

    // Si estamos editando, usar los valores existentes
    if (_isEditing) {
      _selectedDate = widget.mealDay!.date;
      _breakfastController =
          TextEditingController(text: widget.mealDay!.breakfast ?? '');
      _lunchController =
          TextEditingController(text: widget.mealDay!.lunch ?? '');
      _dinnerController =
          TextEditingController(text: widget.mealDay!.dinner ?? '');
      _canSave = true;
    } else {
      // Si estamos creando, usar valores por defecto
      _selectedDate = DateTime.now();
      _breakfastController = TextEditingController();
      _lunchController = TextEditingController();
      _dinnerController = TextEditingController();
    }
    _breakfastController.addListener(_validateFields);
    _lunchController.addListener(_validateFields);
    _dinnerController.addListener(_validateFields);
  }

  void _validateFields() {
    final hasContent = _breakfastController.text.trim().isNotEmpty ||
        _lunchController.text.trim().isNotEmpty ||
        _dinnerController.text.trim().isNotEmpty;

    if (_canSave != hasContent) {
      setState(() {
        _canSave = hasContent;
      });
    }
  }

  @override
  void dispose() {
    _breakfastController.removeListener(_validateFields);
    _lunchController.removeListener(_validateFields);
    _dinnerController.removeListener(_validateFields);
    _breakfastController.dispose();
    _lunchController.dispose();
    _dinnerController.dispose();
    super.dispose();
  }

  // Formatea la fecha para mostrar en el selector
  String _formatDate(DateTime date) {
    final formatter = DateFormat('EEEE d \'de\' MMMM \'de\' yyyy', 'es_ES');
    final formatted = formatter.format(date);
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  // Muestra el selector de fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF54D3C2),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Valida y guarda el MealDay
  void _save() {
    // Validar que al menos una comida esté asignada
    final breakfast = _breakfastController.text.trim();
    final lunch = _lunchController.text.trim();
    final dinner = _dinnerController.text.trim();

    if (breakfast.isEmpty && lunch.isEmpty && dinner.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes asignar al menos una comida'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Crear o actualizar el MealDay
    final mealDay = MealDay(
      id: widget.mealDay?.id,
      date: _selectedDate,
      breakfast: breakfast.isNotEmpty ? breakfast : null,
      lunch: lunch.isNotEmpty ? lunch : null,
      dinner: dinner.isNotEmpty ? dinner : null,
    );

    // Retornar el MealDay al llamador
    Navigator.of(context).pop(mealDay);
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
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                _isEditing ? 'Editar Comida' : 'Nueva Comida',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              // Selector de fecha
              InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF54D3C2),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _formatDate(_selectedDate),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Campo Desayuno
              _buildMealField(
                controller: _breakfastController,
                label: 'Desayuno',
                icon: Icons.wb_sunny,
                hint: 'Ej: Huevos con tocino',
              ),
              const SizedBox(height: 16),

              // Campo Comida
              _buildMealField(
                controller: _lunchController,
                label: 'Comida',
                icon: Icons.restaurant,
                hint: 'Ej: Pasta con pollo',
              ),
              const SizedBox(height: 16),

              // Campo Cena
              _buildMealField(
                controller: _dinnerController,
                label: 'Cena',
                icon: Icons.nightlight,
                hint: 'Ej: Ensalada César',
              ),
              const SizedBox(height: 8),

              // Nota informativa
              Text(
                'Al menos una comida debe estar asignada',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
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
                      onPressed: _canSave ? _save : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF54D3C2),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[600],
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
      ),
    );
  }

  // Widget para cada campo de comida
  Widget _buildMealField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: const Color(0xFF54D3C2),
            ),
            const SizedBox(width: 8),
            Text(
              label,
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
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
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
              borderSide: const BorderSide(color: Color(0xFF54D3C2), width: 2),
            ),
          ),
          style: GoogleFonts.inter(fontSize: 14),
        ),
      ],
    );
  }
}
