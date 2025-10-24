import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/service_model.dart';

/// 🌐 API Service - Ultra Clean Implementation
/// 
/// Supports both LOCAL JSON and ONLINE API modes with:
/// - Local JSON file loading from assets
/// - Online MockAPI integration
/// - Comprehensive logging
/// - Full CRUD operations
/// - Clean error handling
class ApiService {
  // ============================================
  // 📌 CONFIGURATION
  // ============================================
  
  /// Base URL for your MockAPI (change this to your actual URL)
  static const String baseUrl = 'https://68f892d7deff18f212b691d7.mockapi.io/api/v1';
  
  /// Mode Selection: 'local' or 'online'
  /// - 'local': Load data from assets/data/sample.json
  /// - 'online': Fetch data from MockAPI
  static const String mode = 'online';
  
  /// Path to local JSON file in assets
  static const String localJsonPath = 'asset/data/sample.json';
  
  /// Request timeout duration
  static const Duration timeout = Duration(seconds: 30);
  
  /// Default headers for all HTTP requests
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ============================================
  // 🔍 GET ALL SERVICES
  // ============================================
  
  /// Fetch all services (auto-select local or online based on mode)
  Future<List<ServiceModel>> getServices() async {
    try {
      return mode == 'local' 
          ? await _getServicesFromLocal() 
          : await _getServicesFromAPI();
    } catch (e) {
      _logError('getServices', e);
      throw Exception('Error fetching services: $e');
    }
  }

  // ============================================
  // 📂 GET FROM LOCAL JSON
  // ============================================
  
  /// Load services from local JSON file in assets
  Future<List<ServiceModel>> _getServicesFromLocal() async {
    try {
      _logSectionHeader('LOADING FROM LOCAL JSON');
      
      // STEP 1: Load JSON file from assets
      _logStep('Loading file', localJsonPath);
      final String jsonString = await rootBundle.loadString(localJsonPath);
      _logSuccess('File loaded successfully');
      
      // STEP 2: Decode JSON String → List<dynamic>
      _logStep('Decoding JSON');
      final List<dynamic> jsonData = json.decode(jsonString);
      _logSuccess('Decoded ${jsonData.length} items');
      
      // STEP 3: Parse List<dynamic> → List<ServiceModel>
      _logStep('Parsing to ServiceModel');
      final List<ServiceModel> services = jsonData
          .map((json) => ServiceModel.fromJson(json))
          .toList();
      
      _logSuccess('Successfully parsed ${services.length} services');
      _logSectionFooter();
      
      return services;
      
    } catch (e) {
      _logError('Loading from local JSON', e);
      throw Exception('Error loading local data: $e');
    }
  }

  // ============================================
  // 🌐 GET FROM ONLINE API
  // ============================================
  
  /// Fetch services from online MockAPI
  Future<List<ServiceModel>> _getServicesFromAPI() async {
    try {
      // ✅ FIX: Langsung pakai baseUrl tanpa tambahan '/services'
      final url = '$baseUrl/service';
      
      _logSectionHeader('HTTP GET REQUEST');
      _logStep('Sending request to', url);
      
      // STEP 1: Send HTTP GET Request
      final response = await http
          .get(
            Uri.parse(url),
            headers: _headers,
          )
          .timeout(timeout);

      // STEP 2: Log response status
      _logResponse(response);
      
      // STEP 3: Check status code
      if (response.statusCode == 200) {
        _logSuccess('Request succeeded');
        
        // STEP 4: Decode JSON
        _logStep('Decoding JSON');
        final List<dynamic> jsonData = json.decode(response.body);
        _logSuccess('Decoded ${jsonData.length} items');
        
        // STEP 5: Parse to ServiceModel
        _logStep('Parsing to ServiceModel');
        final List<ServiceModel> services = jsonData
            .map((json) => ServiceModel.fromJson(json))
            .toList();
        
        _logSuccess('Successfully parsed ${services.length} services');
        _logSectionFooter();
        
        return services;
        
      } else {
        _logError('Request failed', 'Status ${response.statusCode}');
        throw Exception('Failed to load services: ${response.statusCode}');
      }
      
    } catch (e) {
      _logError('API request', e);
      throw Exception('Error fetching from API: $e');
    }
  }

  // ============================================
  // 🔍 GET SERVICE BY ID
  // ============================================
  
  /// Fetch a single service by ID
  Future<ServiceModel> getServiceById(String id) async {
    try {
      if (mode == 'local') {
        // Local mode: Load all and filter by ID
        _logInfo('Fetching service ID: $id from local');
        final services = await _getServicesFromLocal();
        return services.firstWhere(
          (service) => service.id == id,
          orElse: () => throw Exception('Service not found with ID: $id'),
        );
        
      } else {
        // Online mode: Direct API call
        // ✅ FIX: Langsung pakai baseUrl
        final url = '$baseUrl/service/$id';
        _logInfo('Fetching service ID: $id from API');
        
        final response = await http
            .get(
              Uri.parse(url),
              headers: _headers,
            )
            .timeout(timeout);

        if (response.statusCode == 200) {
          _logSuccess('Service found');
          return ServiceModel.fromJson(json.decode(response.body));
        } else {
          throw Exception('Service not found: ${response.statusCode}');
        }
      }
    } catch (e) {
      _logError('Fetching service by ID', e);
      throw Exception('Error fetching service: $e');
    }
  }

  // ============================================
  // ➕ CREATE SERVICE (POST)
  // ============================================
  
  /// Create a new service (only works in online mode)
  Future<ServiceModel> createService(ServiceModel service) async {
    if (mode == 'local') {
      throw Exception('Cannot create service in local mode. Switch to online mode.');
    }

    try {
      _logSectionHeader('HTTP POST REQUEST');
      
      // STEP 1: Convert to JSON
      _logStep('Converting to JSON');
      final jsonBody = json.encode(service.toJson());
      _logInfo('Body: $jsonBody');
      
      // STEP 2: Send POST request
      _logStep('Sending POST request');
      // ✅ FIX: Langsung pakai baseUrl
      final response = await http
          .post(
            Uri.parse('$baseUrl/service'),
            headers: _headers,
            body: jsonBody,
          )
          .timeout(timeout);

      // STEP 3: Check response
      _logResponse(response);
      
      if (response.statusCode == 201) {
        _logSuccess('Service created successfully!');
        _logSectionFooter();
        return ServiceModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create service: ${response.statusCode}');
      }
      
    } catch (e) {
      _logError('Creating service', e);
      throw Exception('Error creating service: $e');
    }
  }

  // ============================================
  // ✏️ UPDATE SERVICE (PUT)
  // ============================================
  
  /// Update an existing service (only works in online mode)
  Future<ServiceModel> updateService(String id, ServiceModel service) async {
    if (mode == 'local') {
      throw Exception('Cannot update service in local mode. Switch to online mode.');
    }

    try {
      _logSectionHeader('HTTP PUT REQUEST');
      _logInfo('Updating service ID: $id');
      
      // STEP 1: Convert to JSON
      final jsonBody = json.encode(service.toJson());
      
      // STEP 2: Send PUT request
      // ✅ FIX: Langsung pakai baseUrl
      final response = await http
          .put(
            Uri.parse('$baseUrl/service/$id'),
            headers: _headers,
            body: jsonBody,
          )
          .timeout(timeout);

      // STEP 3: Check response
      _logResponse(response);
      
      if (response.statusCode == 200) {
        _logSuccess('Service updated successfully!');
        _logSectionFooter();
        return ServiceModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update service: ${response.statusCode}');
      }
      
    } catch (e) {
      _logError('Updating service', e);
      throw Exception('Error updating service: $e');
    }
  }

  // ============================================
  // 🗑️ DELETE SERVICE
  // ============================================
  
  /// Delete a service by ID (only works in online mode)
  Future<void> deleteService(String id) async {
    if (mode == 'local') {
      throw Exception('Cannot delete service in local mode. Switch to online mode.');
    }

    try {
      _logSectionHeader('HTTP DELETE REQUEST');
      _logInfo('Deleting service ID: $id');
      
      // Send DELETE request
      // ✅ FIX: Langsung pakai baseUrl
      final response = await http
          .delete(
            Uri.parse('$baseUrl/service/$id'),
            headers: _headers,
          )
          .timeout(timeout);

      // Check response
      _logResponse(response);
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        _logSuccess('Service deleted successfully!');
        _logSectionFooter();
      } else {
        throw Exception('Failed to delete service: ${response.statusCode}');
      }
      
    } catch (e) {
      _logError('Deleting service', e);
      throw Exception('Error deleting service: $e');
    }
  }

  // ============================================
  // 🛠️ LOGGING UTILITIES
  // ============================================
  
  /// Print section header with separator
  void _logSectionHeader(String title) {
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📌 $title');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  }
  
  /// Print section footer separator
  void _logSectionFooter() {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  }
  
  /// Print a step in progress
  void _logStep(String action, [String? detail]) {
    if (detail != null) {
      print('🔄 $action: $detail');
    } else {
      print('🔄 $action...');
    }
  }
  
  /// Print success message
  void _logSuccess(String message) {
    print('✅ $message\n');
  }
  
  /// Print info message
  void _logInfo(String message) {
    print('ℹ️  $message');
  }
  
  /// Print error message
  void _logError(String context, dynamic error) {
    print('❌ Error in $context: $error');
  }
  
  /// Log HTTP response details
  void _logResponse(http.Response response) {
    print('📊 Response received:');
    print('   Status: ${response.statusCode}');
    print('   ${_getStatusEmoji(response.statusCode)} ${_getStatusMessage(response.statusCode)}');
    
    if (response.body.isNotEmpty && response.body.length < 200) {
      print('   Body: ${response.body}');
    }
    print('');
  }
  
  /// Get emoji based on status code
  String _getStatusEmoji(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) return '✅';
    if (statusCode >= 400 && statusCode < 500) return '⚠️';
    if (statusCode >= 500) return '❌';
    return '❓';
  }
  
  /// Get human-readable status message
  String _getStatusMessage(int statusCode) {
    switch (statusCode) {
      case 200:
        return 'OK - Success';
      case 201:
        return 'Created - Resource created successfully';
      case 204:
        return 'No Content - Deleted successfully';
      case 400:
        return 'Bad Request - Invalid data';
      case 401:
        return 'Unauthorized - Authentication required';
      case 404:
        return 'Not Found - Resource not found';
      case 500:
        return 'Internal Server Error';
      default:
        return 'HTTP $statusCode';
    }
  }

  // ============================================
  // 🎯 UTILITY METHODS
  // ============================================
  
  /// Get current mode (local or online)
  static String getMode() => mode;
  
  /// Check if running in local mode
  static bool isLocalMode() => mode == 'local';
  
  /// Check if running in online mode
  static bool isOnlineMode() => mode == 'online';
  
  /// Get base URL
  static String getBaseUrl() => baseUrl;
  
  /// Get local JSON path
  static String getLocalJsonPath() => localJsonPath;
}