import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/service_model.dart';

class ApiService {
  // ============================================
  // KONFIGURASI
  // ============================================
  
  // Ganti dengan URL MockAPI kamu (jika pakai online API)
  static const String baseUrl = 'https://6789abcd1234567890.mockapi.io/api/v1';
  
  // Mode: 'local' atau 'online'
  static const String mode = 'local'; // GANTI KE 'online' jika pakai MockAPI
  
  // Path file JSON local
  static const String localJsonPath = 'assets/data/sample.json';

  // ============================================
  // GET: Mengambil semua services
  // ============================================
  Future<List<ServiceModel>> getServices() async {
    try {
      if (mode == 'local') {
        return await _getServicesFromLocal();
      } else {
        return await _getServicesFromAPI();
      }
    } catch (e) {
      print('❌ Error in getServices: $e');
      throw Exception('Error fetching services: $e');
    }
  }

  // ============================================
  // GET from LOCAL JSON
  // ============================================
  Future<List<ServiceModel>> _getServicesFromLocal() async {
    try {
      print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📂 LOADING FROM LOCAL JSON');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      // STEP 1: Load JSON file dari assets
      print('📄 Loading: $localJsonPath');
      final String response = await rootBundle.loadString(localJsonPath);
      print('✅ File loaded successfully\n');
      
      // STEP 2: Decode JSON String → List<dynamic>
      print('🔄 Decoding JSON...');
      final List<dynamic> data = json.decode(response);
      print('✅ Decoded: ${data.length} items\n');
      
      // STEP 3: Parse List<dynamic> → List<ServiceModel>
      print('🔄 Parsing to ServiceModel...');
      final List<ServiceModel> services = data
          .map((json) => ServiceModel.fromJson(json))
          .toList();
      
      print('✅ Successfully parsed ${services.length} services');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      return services;
      
    } catch (e) {
      print('❌ Error loading from local JSON: $e');
      throw Exception('Error loading local data: $e');
    }
  }

  // ============================================
  // GET from ONLINE API
  // ============================================
  Future<List<ServiceModel>> _getServicesFromAPI() async {
    try {
      print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🌐 HTTP GET REQUEST');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      final url = '$baseUrl/services';
      print('📡 URL: $url');
      print('⏳ Sending request...\n');
      
      // STEP 1: Send HTTP GET Request
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('📊 Response received');
      print('   Status Code: ${response.statusCode}');
      
      // STEP 2: Check status code
      if (response.statusCode == 200) {
        print('   ✅ Success!\n');
        
        // STEP 3: Decode JSON
        print('🔄 Decoding JSON...');
        List<dynamic> data = json.decode(response.body);
        print('✅ Decoded: ${data.length} items\n');
        
        // STEP 4: Parse to ServiceModel
        print('🔄 Parsing to ServiceModel...');
        List<ServiceModel> services = data
            .map((json) => ServiceModel.fromJson(json))
            .toList();
        
        print('✅ Successfully parsed ${services.length} services');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
        
        return services;
        
      } else {
        print('   ❌ Failed!');
        print('   Status: ${response.statusCode}');
        print('   Body: ${response.body}\n');
        throw Exception('Failed to load services: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Error in API request: $e\n');
      throw Exception('Error fetching from API: $e');
    }
  }

  // ============================================
  // GET by ID: Mengambil service berdasarkan ID
  // ============================================
  Future<ServiceModel> getServiceById(String id) async {
    try {
      if (mode == 'local') {
        // Dari local, ambil semua lalu filter by ID
        final services = await _getServicesFromLocal();
        return services.firstWhere(
          (service) => service.id == id,
          orElse: () => throw Exception('Service not found'),
        );
      } else {
        // Dari API
        final response = await http.get(
          Uri.parse('$baseUrl/services/$id'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          return ServiceModel.fromJson(json.decode(response.body));
        } else {
          throw Exception('Service not found: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error fetching service: $e');
    }
  }

  // ============================================
  // POST: Membuat service baru (hanya untuk online API)
  // ============================================
  Future<ServiceModel> createService(ServiceModel service) async {
    if (mode == 'local') {
      throw Exception('Cannot create service in local mode');
    }

    try {
      print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📤 HTTP POST REQUEST');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      print('🔄 Converting to JSON...');
      final jsonBody = json.encode(service.toJson());
      print('JSON: $jsonBody\n');
      
      print('📤 Sending POST request...');
      final response = await http.post(
        Uri.parse('$baseUrl/services'),
        headers: {'Content-Type': 'application/json'},
        body: jsonBody,
      );

      print('📊 Response: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        print('✅ Service created successfully!\n');
        return ServiceModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create service: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e\n');
      throw Exception('Error creating service: $e');
    }
  }

  // ============================================
  // PUT: Update service (hanya untuk online API)
  // ============================================
  Future<ServiceModel> updateService(String id, ServiceModel service) async {
    if (mode == 'local') {
      throw Exception('Cannot update service in local mode');
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/services/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(service.toJson()),
      );

      if (response.statusCode == 200) {
        return ServiceModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update service: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating service: $e');
    }
  }

  // ============================================
  // DELETE: Hapus service (hanya untuk online API)
  // ============================================
  Future<void> deleteService(String id) async {
    if (mode == 'local') {
      throw Exception('Cannot delete service in local mode');
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/services/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete service: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting service: $e');
    }
  }
}