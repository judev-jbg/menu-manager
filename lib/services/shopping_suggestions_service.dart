import 'package:shared_preferences/shared_preferences.dart';

// Servicio para gestionar las sugerencias de items de compras
class ShoppingSuggestionsService {
  static const String _storageKey = 'shopping_suggestions';

  // Singleton
  static final ShoppingSuggestionsService _instance = ShoppingSuggestionsService._internal();
  factory ShoppingSuggestionsService() => _instance;
  ShoppingSuggestionsService._internal();

  // Obtiene todas las sugerencias almacenadas
  Future<Set<String>> getSuggestions() async {
    final prefs = await SharedPreferences.getInstance();
    final suggestions = prefs.getStringList(_storageKey) ?? [];
    return suggestions.toSet();
  }

  // Agrega una nueva sugerencia
  Future<void> addSuggestion(String item) async {
    if (item.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final currentSuggestions = await getSuggestions();

    // Crear un mapa para evitar duplicados normalizados
    final normalizedMap = <String, String>{};

    // Primero, mapear las sugerencias existentes
    for (var suggestion in currentSuggestions) {
      final normalized = _normalize(suggestion);
      if (!normalizedMap.containsKey(normalized)) {
        normalizedMap[normalized] = suggestion;
      }
    }

    // Agregar el nuevo item si no existe una versión normalizada
    final trimmedItem = item.trim();
    final normalized = _normalize(trimmedItem);

    if (!normalizedMap.containsKey(normalized)) {
      normalizedMap[normalized] = trimmedItem;
    }

    await prefs.setStringList(_storageKey, normalizedMap.values.toList());
  }

  // Busca sugerencias que coincidan con el query (búsqueda flexible)
  Future<List<String>> searchSuggestions(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final allSuggestions = await getSuggestions();
    final normalizedQuery = _normalize(query);

    // Filtrar sugerencias que contengan el query normalizado
    final matches = allSuggestions.where((suggestion) {
      final normalizedSuggestion = _normalize(suggestion);
      return normalizedSuggestion.contains(normalizedQuery);
    }).toList();

    // Ordenar por relevancia: primero las que empiezan con el query
    matches.sort((a, b) {
      final aNormalized = _normalize(a);
      final bNormalized = _normalize(b);
      final aStarts = aNormalized.startsWith(normalizedQuery);
      final bStarts = bNormalized.startsWith(normalizedQuery);

      if (aStarts && !bStarts) return -1;
      if (!aStarts && bStarts) return 1;
      return a.compareTo(b);
    });

    return matches;
  }

  // Normaliza texto: elimina tildes, signos de puntuación, convierte a minúsculas
  String _normalize(String text) {
    const withDiacritics = 'áéíóúÁÉÍÓÚñÑ';
    const withoutDiacritics = 'aeiouAEIOUnN';

    String normalized = text.toLowerCase();

    // Eliminar tildes
    for (int i = 0; i < withDiacritics.length; i++) {
      normalized = normalized.replaceAll(
        withDiacritics[i],
        withoutDiacritics[i],
      );
    }

    // Eliminar signos de puntuación y caracteres especiales
    normalized = normalized.replaceAll(RegExp(r'[^\w\s]'), '');

    // Eliminar espacios extra
    normalized = normalized.trim().replaceAll(RegExp(r'\s+'), ' ');

    return normalized;
  }

  // Limpia todas las sugerencias (útil para testing o reset)
  Future<void> clearSuggestions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
