import 'package:flutter/services.dart';

// ============================================
// ENV CONFIG SERVICE - NO EXTERNAL PACKAGE
// ============================================
class EnvConfig {
  static Map<String, String> _env = {};
  static bool _isLoaded = false;

  /// Load .env file dari assets
  static Future<void> load() async {
    if (_isLoaded) return;

    try {
      print('📄 Loading .env file...');
      
      // Load .env file dari assets
      final envString = await rootBundle.loadString('.env');
      
      // Parse .env file
      final lines = envString.split('\n');
      
      for (var line in lines) {
        line = line.trim();
        
        // Skip empty lines and comments
        if (line.isEmpty || line.startsWith('#')) continue;
        
        // Parse KEY=VALUE
        final separatorIndex = line.indexOf('=');
        if (separatorIndex == -1) continue;
        
        final key = line.substring(0, separatorIndex).trim();
        final value = line.substring(separatorIndex + 1).trim();
        
        // Remove quotes if present
        var cleanValue = value;
        if ((cleanValue.startsWith('"') && cleanValue.endsWith('"')) ||
            (cleanValue.startsWith("'") && cleanValue.endsWith("'"))) {
          cleanValue = cleanValue.substring(1, cleanValue.length - 1);
        }
        
        _env[key] = cleanValue;
      }
      
      _isLoaded = true;
      print('✅ .env file loaded successfully');
      print('📊 Loaded ${_env.length} environment variables\n');
    } catch (e) {
      print('❌ Failed to load .env file: $e');
      print('⚠️  Make sure .env exists and is added to pubspec.yaml assets\n');
      rethrow;
    }
  }

  /// Get environment variable
  static String get(String key, {String defaultValue = ''}) {
    if (!_isLoaded) {
      throw Exception('EnvConfig not loaded. Call EnvConfig.load() first.');
    }
    return _env[key] ?? defaultValue;
  }

  /// Get required environment variable (throw error if not found)
  static String getRequired(String key) {
    if (!_isLoaded) {
      throw Exception('EnvConfig not loaded. Call EnvConfig.load() first.');
    }
    
    final value = _env[key];
    if (value == null || value.isEmpty) {
      throw Exception('Required environment variable "$key" not found in .env');
    }
    
    return value;
  }

  /// Check if key exists
  static bool has(String key) {
    return _env.containsKey(key);
  }

  /// Get all environment variables (for debugging)
  static Map<String, String> getAll() {
    return Map.unmodifiable(_env);
  }

  /// Print all loaded variables (for debugging)
  static void printAll() {
    print('\n📋 All Environment Variables:');
    print('━' * 50);
    if (_env.isEmpty) {
      print('(No variables loaded)');
    } else {
      _env.forEach((key, value) {
        // Hide sensitive values
        final hiddenValue = key.contains('KEY') || key.contains('SECRET')
            ? '${value.substring(0, 10)}...[hidden]'
            : value;
        print('$key = $hiddenValue');
      });
    }
    print('━' * 50);
    print('Total: ${_env.length} variables\n');
  }

  /// Clear all loaded variables
  static void clear() {
    _env.clear();
    _isLoaded = false;
  }

  // ========================================
  // HELPER GETTERS FOR COMMON VARIABLES
  // ========================================

  /// Get Supabase URL
  static String get supabaseUrl {
    try {
      return getRequired('SUPABASE_URL');
    } catch (e) {
      throw Exception(
        'SUPABASE_URL not found in .env file.\n'
        'Please add: SUPABASE_URL=https://your-project-id.supabase.co'
      );
    }
  }

  /// Get Supabase Anon Key
  static String get supabaseAnonKey {
    try {
      return getRequired('SUPABASE_ANON_KEY');
    } catch (e) {
      throw Exception(
        'SUPABASE_ANON_KEY not found in .env file.\n'
        'Please add: SUPABASE_ANON_KEY=your-anon-key-here'
      );
    }
  }

  /// Get App Name
  static String get appName => get('APP_NAME', defaultValue: 'Corner Garage');

  /// Get App Version
  static String get appVersion => get('APP_VERSION', defaultValue: '1.0.0');

  /// Validate Supabase credentials
  static bool validateSupabaseCredentials() {
    try {
      final url = supabaseUrl;
      final key = supabaseAnonKey;

      // Check if URL is valid
      if (url.isEmpty || 
          url.contains('your-project-id') || 
          !url.startsWith('http')) {
        print('❌ Invalid SUPABASE_URL: $url');
        return false;
      }

      // Check if key is valid (JWT format starts with eyJ)
      if (key.isEmpty || 
          key.contains('your-anon-key') || 
          !key.startsWith('eyJ')) {
        print('❌ Invalid SUPABASE_ANON_KEY');
        return false;
      }

      print('✅ Supabase credentials validated');
      return true;
    } catch (e) {
      print('❌ Validation failed: $e');
      return false;
    }
  }
}