import 'package:flutter/material.dart';

// ============================================
// SERVICE MODEL - WITH SUPABASE SUPPORT
// ============================================
class ServiceModel {
  final String id;
  final String name;
  final String price;
  final String description;
  final String icon;
  final String color;
  final String? colorHex;
  final String? imageUrl;  // 🆕 NEW: URL gambar dari Supabase Storage
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.icon,
    required this.color,
    this.colorHex,
    this.imageUrl,  // 🆕 NEW
    this.createdAt,
    this.updatedAt,
  });

  // ========================================
  // FROM JSON (Supabase)
  // ========================================
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString() ?? '0',
      name: json['name']?.toString() ?? json['title']?.toString() ?? '',
      price: json['price']?.toString() ?? 'Rp 0',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'build',
      color: json['color']?.toString() ?? _hexToColorName(json['color_hex'] ?? '#2196F3'),
      colorHex: json['color_hex']?.toString(),
      imageUrl: json['image_url']?.toString(),  // 🆕 NEW: Parse image URL
      createdAt: _parseTimestamp(json['created_at']),
      updatedAt: _parseTimestamp(json['updated_at']),
    );
  }

  // ========================================
  // TO JSON (Supabase)
  // ========================================
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'icon': icon,
      'color': color,
      'color_hex': colorHex ?? _colorNameToHex(color),
      'image_url': imageUrl,  // 🆕 NEW: Include image URL
      // Don't include id in toJson (it's managed by database)
      // created_at and updated_at will be set by database
    };
  }

  // ========================================
  // TO MAP FOR UPDATE (Supabase)
  // ========================================
  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'icon': icon,
      'color': color,
      'color_hex': colorHex ?? _colorNameToHex(color),
      'image_url': imageUrl,  // 🆕 NEW: Update image URL
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // ========================================
  // COPY WITH
  // ========================================
  ServiceModel copyWith({
    String? id,
    String? name,
    String? price,
    String? description,
    String? icon,
    String? color,
    String? colorHex,
    String? imageUrl,  // 🆕 NEW
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      colorHex: colorHex ?? this.colorHex,
      imageUrl: imageUrl ?? this.imageUrl,  // 🆕 NEW
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ========================================
  // GET COLOR (Material Color)
  // ========================================
  Color getColor() {
    if (colorHex != null && colorHex!.isNotEmpty) {
      try {
        final hex = colorHex!.replaceAll('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      } catch (e) {
        // Fallback to color name
      }
    }

    // Color name mapping
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
        return Colors.blue;
    }
  }

  // ========================================
  // GET ICON (Material Icon)
  // ========================================
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

  // ========================================
  // HELPERS
  // ========================================
  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;

    if (timestamp is String) {
      return DateTime.tryParse(timestamp);
    }

    if (timestamp is DateTime) {
      return timestamp;
    }

    return null;
  }

  static String _hexToColorName(String hex) {
    hex = hex.replaceAll('#', '').toUpperCase();
    
    const Map<String, String> colorMap = {
      '2196F3': 'blue',
      '4CAF50': 'green',
      'F44336': 'red',
      'FF9800': 'orange',
      '9C27B0': 'purple',
      '009688': 'teal',
      '3F51B5': 'indigo',
      'FFC107': 'amber',
      'E91E63': 'pink',
      '00BCD4': 'cyan',
    };

    return colorMap[hex] ?? 'blue';
  }

  static String _colorNameToHex(String colorName) {
    const Map<String, String> hexMap = {
      'blue': '#2196F3',
      'green': '#4CAF50',
      'red': '#F44336',
      'orange': '#FF9800',
      'purple': '#9C27B0',
      'teal': '#009688',
      'indigo': '#3F51B5',
      'amber': '#FFC107',
      'pink': '#E91E63',
      'cyan': '#00BCD4',
    };

    return hexMap[colorName.toLowerCase()] ?? '#2196F3';
  }

  // ========================================
  // TO STRING
  // ========================================
  @override
  String toString() {
    return 'ServiceModel(id: $id, name: $name, price: $price)';
  }

  // ========================================
  // EQUALITY
  // ========================================
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}