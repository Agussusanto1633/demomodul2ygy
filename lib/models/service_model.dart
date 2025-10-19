import 'package:flutter/material.dart';

class ServiceModel {
  final String id;
  final String name;
  final String price;
  final String description;
  final String icon;
  final String colorHex;

  ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.icon,
    required this.colorHex,
  });

  // ============================================
  // FROM JSON: Parsing dari JSON → Object
  // ============================================
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'build',
      colorHex: json['colorHex'] ?? '#2196F3',
    );
  }

  // ============================================
  // TO JSON: Convert Object → JSON
  // ============================================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'icon': icon,
      'colorHex': colorHex,
    };
  }

  // ============================================
  // HELPER METHOD: Get IconData dari string
  // ============================================
  IconData getIcon() {
    switch (icon.toLowerCase()) {
      case 'format_paint':
        return Icons.format_paint;
      case 'sports_motorsports':
        return Icons.sports_motorsports;
      case 'build':
        return Icons.build;
      case 'oil_barrel':
        return Icons.oil_barrel;
      case 'settings_suggest':
        return Icons.settings_suggest;
      case 'trip_origin':
        return Icons.trip_origin;
      case 'water_drop':
        return Icons.water_drop;
      case 'battery_charging_full':
        return Icons.battery_charging_full;
      case 'speed':
        return Icons.speed;
      case 'settings':
        return Icons.settings;
      default:
        return Icons.build;
    }
  }

  // ============================================
  // HELPER METHOD: Get Color dari hex string
  // ============================================
  Color getColor() {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  // ============================================
  // HELPER METHOD: Get background color
  // ============================================
  Color getBackgroundColor() {
    return getColor().withOpacity(0.1);
  }

  // ============================================
  // HELPER METHOD: Print untuk debugging
  // ============================================
  @override
  String toString() {
    return 'ServiceModel(id: $id, name: $name, price: $price)';
  }
}