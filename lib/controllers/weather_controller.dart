import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/weather_api_service.dart';
import '../models/weather_model.dart';

// ============================================
// WEATHER CONTROLLER
// ============================================
class WeatherController extends GetxController {
  final _weatherService = WeatherApiService();

  // Observable variables
  var isLoading = false.obs;
  var currentWeather = Rxn<WeatherModel>();
  var currentRecommendation = Rxn<ClothingRecommendation>();
  var errorMessage = ''.obs;
  var selectedCity = 'Jakarta'.obs;
  
  // Tracking approach
  var currentApproach = ''.obs;
  var executionTime = 0.obs; // dalam milliseconds
  
  // Available cities
  final cities = ['Jakarta', 'Bandung', 'Surabaya', 'Bogor'];

  // ========================================
  // APPROACH 1: ASYNC-AWAIT
  // ========================================
  Future<void> fetchWeatherWithAsyncAwait() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      isLoading.value = true;
      errorMessage.value = '';
      currentApproach.value = 'async-await';
      
      print('\n═══════════════════════════════════════');
      print('📊 APPROACH 1: ASYNC-AWAIT');
      print('═══════════════════════════════════════');
      
      // Chained request menggunakan async-await
      final result = await _weatherService.getWeatherAndRecommendationAsync(
        selectedCity.value,
      );
      
      currentWeather.value = result['weather'];
      currentRecommendation.value = result['recommendation'];
      
      stopwatch.stop();
      executionTime.value = stopwatch.elapsedMilliseconds;
      
      print('⏱️  Execution Time: ${executionTime.value}ms');
      print('═══════════════════════════════════════\n');
      
      Get.snackbar(
        '✅ Async-Await Success',
        'Data loaded in ${executionTime.value}ms',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
    } catch (e) {
      stopwatch.stop();
      executionTime.value = stopwatch.elapsedMilliseconds;
      errorMessage.value = e.toString();
      
      print('❌ Error: $e');
      print('⏱️  Failed after: ${executionTime.value}ms');
      print('═══════════════════════════════════════\n');
      
      Get.snackbar(
        '❌ Async-Await Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========================================
  // APPROACH 2: CALLBACK CHAINING
  // ========================================
  void fetchWeatherWithCallback() {
    final stopwatch = Stopwatch()..start();
    
    isLoading.value = true;
    errorMessage.value = '';
    currentApproach.value = 'callback';
    
    print('\n═══════════════════════════════════════');
    print('📊 APPROACH 2: CALLBACK CHAINING');
    print('═══════════════════════════════════════');
    
    // Chained request menggunakan callback (Callback Hell!)
    _weatherService.getWeatherAndRecommendationCallback(
      selectedCity.value,
      (result) {
        // Success callback
        stopwatch.stop();
        executionTime.value = stopwatch.elapsedMilliseconds;
        
        currentWeather.value = result['weather'];
        currentRecommendation.value = result['recommendation'];
        
        print('⏱️  Execution Time: ${executionTime.value}ms');
        print('═══════════════════════════════════════\n');
        
        isLoading.value = false;
        
        Get.snackbar(
          '✅ Callback Success',
          'Data loaded in ${executionTime.value}ms',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      },
      (error) {
        // Error callback
        stopwatch.stop();
        executionTime.value = stopwatch.elapsedMilliseconds;
        errorMessage.value = error;
        
        print('❌ Error: $error');
        print('⏱️  Failed after: ${executionTime.value}ms');
        print('═══════════════════════════════════════\n');
        
        isLoading.value = false;
        
        Get.snackbar(
          '❌ Callback Error',
          error,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      },
    );
  }

  // ========================================
  // COMPARISON HELPER
  // ========================================
  void compareApproaches() {
    print('\n╔═══════════════════════════════════════════════════════╗');
    print('║         COMPARISON: ASYNC-AWAIT vs CALLBACK          ║');
    print('╚═══════════════════════════════════════════════════════╝');
    print('');
    print('📌 ASYNC-AWAIT:');
    print('  ✅ Readability: HIGH (kode linear, mudah dibaca)');
    print('  ✅ Debugging: EASY (stacktrace jelas, flow mudah diikuti)');
    print('  ✅ Maintainability: HIGH (mudah dimodifikasi & extend)');
    print('  ✅ Error Handling: CLEAN (try-catch terpusat)');
    print('  ⚠️  Learning Curve: Medium (perlu memahami Future & async)');
    print('');
    print('📌 CALLBACK CHAINING:');
    print('  ❌ Readability: LOW (nested callbacks, callback hell)');
    print('  ❌ Debugging: HARD (error handling tersebar)');
    print('  ❌ Maintainability: LOW (sulit modifikasi tanpa bug)');
    print('  ⚠️  Error Handling: SCATTERED (error di banyak tempat)');
    print('  ✅ Learning Curve: Easy (konsep sederhana)');
    print('');
    print('🏆 WINNER: ASYNC-AWAIT');
    print('   Lebih maintainable, readable, dan professional!');
    print('');
    print('═══════════════════════════════════════════════════════\n');
  }

  // ========================================
  // UTILITY METHODS
  // ========================================
  void changeCity(String city) {
    selectedCity.value = city;
    // Clear previous data
    currentWeather.value = null;
    currentRecommendation.value = null;
    errorMessage.value = '';
  }

  void clearData() {
    currentWeather.value = null;
    currentRecommendation.value = null;
    errorMessage.value = '';
    executionTime.value = 0;
    currentApproach.value = '';
  }

  String getApproachColor() {
    if (currentApproach.value == 'async-await') {
      return 'green';
    } else if (currentApproach.value == 'callback') {
      return 'orange';
    }
    return 'grey';
  }

  IconData getWeatherIcon() {
    if (currentWeather.value == null) return Icons.cloud;
    
    switch (currentWeather.value!.condition.toLowerCase()) {
      case 'sunny':
        return Icons.wb_sunny;
      case 'rainy':
        return Icons.umbrella;
      case 'cloudy':
        return Icons.cloud;
      case 'hot':
        return Icons.local_fire_department;
      case 'cold':
        return Icons.ac_unit;
      default:
        return Icons.cloud;
    }
  }
}