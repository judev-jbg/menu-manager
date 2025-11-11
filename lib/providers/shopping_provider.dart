import 'package:flutter/foundation.dart';
import '../models/shopping_item.dart';
import '../database/database_helper.dart';

// Provider para gestionar el estado de la lista de compras
class ShoppingProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<ShoppingItem> _shoppingItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<ShoppingItem> get shoppingItems => _shoppingItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get itemCount => _shoppingItems.length;

  // Constructor - carga los datos iniciales
  ShoppingProvider() {
    loadShoppingItems();
  }

  // Carga todos los ShoppingItems desde la base de datos
  Future<void> loadShoppingItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _shoppingItems = await _dbHelper.getAllShoppingItems();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar la lista de compras: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crea un nuevo ShoppingItem
  Future<bool> createShoppingItem(ShoppingItem item) async {
    try {
      // Validar que el item sea válido (descripción no vacía)
      if (!item.isValid) {
        _errorMessage = 'La descripción no puede estar vacía';
        notifyListeners();
        return false;
      }

      // Crear el ShoppingItem
      await _dbHelper.createShoppingItem(item);

      // Recargar la lista
      await loadShoppingItems();

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Error al crear el item de compra: $e';
      notifyListeners();
      return false;
    }
  }

  // Actualiza un ShoppingItem existente
  Future<bool> updateShoppingItem(ShoppingItem item) async {
    try {
      // Validar que el item sea válido (descripción no vacía)
      if (!item.isValid) {
        _errorMessage = 'La descripción no puede estar vacía';
        notifyListeners();
        return false;
      }

      // Actualizar el ShoppingItem
      await _dbHelper.updateShoppingItem(item);

      // Recargar la lista
      await loadShoppingItems();

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Error al actualizar el item de compra: $e';
      notifyListeners();
      return false;
    }
  }

  // Elimina un ShoppingItem por su ID
  Future<bool> deleteShoppingItem(int id) async {
    try {
      await _dbHelper.deleteShoppingItem(id);

      // Recargar la lista
      await loadShoppingItems();

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar el item de compra: $e';
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
