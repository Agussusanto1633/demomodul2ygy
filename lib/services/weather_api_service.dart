import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../models/weather_model.dart';

// ============================================
// WEATHER API SERVICE - CUACA ENDPOINT
// ============================================
class WeatherApiService {
  // MockAPI base URL
  final String baseUrl = 'https://68fcdcff96f6ff19b9f6867a.mockapi.io/api/v1';
  
  // Simulasi delay untuk meniru network latency
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  // ========================================
  // APPROACH 1: ASYNC-AWAIT
  // ========================================
  
  /// Step 1: Ambil data cuaca (menggunakan async-await)
  Future<WeatherModel> getWeatherAsync(String city) async {
    try {
      print('🌤️  [ASYNC-AWAIT] Fetching weather for $city...');
      
      await _simulateNetworkDelay();
      
      // ✅ CORRECT: Resource name is 'cuaca'
      final response = await http.get(
        Uri.parse('$baseUrl/cuaca'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> weatherList = json.decode(response.body);
        
        // Cari city yang sesuai
        final cityWeather = weatherList.firstWhere(
          (w) => w['city'].toString().toLowerCase() == city.toLowerCase(),
          orElse: () => weatherList.first,
        );
        
        print('✅ [ASYNC-AWAIT] Weather data received for $city');
        return WeatherModel.fromJson(cityWeather);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [ASYNC-AWAIT] Error: $e');
      rethrow;
    }
  }

  /// Step 2: Ambil rekomendasi pakaian berdasarkan cuaca (menggunakan async-await)
  Future<ClothingRecommendation> getClothingRecommendationAsync(
    WeatherModel weather,
  ) async {
    try {
      print('👕 [ASYNC-AWAIT] Getting clothing recommendation...');
      
      await _simulateNetworkDelay();
      
      // Generate rekomendasi berdasarkan cuaca yang sudah ada
      final recommendation = _generateClothingRecommendation(weather);
      
      print('✅ [ASYNC-AWAIT] Recommendation generated');
      return ClothingRecommendation.fromJson(recommendation);
    } catch (e) {
      print('❌ [ASYNC-AWAIT] Error: $e');
      rethrow;
    }
  }

  /// Chained Request: Ambil cuaca kemudian rekomendasi pakaian
  Future<Map<String, dynamic>> getWeatherAndRecommendationAsync(
    String city,
  ) async {
    try {
      print('\n🚀 [ASYNC-AWAIT] Starting chained request...\n');
      
      // Step 1: Get weather dari MockAPI
      final weather = await getWeatherAsync(city);
      
      // Step 2: Get clothing recommendation based on weather
      final recommendation = await getClothingRecommendationAsync(weather);
      
      print('\n✨ [ASYNC-AWAIT] Chained request completed!\n');
      
      return {
        'weather': weather,
        'recommendation': recommendation,
        'approach': 'async-await',
      };
    } catch (e) {
      print('\n❌ [ASYNC-AWAIT] Chained request failed: $e\n');
      rethrow;
    }
  }

  // ========================================
  // APPROACH 2: CALLBACK CHAINING
  // ========================================
  
  /// Step 1: Ambil data cuaca (menggunakan callback)
  void getWeatherCallback(
    String city,
    Function(WeatherModel) onSuccess,
    Function(String) onError,
  ) {
    print('🌤️  [CALLBACK] Fetching weather for $city...');
    
    _simulateNetworkDelay().then((_) {
      // ✅ FIXED: Changed from /weather to /cuaca
      http.get(Uri.parse('$baseUrl/cuaca')).then((response) {
        if (response.statusCode == 200) {
          try {
            final List<dynamic> weatherList = json.decode(response.body);
            
            // Cari city yang sesuai
            final cityWeather = weatherList.firstWhere(
              (w) => w['city'].toString().toLowerCase() == city.toLowerCase(),
              orElse: () => weatherList.first,
            );
            
            final weather = WeatherModel.fromJson(cityWeather);
            
            print('✅ [CALLBACK] Weather data received');
            onSuccess(weather);
          } catch (e) {
            print('❌ [CALLBACK] Parse error: $e');
            onError('Failed to parse weather data: $e');
          }
        } else {
          print('❌ [CALLBACK] HTTP error: ${response.statusCode}');
          onError('Failed to load weather data: ${response.statusCode}');
        }
      }).catchError((error) {
        print('❌ [CALLBACK] Network error: $error');
        onError('Network error: $error');
      });
    }).catchError((error) {
      print('❌ [CALLBACK] Delay error: $error');
      onError('Delay error: $error');
    });
  }

  /// Step 2: Ambil rekomendasi pakaian (menggunakan callback)
  void getClothingRecommendationCallback(
    WeatherModel weather,
    Function(ClothingRecommendation) onSuccess,
    Function(String) onError,
  ) {
    print('👕 [CALLBACK] Getting clothing recommendation...');
    
    _simulateNetworkDelay().then((_) {
      try {
        final recommendationData = _generateClothingRecommendation(weather);
        final recommendation = ClothingRecommendation.fromJson(recommendationData);
        
        print('✅ [CALLBACK] Recommendation generated');
        onSuccess(recommendation);
      } catch (e) {
        print('❌ [CALLBACK] Parse error: $e');
        onError('Failed to generate recommendation: $e');
      }
    }).catchError((error) {
      print('❌ [CALLBACK] Delay error: $error');
      onError('Delay error: $error');
    });
  }

  /// Chained Request: Ambil cuaca kemudian rekomendasi pakaian (CALLBACK HELL!)
  void getWeatherAndRecommendationCallback(
    String city,
    Function(Map<String, dynamic>) onSuccess,
    Function(String) onError,
  ) {
    print('\n🚀 [CALLBACK] Starting chained request...\n');
    
    // Callback Hell begins here! 😱
    getWeatherCallback(
      city,
      (weather) {
        // Success callback untuk weather
        getClothingRecommendationCallback(
          weather,
          (recommendation) {
            // Success callback untuk recommendation (nested!)
            print('\n✨ [CALLBACK] Chained request completed!\n');
            
            onSuccess({
              'weather': weather,
              'recommendation': recommendation,
              'approach': 'callback',
            });
          },
          (error) {
            // Error callback untuk recommendation (nested!)
            print('\n❌ [CALLBACK] Recommendation error: $error\n');
            onError('Recommendation error: $error');
          },
        );
      },
      (error) {
        // Error callback untuk weather
        print('\n❌ [CALLBACK] Weather error: $error\n');
        onError('Weather error: $error');
      },
    );
  }

  // ========================================
  // HELPER METHODS
  // ========================================

  /// Generate rekomendasi pakaian berdasarkan cuaca
  Map<String, dynamic> _generateClothingRecommendation(WeatherModel weather) {
    String recommendation;
    List<String> items;
    String reason;

    if (weather.temperature >= 30) {
      recommendation = 'Pakaian Ringan & Sejuk';
      items = ['Kaos katun', 'Celana pendek', 'Sandal', 'Topi', 'Kacamata hitam'];
      reason = 'Cuaca sangat panas (${weather.temperature}°C)';
    } else if (weather.temperature >= 25) {
      recommendation = 'Pakaian Kasual Nyaman';
      items = ['Kaos', 'Celana jeans', 'Sepatu sneakers', 'Kacamata'];
      reason = 'Cuaca hangat (${weather.temperature}°C)';
    } else if (weather.temperature >= 20) {
      recommendation = 'Pakaian Hangat Ringan';
      items = ['Kemeja lengan panjang', 'Celana panjang', 'Jaket tipis', 'Sepatu tertutup'];
      reason = 'Cuaca sejuk (${weather.temperature}°C)';
    } else {
      recommendation = 'Pakaian Hangat Tebal';
      items = ['Sweater', 'Jaket tebal', 'Celana panjang', 'Sepatu boots', 'Syal'];
      reason = 'Cuaca dingin (${weather.temperature}°C)';
    }

    // Tambahan untuk kondisi hujan
    if (weather.condition == 'rainy') {
      items.add('Payung');
      items.add('Jas hujan');
      reason += ' dan hujan';
    }

    return {
      'recommendation': recommendation,
      'items': items,
      'reason': reason,
      'weatherCondition': weather.condition,
    };
  }
}