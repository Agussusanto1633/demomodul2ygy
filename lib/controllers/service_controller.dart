import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service_http.dart';
import '../services/api_service_dio.dart';
import '../models/service_model.dart';

class ServiceController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var services = <ServiceModel>[].obs;
  var selectedService = Rxn<ServiceModel>();
  var errorMessage = ''.obs;

  // API Mode: true = Dio, false = HTTP
  var useDio = false.obs;

  // Instance untuk kedua service
  final _httpService = ApiService();
  final _dioService = ApiServiceDio();

  @override
  void onInit() {
    super.onInit();
    // Auto load services on init
    fetchAllServices();
  }

  // ========== TOGGLE API ==========
  void toggleApiMode() {
    useDio.value = !useDio.value;
    
    // Clear existing services
    services.clear();
    
    Get.snackbar(
      'API Switched',
      useDio.value ? '🟢 Using DIO Package - Loading data...' : '🔵 Using HTTP Package - Loading data...',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: useDio.value ? Colors.green : Colors.blue,
      colorText: Colors.white,
    );
    
    // Auto reload data with new API
    fetchAllServices();
  }

  // ========== GET ALL SERVICES ==========
  Future<void> fetchAllServices() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      List<ServiceModel> result;

      if (useDio.value) {
        print('🚀 Fetching with DIO package');
        result = await _dioService.getService();
      } else {
        print('🔵 Fetching with HTTP package');
        result = await _httpService.getServices();
      }

      services.value = result;

      Get.snackbar(
        'Success',
        'Loaded ${result.length} services from ${useDio.value ? "DIO 🚀" : "HTTP 🔵"}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: useDio.value ? Colors.green : Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load data: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========== GET SERVICE BY ID ==========
  Future<void> fetchServiceById(String id) async {
    try {
      isLoading.value = true;

      ServiceModel result;

      if (useDio.value) {
        result = await _dioService.getServiceById(id);
      } else {
        result = await _httpService.getServiceById(id);
      }

      selectedService.value = result;

      Get.snackbar(
        'Success',
        'Service loaded: ${result.title}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========== CREATE SERVICE ==========
  Future<void> createService(ServiceModel service) async {
    try {
      isLoading.value = true;

      ServiceModel result;

      if (useDio.value) {
        result = await _dioService.createService(service);
      } else {
        result = await _httpService.createService(service);
      }

      // Add to list
      services.add(result);

      Get.snackbar(
        'Success',
        'Service created: ${result.title}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========== UPDATE SERVICE ==========
  Future<void> updateService(String id, ServiceModel service) async {
    try {
      isLoading.value = true;

      ServiceModel result;

      if (useDio.value) {
        result = await _dioService.updateService(id, service);
      } else {
        result = await _httpService.updateService(id, service);
      }

      // Update in list
      final index = services.indexWhere((s) => s.id == id);
      if (index != -1) {
        services[index] = result;
      }

      Get.snackbar(
        'Success',
        'Service updated: ${result.title}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========== DELETE SERVICE ==========
  Future<void> deleteService(String id) async {
    try {
      isLoading.value = true;

      if (useDio.value) {
        await _dioService.deleteService(id);
      } else {
        await _httpService.deleteService(id);
      }

      // Remove from list
      services.removeWhere((service) => service.id == id);

      Get.snackbar(
        'Success',
        'Service deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
}