import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/meals_provider.dart';
import 'providers/shopping_provider.dart';

// Screens
import 'screens/home_screen.dart';

void main() {
  runApp(const MenuManagerApp());
}

class MenuManagerApp extends StatelessWidget {
  const MenuManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider para gestionar las comidas (MealDays)
        ChangeNotifierProvider(create: (_) => MealsProvider()),
        // Provider para gestionar la lista de compras
        ChangeNotifierProvider(create: (_) => ShoppingProvider()),
      ],
      child: MaterialApp(
        title: 'Menu Manager',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const HomeScreen(),
      ),
    );
  }

  // Tema personalizado de la aplicación
  ThemeData _buildTheme() {
    return ThemeData(
      // Colores principales
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      primaryColor: const Color(0xFF54D3C2),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF54D3C2),
        primary: const Color(0xFF54D3C2),
        background: const Color(0xFFF5F5F5),
      ),

      // Tema de AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: GoogleFonts.inter(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Tema de Cards
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Tema de FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF54D3C2),
        foregroundColor: Colors.white,
      ),

      // Tema de inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF54D3C2), width: 2),
        ),
      ),

      // Fuente Inter para toda la app
      textTheme: GoogleFonts.interTextTheme(),
    );
  }
}
