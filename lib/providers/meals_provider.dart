import 'package:flutter/foundation.dart';
import '../models/meal_day.dart';
import '../database/database_helper.dart';

// Provider para gestionar el estado de las comidas (MealDays)
class MealsProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<MealDay> _mealDays = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<MealDay> get mealDays => _mealDays;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get itemCount => _mealDays.length;

  // Constructor - carga los datos iniciales
  MealsProvider() {
    loadMealDays();
  }

  // Carga todos los MealDays desde la base de datos
  Future<void> loadMealDays() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _mealDays = await _dbHelper.getAllMealDays();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar las comidas: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crea un nuevo MealDay
  // Valida que no exista un MealDay para la misma fecha
  Future<bool> createMealDay(MealDay mealDay) async {
    try {
      // Validar que el MealDay sea válido (al menos una comida)
      if (!mealDay.isValid) {
        _errorMessage = 'Debe asignar al menos una comida';
        notifyListeners();
        return false;
      }

      // Verificar si ya existe un MealDay para esa fecha
      final existing = await _dbHelper.getMealDayByDate(mealDay.date);
      if (existing != null) {
        _errorMessage = 'Ya existe un registro para esta fecha';
        notifyListeners();
        return false;
      }

      // Crear el MealDay
      await _dbHelper.createMealDay(mealDay);

      // Recargar la lista
      await loadMealDays();

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Error al crear el día de comidas: $e';
      notifyListeners();
      return false;
    }
  }

  // Actualiza un MealDay existente
  Future<bool> updateMealDay(MealDay mealDay) async {
    try {
      // Validar que el MealDay sea válido (al menos una comida)
      if (!mealDay.isValid) {
        _errorMessage = 'Debe asignar al menos una comida';
        notifyListeners();
        return false;
      }

      // Actualizar el MealDay
      await _dbHelper.updateMealDay(mealDay);

      // Recargar la lista
      await loadMealDays();

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Error al actualizar el día de comidas: $e';
      notifyListeners();
      return false;
    }
  }

  // Elimina un MealDay por su ID
  Future<bool> deleteMealDay(int id) async {
    try {
      await _dbHelper.deleteMealDay(id);

      // Recargar la lista
      await loadMealDays();

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar el día de comidas: $e';
      notifyListeners();
      return false;
    }
  }

  // Limpia el mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
