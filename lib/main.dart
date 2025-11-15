import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Services
import 'services/local_storage_service.dart';
import 'services/hive_service.dart';
import 'services/env_config.dart';

// Controllers
import 'controllers/auth_controller.dart';
import 'controllers/service_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/note_controller.dart';
import 'controllers/todo_controller.dart';

// Views
import 'views/login_page.dart';
import 'views/home_page.dart';
import 'views/crud_test_page.dart';
import 'views/notes_page.dart';
import 'views/todos_page.dart';
import 'views/orders_page.dart';
import 'views/profile_page.dart';
import 'views/setting_page.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  print('\n🚀 Starting Corner Garage App with Supabase...\n');

  try {
    // ========================================
    // STEP 1: LOAD .ENV FILE
    // ========================================
    print('📄 STEP 1: Loading .env file...');
    await EnvConfig.load();
    print('✅ STEP 1 COMPLETE: .env file loaded\n');
    
    // 🔍 DEBUG: Print all environment variables
    print('━' * 60);
    print('🔍 DEBUG: Environment Variables');
    print('━' * 60);
    EnvConfig.printAll();
    print('━' * 60);
    print('');

    // ========================================
    // STEP 2: GET SUPABASE CREDENTIALS
    // ========================================
    print('📄 STEP 2: Getting Supabase credentials from .env...');
    
    final url = EnvConfig.supabaseUrl;
    final key = EnvConfig.supabaseAnonKey;
    
    print('🔍 SUPABASE_URL: $url');
    print('🔍 SUPABASE_ANON_KEY (first 30 chars): ${key.length > 30 ? key.substring(0, 30) : key}...');
    print('🔍 Key length: ${key.length} characters');
    print('✅ STEP 2 COMPLETE: Credentials retrieved\n');

    // ========================================
    // STEP 3: VALIDATE CREDENTIALS
    // ========================================
    print('📄 STEP 3: Validating Supabase credentials...');
    
    // Manual validation with detailed feedback
    if (url.isEmpty || url.contains('your-project-id') || !url.startsWith('http')) {
      throw Exception(
        '❌ Invalid SUPABASE_URL!\n'
        '   Current value: $url\n'
        '   Expected: https://xxxxx.supabase.co'
      );
    }
    
    if (key.isEmpty || key.contains('your-anon-key') || !key.startsWith('eyJ')) {
      throw Exception(
        '❌ Invalid SUPABASE_ANON_KEY!\n'
        '   Current value: ${key.substring(0, 20)}...\n'
        '   Expected: JWT token starting with "eyJ"'
      );
    }
    
    print('✅ STEP 3 COMPLETE: Credentials are valid\n');

    // ========================================
    // STEP 4: INITIALIZE SUPABASE
    // ========================================
    print('📄 STEP 4: Initializing Supabase...');
    print('🔗 Connecting to: $url');
    
    await Supabase.initialize(
      url: url,
      anonKey: key,
    );

    print('✅ STEP 4 COMPLETE: Supabase initialized successfully');
    print('📍 Project URL: ${EnvConfig.supabaseUrl}');
    print('✨ Supabase client ready!\n');

  } catch (e, stackTrace) {
    print('\n');
    print('━' * 60);
    print('❌ INITIALIZATION ERROR');
    print('━' * 60);
    print('Error: $e');
    print('━' * 60);
    print('Stack Trace:');
    print(stackTrace);
    print('━' * 60);
    print('');
    
    // Show helpful error message
    print('━' * 60);
    print('⚠️  TROUBLESHOOTING GUIDE');
    print('━' * 60);
    print('');
    print('1. Check if .env file exists in project root');
    print('   Location: your_project/.env (same level as pubspec.yaml)');
    print('');
    print('2. Verify .env file content:');
    print('   SUPABASE_URL=https://xxxxx.supabase.co');
    print('   SUPABASE_ANON_KEY=eyJhbGci...');
    print('');
    print('3. Add .env to pubspec.yaml assets:');
    print('   flutter:');
    print('     assets:');
    print('       - .env');
    print('');
    print('4. Clean and rebuild:');
    print('   flutter clean');
    print('   flutter pub get');
    print('   flutter run');
    print('');
    print('5. Get credentials from:');
    print('   https://app.supabase.com');
    print('   → Your Project → Settings → API');
    print('━' * 60);
    print('');
    
    // Don't stop the app, continue with initialization
  }

  // ========================================
  // INITIALIZE LOCAL STORAGE (SharedPreferences)
  // ========================================
  print('📦 Initializing Local Storage Service...');
  await LocalStorageService.init();
  print('✅ Local Storage initialized successfully\n');

  // ========================================
  // INITIALIZE HIVE
  // ========================================
  print('📦 Initializing Hive Service...');
  await HiveService.init();
  print('✅ Hive initialized successfully\n');

  // ========================================
  // INITIALIZE CONTROLLERS
  // ========================================
  print('🎮 Initializing Controllers...');

  // Initialize ThemeController first (untuk dark mode)
  Get.put(ThemeController());
  print('✅ ThemeController initialized');

  // Initialize AuthController
  Get.put(AuthController());
  print('✅ AuthController initialized');

  // Initialize other controllers
  Get.put(ServiceController());
  print('✅ ServiceController initialized');

  Get.put(NoteController());
  print('✅ NoteController initialized');

  Get.put(TodoController());
  print('✅ TodoController initialized');

  print('\n✨ All controllers initialized successfully\n');

  // ========================================
  // CHECK LOGIN STATUS
  // ========================================
  final authController = Get.find<AuthController>();
  final bool isLoggedIn = authController.isLoggedIn.value;

  if (isLoggedIn) {
    print('👤 User is already logged in');
    print('📧 User: ${authController.currentUser.value?.email}\n');
  } else {
    print('🔓 No user logged in, redirecting to login page\n');
  }

  print('━' * 60);
  print('🎉 APP STARTUP COMPLETE!');
  print('━' * 60);
  print('');

  runApp(MyApp(initialRoute: isLoggedIn ? '/home' : '/login'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({
    super.key,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    // Get ThemeController
    final themeController = Get.find<ThemeController>();

    return Obx(() => GetMaterialApp(
      title: EnvConfig.appName,
      
      // ========================================
      // DARK MODE CONFIGURATION
      // ========================================
      theme: themeController.lightTheme,
      darkTheme: themeController.darkTheme,
      themeMode: themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,

      debugShowCheckedModeBanner: false,

      // Set initial route based on login status
      initialRoute: initialRoute,

      // Define all routes
      getPages: [
        // ========================================
        // AUTH ROUTES
        // ========================================
        GetPage(
          name: '/login',
          page: () => const LoginPage(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 300),
        ),

        // ========================================
        // MAIN ROUTES
        // ========================================
        GetPage(
          name: '/home',
          page: () => const RepairServicePage(),
          transition: Transition.cupertino,
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/crud-test',
          page: () => const CrudFirestorePage(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
        ),

        // ========================================
        // SECONDARY ROUTES
        // ========================================
        GetPage(
          name: '/orders',
          page: () => const OrdersPage(),
          transition: Transition.fade,
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/profile',
          page: () => const ProfilePage(),
          transition: Transition.zoom,
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/settings',
          page: () => const SettingsPage(),
          transition: Transition.cupertino,
          transitionDuration: const Duration(milliseconds: 300),
        ),

        // ========================================
        // NEW ROUTES - NOTES & TODOS
        // ========================================
        GetPage(
          name: '/notes',
          page: () => const NotesPage(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/todos',
          page: () => const TodosPage(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ],

      // Default transition for all routes
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),

      // Unknown route handling
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => Scaffold(
          appBar: AppBar(
            title: const Text('Page Not Found'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 20),
                const Text(
                  '404 - Page Not Found',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text('The page you are looking for does not exist.'),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Get.offAllNamed('/home'),
                  child: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}