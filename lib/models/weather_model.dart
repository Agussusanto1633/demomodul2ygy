// ============================================
// WEATHER MODEL - SIMPLE VERSION (6 FIELDS)
// ============================================
class WeatherModel {
  final String city;
  final double temperature;
  final String condition;
  final int humidity;
  final String description;

  WeatherModel({
    required this.city,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.description,
  });

  /// Simple factory - works with 6-field schema
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      city: json['city']?.toString() ?? 'Unknown',
      temperature: _parseDouble(json['temperature']),
      condition: json['condition']?.toString().toLowerCase() ?? 'sunny',
      humidity: _parseInt(json['humidity']),
      description: json['description']?.toString() ?? 'Clear sky',
    );
  }

  /// Helper: Parse double safely
  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 25.0;
    return 25.0;
  }

  /// Helper: Parse int safely
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 60;
    return 60;
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'temperature': temperature,
      'condition': condition,
      'humidity': humidity,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'WeatherModel(city: $city, temp: ${temperature}°C, '
           'condition: $condition, humidity: $humidity%)';
  }
}

// ============================================
// CLOTHING RECOMMENDATION MODEL
// ============================================
class ClothingRecommendation {
  final String recommendation;
  final List<String> items;
  final String reason;
  final String weatherCondition;

  ClothingRecommendation({
    required this.recommendation,
    required this.items,
    required this.reason,
    required this.weatherCondition,
  });

  /// Simple factory - no complex parsing needed
  factory ClothingRecommendation.fromJson(Map<String, dynamic> json) {
    return ClothingRecommendation(
      recommendation: json['recommendation']?.toString() ?? '',
      items: _parseItems(json['items']),
      reason: json['reason']?.toString() ?? '',
      weatherCondition: json['weatherCondition']?.toString() ?? '',
    );
  }

  /// Helper: Parse items list safely
  static List<String> _parseItems(dynamic itemsData) {
    if (itemsData == null) return [];
    
    if (itemsData is List) {
      return itemsData.map((item) => item.toString()).toList();
    }
    
    if (itemsData is String) {
      // If items is comma-separated string
      return itemsData.split(',').map((s) => s.trim()).toList();
    }
    
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'recommendation': recommendation,
      'items': items,
      'reason': reason,
      'weatherCondition': weatherCondition,
    };
  }

  @override
  String toString() {
    return 'ClothingRecommendation(recommendation: $recommendation, '
           'items: ${items.length}, reason: $reason)';
  }
}