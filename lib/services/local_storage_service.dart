import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ============================================
// LOCAL STORAGE SERVICE - SharedPreferences
// ============================================
class LocalStorageService {
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    print('✅ LocalStorageService initialized');
  }

  // Ensure prefs is initialized
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('LocalStorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // ========================================
  // USER DATA STORAGE
  // ========================================

  /// Save user login state
  static Future<bool> setLoggedIn(bool value) async {
    return await prefs.setBool('isLoggedIn', value);
  }

  /// Get user login state
  static bool isLoggedIn() {
    return prefs.getBool('isLoggedIn') ?? false;
  }

  /// Save user data
  static Future<bool> setUserData(Map<String, dynamic> userData) async {
    final jsonString = json.encode(userData);
    return await prefs.setString('userData', jsonString);
  }

  /// Get user data
  static Map<String, dynamic>? getUserData() {
    final jsonString = prefs.getString('userData');
    if (jsonString != null) {
      return json.decode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  /// Save username
  static Future<bool> setUsername(String username) async {
    return await prefs.setString('username', username);
  }

  /// Get username
  static String getUsername() {
    return prefs.getString('username') ?? '';
  }

  /// Save email
  static Future<bool> setEmail(String email) async {
    return await prefs.setString('email', email);
  }

  /// Get email
  static String getEmail() {
    return prefs.getString('email') ?? '';
  }

  /// Save user ID
  static Future<bool> setUserId(String userId) async {
    return await prefs.setString('userId', userId);
  }

  /// Get user ID
  static String getUserId() {
    return prefs.getString('userId') ?? '';
  }

  // ========================================
  // APP SETTINGS STORAGE
  // ========================================

  /// Save theme mode (dark/light)
  static Future<bool> setDarkMode(bool value) async {
    return await prefs.setBool('darkMode', value);
  }

  /// Get theme mode
  static bool isDarkMode() {
    return prefs.getBool('darkMode') ?? false;
  }

  /// Save notification enabled
  static Future<bool> setNotificationEnabled(bool value) async {
    return await prefs.setBool('notificationEnabled', value);
  }

  /// Get notification enabled
  static bool isNotificationEnabled() {
    return prefs.getBool('notificationEnabled') ?? true;
  }

  /// Save language preference
  static Future<bool> setLanguage(String lang) async {
    return await prefs.setString('language', lang);
  }

  /// Get language preference
  static String getLanguage() {
    return prefs.getString('language') ?? 'id';
  }

  // ========================================
  // API MODE STORAGE
  // ========================================

  /// Save API mode (Dio/HTTP)
  static Future<bool> setUseDio(bool value) async {
    return await prefs.setBool('useDio', value);
  }

  /// Get API mode
  static bool getUseDio() {
    return prefs.getBool('useDio') ?? false;
  }

  // ========================================
  // CACHE MANAGEMENT
  // ========================================

  /// Save cached services data
  static Future<bool> setCachedServices(List<Map<String, dynamic>> services) async {
    final jsonString = json.encode(services);
    return await prefs.setString('cachedServices', jsonString);
  }

  /// Get cached services data
  static List<Map<String, dynamic>>? getCachedServices() {
    final jsonString = prefs.getString('cachedServices');
    if (jsonString != null) {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    }
    return null;
  }

  /// Save cache timestamp
  static Future<bool> setCacheTimestamp() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return await prefs.setInt('cacheTimestamp', timestamp);
  }

  /// Get cache timestamp
  static DateTime? getCacheTimestamp() {
    final timestamp = prefs.getInt('cacheTimestamp');
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  /// Check if cache is expired (older than 1 hour)
  static bool isCacheExpired() {
    final timestamp = getCacheTimestamp();
    if (timestamp == null) return true;
    
    final difference = DateTime.now().difference(timestamp);
    return difference.inHours >= 1;
  }

  // ========================================
  // REMEMBER ME FEATURE
  // ========================================

  /// Save remember me state
  static Future<bool> setRememberMe(bool value) async {
    return await prefs.setBool('rememberMe', value);
  }

  /// Get remember me state
  static bool getRememberMe() {
    return prefs.getBool('rememberMe') ?? false;
  }

  /// Save saved credentials (for remember me)
  static Future<bool> setSavedCredentials(String email, String password) async {
    await prefs.setString('savedEmail', email);
    await prefs.setString('savedPassword', password);
    return true;
  }

  /// Get saved credentials
  static Map<String, String> getSavedCredentials() {
    return {
      'email': prefs.getString('savedEmail') ?? '',
      'password': prefs.getString('savedPassword') ?? '',
    };
  }

  // ========================================
  // CLEAR DATA
  // ========================================

  /// Clear user data (logout)
  static Future<bool> clearUserData() async {
    await prefs.remove('isLoggedIn');
    await prefs.remove('userData');
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('userId');
    print('🗑️ User data cleared');
    return true;
  }

  /// Clear cache only
  static Future<bool> clearCache() async {
    await prefs.remove('cachedServices');
    await prefs.remove('cacheTimestamp');
    print('🗑️ Cache cleared');
    return true;
  }

  /// Clear saved credentials
  static Future<bool> clearSavedCredentials() async {
    await prefs.remove('savedEmail');
    await prefs.remove('savedPassword');
    await prefs.remove('rememberMe');
    return true;
  }

  /// Clear all data
  static Future<bool> clearAll() async {
    await _prefs?.clear();
    print('🗑️ All local storage cleared');
    return true;
  }

  // ========================================
  // UTILITY METHODS
  // ========================================

  /// Print all saved keys (for debugging)
  static void printAllKeys() {
    print('\n📦 All Saved Keys in SharedPreferences:');
    print('═══════════════════════════════════════');
    final keys = prefs.getKeys();
    if (keys.isEmpty) {
      print('(No data stored)');
    } else {
      for (var key in keys) {
        print('$key: ${prefs.get(key)}');
      }
    }
    print('═══════════════════════════════════════\n');
  }

  /// Get storage size info
  static Map<String, dynamic> getStorageInfo() {
    final keys = prefs.getKeys();
    return {
      'totalKeys': keys.length,
      'isLoggedIn': isLoggedIn(),
      'username': getUsername(),
      'hasCachedData': getCachedServices() != null,
      'cacheExpired': isCacheExpired(),
    };
  }
}