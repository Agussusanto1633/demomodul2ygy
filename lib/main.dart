import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/repair_service_page.dart';

void main() {
  // Print app start
  print('\n🚀 Starting Bengkel App...\n');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Layanan Repaint',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const RepairServicePage(),
      
      // Default transitions
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}