import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/local_storage_service.dart';

// ============================================
// THEME CONTROLLER - DARK MODE MANAGEMENT
// ============================================
class ThemeController extends GetxController {
  // Observable for dark mode state
  var isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
  }

  // Load theme mode from local storage
  void _loadThemeMode() {
    isDarkMode.value = LocalStorageService.isDarkMode();
    print('📱 Theme loaded: ${isDarkMode.value ? "Dark" : "Light"}');
  }

  // Toggle dark mode
  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    await LocalStorageService.setDarkMode(isDarkMode.value);
    
    // Change app theme
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    
    print('🎨 Theme changed to: ${isDarkMode.value ? "Dark" : "Light"}');
  }

  // Set dark mode
  Future<void> setDarkMode(bool value) async {
    isDarkMode.value = value;
    await LocalStorageService.setDarkMode(value);
    
    // Change app theme
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    
    print('🎨 Theme set to: ${value ? "Dark" : "Light"}');
  }

  // Get current theme data
  ThemeData get currentTheme {
    return isDarkMode.value ? darkTheme : lightTheme;
  }

  // ========================================
  // LIGHT THEME
  // ========================================
  ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: const Color(0xFF455A64),
      brightness: Brightness.light,
      useMaterial3: true,
      
      // Scaffold background
      scaffoldBackgroundColor: Colors.grey.shade50,
      
      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF455A64),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
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
          borderSide: const BorderSide(color: Color(0xFF455A64), width: 2),
        ),
      ),
      
      // Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF455A64),
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: Color(0xFF455A64),
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade300,
        thickness: 1,
      ),
      
      // List tile theme
      listTileTheme: const ListTileThemeData(
        textColor: Colors.black87,
        iconColor: Color(0xFF455A64),
      ),
    );
  }

  // ========================================
  // DARK THEME
  // ========================================
  ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: const Color(0xFF1E2127),
      brightness: Brightness.dark,
      useMaterial3: true,
      
      // Scaffold background
      scaffoldBackgroundColor: const Color(0xFF121212),
      
      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E2127),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: const Color(0xFF1E2127),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white70,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.white70,
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2D35),
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
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
      ),
      
      // Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2A2D35),
          foregroundColor: Colors.white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: Colors.white70,
      ),
      
      // Divider theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2A2D35),
        thickness: 1,
      ),
      
      // List tile theme
      listTileTheme: const ListTileThemeData(
        textColor: Colors.white70,
        iconColor: Colors.white70,
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E2127),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white38,
      ),
    );
  }
}