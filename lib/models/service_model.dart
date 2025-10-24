import 'package:flutter/material.dart';

class ServiceModel {
  final String id;
  final String title;
  final String description;
  final String price;
  final String icon;
  final String color;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.icon,
    required this.color,
  });

  // Convert JSON to Object
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString() ?? '0',
      title: json['title'] ?? json['name'] ?? '',
      description: json['description'] ?? json['body'] ?? '',
      price: json['price'] ?? 'Rp 0',
      icon: json['icon'] ?? 'build',
      color: json['color'] ?? 'blue',
    );
  }

  // Convert Object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'icon': icon,
      'color': color,
    };
  }

  // CopyWith method
  ServiceModel copyWith({
    String? id,
    String? title,
    String? description,
    String? price,
    String? icon,
    String? color,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  // ============================================
  // HELPER METHODS - Convert string to Color & IconData
  // ============================================

  /// Get Color from color string
  Color getColor() {
    switch (color.toLowerCase()) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'teal':
        return Colors.teal;
      case 'indigo':
        return Colors.indigo;
      case 'amber':
        return Colors.amber;
      case 'pink':
        return Colors.pink;
      case 'cyan':
        return Colors.cyan;
      default:
        return Colors.blue; // default color
    }
  }

  /// Get background Color (lighter shade)
  Color getBackgroundColor() {
    switch (color.toLowerCase()) {
      case 'blue':
        return Colors.blue.shade50;
      case 'green':
        return Colors.green.shade50;
      case 'red':
        return Colors.red.shade50;
      case 'orange':
        return Colors.orange.shade50;
      case 'purple':
        return Colors.purple.shade50;
      case 'teal':
        return Colors.teal.shade50;
      case 'indigo':
        return Colors.indigo.shade50;
      case 'amber':
        return Colors.amber.shade50;
      case 'pink':
        return Colors.pink.shade50;
      case 'cyan':
        return Colors.cyan.shade50;
      default:
        return Colors.blue.shade50;
    }
  }

  /// Get IconData from icon string
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
      case 'construction':
        return Icons.construction;
      case 'car_repair':
        return Icons.car_repair;
      default:
        return Icons.build; // default icon
    }
  }

  // Alias for compatibility
  String get name => title;
  String get body => description;
}