import 'package:bengkelapp/views/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Controllers
import 'controllers/service_controller.dart';
import 'controllers/weather_controller.dart';

// Views
import 'views/login_page.dart';
import 'views/repair_service_page.dart';
import 'views/crud_test_page.dart';
import 'views/orders_page.dart';
import 'views/profile_page.dart';
import 'views/async_experiment_page.dart';

void main() {
  // Print app start
  print('\n🚀 Starting Bengkel App...\n');
  
  // Initialize Controllers
  Get.put(ServiceController());
  Get.put(WeatherController());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Katalog Layanan Bengkel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      
      // Set login sebagai halaman awal
      initialRoute: '/login',
      
      // Define all routes
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginPage(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/home',
          page: () => const RepairServicePage(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/crud-test',
          page: () => const CrudTestPage(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/orders',
          page: () => const OrdersPage(),
          transition: Transition.fade,
        ),
        GetPage(
          name: '/profile',
          page: () => const ProfilePage(),
          transition: Transition.zoom,
        ),
        GetPage(
          name: '/settings',
          page: () => const SettingsPage(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/async-experiment',
          page: () => const AsyncExperimentPage(),
          transition: Transition.rightToLeft,
        ),
      ],
      
      // Default transition
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}