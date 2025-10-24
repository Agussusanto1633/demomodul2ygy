import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../models/service_model.dart';

/// 🌐 API Service - Dio Implementation
/// 
/// Supports both LOCAL JSON and ONLINE API modes with:
/// - Local JSON file loading from assets
/// - Online MockAPI integration with Dio
/// - Comprehensive logging with interceptors
/// - Full CRUD operations
/// - Advanced error handling
class ApiServiceDio {
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
  static const String localJsonPath = 'assets/data/sample.json';
  
  /// Request timeout duration
  static const Duration timeout = Duration(seconds: 30);
  
  /// Dio instance (singleton pattern)
  late final Dio _dio;
  
  // Singleton pattern
  static final ApiServiceDio _instance = ApiServiceDio._internal();
  factory ApiServiceDio() => _instance;
  
  // ============================================
  // 🔧 CONSTRUCTOR & INITIALIZATION
  // ============================================
  
  ApiServiceDio._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeout,
        receiveTimeout: timeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          // Accept all status codes to handle them manually
          return status != null && status < 500;
        },
      ),
    );
    
    // Add interceptor for logging
    _dio.interceptors.add(_createLoggingInterceptor());
  }

  // ============================================
  // 📊 LOGGING INTERCEPTOR
  // ============================================
  
  /// Create logging interceptor for automatic request/response logging
  Interceptor _createLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        _logSectionHeader('🚀 HTTP ${options.method} REQUEST');
        _logInfo('URL: ${options.uri}');
        if (options.data != null) {
          _logInfo('Body: ${options.data}');
        }
        print('');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        _logSectionHeader('✅ HTTP RESPONSE');
        _logInfo('Status: ${response.statusCode}');
        _logInfo('${_getStatusEmoji(response.statusCode ?? 0)} ${_getStatusMessage(response.statusCode ?? 0)}');
        if (response.data != null) {
          final dataStr = response.data.toString();
          if (dataStr.length < 200) {
            _logInfo('Data: $dataStr');
          } else {
            _logInfo('Data: ${dataStr.substring(0, 200)}... (truncated)');
          }
        }
        _logSectionFooter();
        return handler.next(response);
      },
      onError: (error, handler) {
        _logSectionHeader('❌ HTTP ERROR');
        _logError('Request failed', error.message ?? 'Unknown error');
        if (error.response != null) {
          _logInfo('Status: ${error.response?.statusCode}');
          _logInfo('Data: ${error.response?.data}');
        }
        _logSectionFooter();
        return handler.next(error);
      },
    );
  }

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
      _logSectionHeader('LOADING FROM LOCAL JSON (DIO)');
      
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
  
  /// Fetch services from online MockAPI using Dio
  Future<List<ServiceModel>> _getServicesFromAPI() async {
    try {
      // STEP 1: Send HTTP GET Request using Dio
      final response = await _dio.get('/services');

      // STEP 2: Check status code
      if (response.statusCode == 200) {
        _logSuccess('Request succeeded');
        
        // STEP 3: Parse response data (Dio automatically decodes JSON)
        _logStep('Parsing to ServiceModel');
        final List<dynamic> jsonData = response.data;
        
        final List<ServiceModel> services = jsonData
            .map((json) => ServiceModel.fromJson(json))
            .toList();
        
        _logSuccess('Successfully parsed ${services.length} services');
        
        return services;
        
      } else {
        _logError('Request failed', 'Status ${response.statusCode}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to load services: ${response.statusCode}',
        );
      }
      
    } on DioException catch (e) {
      _logError('API request', _getDioErrorMessage(e));
      throw Exception('Error fetching from API: ${_getDioErrorMessage(e)}');
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
        // Online mode: Direct API call with Dio
        _logInfo('Fetching service ID: $id from API');
        
        final response = await _dio.get('/services/$id');

        if (response.statusCode == 200) {
          _logSuccess('Service found');
          return ServiceModel.fromJson(response.data);
        } else {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            message: 'Service not found: ${response.statusCode}',
          );
        }
      }
    } on DioException catch (e) {
      _logError('Fetching service by ID', _getDioErrorMessage(e));
      throw Exception('Error fetching service: ${_getDioErrorMessage(e)}');
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
      _logSectionHeader('HTTP POST REQUEST (DIO)');
      
      // STEP 1: Convert to JSON
      _logStep('Converting to JSON');
      final jsonData = service.toJson();
      _logInfo('Body: $jsonData');
      
      // STEP 2: Send POST request using Dio
      _logStep('Sending POST request');
      final response = await _dio.post(
        '/services',
        data: jsonData,
      );

      // STEP 3: Check response
      if (response.statusCode == 201) {
        _logSuccess('Service created successfully!');
        _logSectionFooter();
        return ServiceModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to create service: ${response.statusCode}',
        );
      }
      
    } on DioException catch (e) {
      _logError('Creating service', _getDioErrorMessage(e));
      throw Exception('Error creating service: ${_getDioErrorMessage(e)}');
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
      _logSectionHeader('HTTP PUT REQUEST (DIO)');
      _logInfo('Updating service ID: $id');
      
      // STEP 1: Convert to JSON
      final jsonData = service.toJson();
      
      // STEP 2: Send PUT request using Dio
      final response = await _dio.put(
        '/services/$id',
        data: jsonData,
      );

      // STEP 3: Check response
      if (response.statusCode == 200) {
        _logSuccess('Service updated successfully!');
        _logSectionFooter();
        return ServiceModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to update service: ${response.statusCode}',
        );
      }
      
    } on DioException catch (e) {
      _logError('Updating service', _getDioErrorMessage(e));
      throw Exception('Error updating service: ${_getDioErrorMessage(e)}');
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
      _logSectionHeader('HTTP DELETE REQUEST (DIO)');
      _logInfo('Deleting service ID: $id');
      
      // Send DELETE request using Dio
      final response = await _dio.delete('/services/$id');

      // Check response
      if (response.statusCode == 200 || response.statusCode == 204) {
        _logSuccess('Service deleted successfully!');
        _logSectionFooter();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to delete service: ${response.statusCode}',
        );
      }
      
    } on DioException catch (e) {
      _logError('Deleting service', _getDioErrorMessage(e));
      throw Exception('Error deleting service: ${_getDioErrorMessage(e)}');
    } catch (e) {
      _logError('Deleting service', e);
      throw Exception('Error deleting service: $e');
    }
  }

  // ============================================
  // 🛠️ DIO ERROR HANDLING
  // ============================================
  
  /// Get user-friendly error message from DioException
  String _getDioErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout - Please check your internet connection';
      case DioExceptionType.sendTimeout:
        return 'Send timeout - Request took too long to send';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout - Server took too long to respond';
      case DioExceptionType.badResponse:
        return 'Bad response - Status: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'Connection error - Please check your internet connection';
      case DioExceptionType.badCertificate:
        return 'Bad certificate - SSL certificate validation failed';
      case DioExceptionType.unknown:
        return 'Unknown error: ${error.message}';
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
  
  /// Get Dio instance for advanced usage
  Dio get dio => _dio;
}