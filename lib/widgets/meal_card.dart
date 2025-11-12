import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../models/meal_day.dart';

// Card personalizada para mostrar un día de comidas
class MealCard extends StatelessWidget {
  final MealDay mealDay;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MealCard({
    super.key,
    required this.mealDay,
    required this.onEdit,
    required this.onDelete,
  });

  // Formatea la fecha en español: "Sábado 15 de noviembre"
  String _formatDate(DateTime date) {
    final formatter = DateFormat('EEEE d \'de\' MMMM', 'es_ES');
    final formatted = formatter.format(date);
    // Capitalizar primera letra
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final isPast = mealDay.isPastDate;
    final isToday = _isToday(mealDay.date);

    return Slidable(
      key: ValueKey(mealDay.id),

      // Swipe a la izquierda = Editar
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.3,
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: const Color(0xFF54D3C2),
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Editar',
            autoClose: true,
          ),
        ],
      ),
      // Swipe a la derecha = Eliminar
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.3,
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Eliminar',
            autoClose: true,
          ),
        ],
      ),
      child: Opacity(
        opacity: isPast ? 0.5 : 1.0,
        child: Stack(
          children: [
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fecha formateada
                    Text(
                      _formatDate(mealDay.date),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        decoration: isPast ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Desayuno
                    _buildMealRow(
                      icon: Icons.local_cafe,
                      label: 'Desayuno',
                      value: mealDay.breakfast,
                      isPast: isPast,
                    ),
                    const SizedBox(height: 12),

                    // Comida
                    _buildMealRow(
                      icon: Icons.restaurant,
                      label: 'Comida',
                      value: mealDay.lunch,
                      isPast: isPast,
                    ),
                    const SizedBox(height: 12),

                    // Cena
                    _buildMealRow(
                      icon: Icons.fastfood,
                      label: 'Cena',
                      value: mealDay.dinner,
                      isPast: isPast,
                    ),
                  ],
                ),
              ),
            ),
            if (isToday)
              Positioned(
                top: 16,
                right: 24,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF54D3C2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'HOY',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget para mostrar cada comida (desayuno, comida, cena)
  Widget _buildMealRow({
    required IconData icon,
    required String label,
    required String? value,
    required bool isPast,
  }) {
    final hasValue = value != null && value.isNotEmpty;
    final displayText =
        hasValue ? value : 'No has asignado el $label.toLowerCase()';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: hasValue ? const Color(0xFF54D3C2) : Colors.grey[400],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            displayText,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: hasValue ? Colors.black87 : Colors.grey[500],
              fontStyle: hasValue ? FontStyle.normal : FontStyle.italic,
              decoration:
                  isPast && hasValue ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
