import 'package:get/get.dart';
import '../models/service_model.dart';
import '../services/api_service.dart';

class ServiceController extends GetxController {
  // ============================================
  // DEPENDENCIES
  // ============================================
  final ApiService _apiService = ApiService();

  // ============================================
  // OBSERVABLE VARIABLES
  // ============================================
  
  // List of services
  var services = <ServiceModel>[].obs;
  
  // Loading state
  var isLoading = false.obs;
  
  // Error message
  var errorMessage = ''.obs;
  
  // Selected index (untuk animasi selection)
  var selectedIndex = Rxn<int>();
  
  // Animation states
  var isPulsing = false.obs;
  var isRotating = false.obs;
  
  // Item spacing
  var itemSpacing = 15.0.obs;

  // ============================================
  // LIFECYCLE
  // ============================================
  
  @override
  void onInit() {
    super.onInit();
    print('🎮 ServiceController initialized');
    
    // Fetch services saat controller pertama kali diinit
    fetchServices();
  }

  @override
  void onClose() {
    print('🎮 ServiceController closed');
    super.onClose();
  }

  // ============================================
  // API METHODS
  // ============================================

  /// Fetch all services dari API/Local JSON
  Future<void> fetchServices() async {
    try {
      print('\n🔄 Fetching services...');
      
      // Set loading state
      isLoading(true);
      errorMessage('');
      
      // Call API service
      final result = await _apiService.getServices();
      
      // Update services list
      services.value = result;
      
      print('✅ Fetched ${services.length} services');
      
      // Check if empty
      if (services.isEmpty) {
        errorMessage('Tidak ada layanan tersedia');
      }
      
    } catch (e) {
      // Handle error
      print('❌ Error fetching services: $e');
      errorMessage('Gagal memuat data: ${e.toString()}');
      
    } finally {
      // Always stop loading
      isLoading(false);
    }
  }

  /// Refresh services (pull to refresh)
  Future<void> refreshServices() async {
    print('🔄 Refreshing services...');
    await fetchServices();
  }

  /// Get service by ID
  Future<ServiceModel?> getServiceById(String id) async {
    try {
      return await _apiService.getServiceById(id);
    } catch (e) {
      print('❌ Error getting service by ID: $e');
      Get.snackbar(
        'Error',
        'Gagal mengambil data layanan',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  /// Create new service (hanya jika pakai online API)
  Future<bool> createService(ServiceModel service) async {
    try {
      isLoading(true);
      
      final created = await _apiService.createService(service);
      
      // Add to list
      services.add(created);
      
      Get.snackbar(
        'Berhasil',
        'Layanan baru berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
      
    } catch (e) {
      print('❌ Error creating service: $e');
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
      
    } finally {
      isLoading(false);
    }
  }

  /// Update service (hanya jika pakai online API)
  Future<bool> updateService(String id, ServiceModel service) async {
    try {
      isLoading(true);
      
      final updated = await _apiService.updateService(id, service);
      
      // Update in list
      final index = services.indexWhere((s) => s.id == id);
      if (index != -1) {
        services[index] = updated;
      }
      
      Get.snackbar(
        'Berhasil',
        'Layanan berhasil diupdate',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
      
    } catch (e) {
      print('❌ Error updating service: $e');
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
      
    } finally {
      isLoading(false);
    }
  }

  /// Delete service (hanya jika pakai online API)
  Future<bool> deleteService(String id) async {
    try {
      isLoading(true);
      
      await _apiService.deleteService(id);
      
      // Remove from list
      services.removeWhere((s) => s.id == id);
      
      Get.snackbar(
        'Berhasil',
        'Layanan berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
      
    } catch (e) {
      print('❌ Error deleting service: $e');
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
      
    } finally {
      isLoading(false);
    }
  }

  // ============================================
  // UI METHODS
  // ============================================

  /// Toggle pulse animation
  void togglePulse() {
    isPulsing.value = !isPulsing.value;
    print('💫 Pulse animation: ${isPulsing.value ? "ON" : "OFF"}');
  }

  /// Toggle rotate animation
  void toggleRotate() {
    isRotating.value = !isRotating.value;
    print('🔄 Rotate animation: ${isRotating.value ? "ON" : "OFF"}');
  }

  /// Update item spacing
  void updateItemSpacing(double value) {
    itemSpacing.value = value;
  }

  /// Select service by index
  void selectService(int index) {
    if (selectedIndex.value == index) {
      selectedIndex.value = null;
      print('❌ Deselected service at index $index');
    } else {
      selectedIndex.value = index;
      print('✅ Selected service at index $index: ${services[index].name}');
    }
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get service by index (safe)
  ServiceModel? getServiceByIndex(int index) {
    if (index >= 0 && index < services.length) {
      return services[index];
    }
    return null;
  }

  /// Check if services is empty
  bool get isEmpty => services.isEmpty;

  /// Get total services count
  int get totalServices => services.length;

  /// Search services by name
  List<ServiceModel> searchServices(String query) {
    if (query.isEmpty) return services;
    
    return services.where((service) {
      return service.name.toLowerCase().contains(query.toLowerCase()) ||
             service.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Filter services by price range
  List<ServiceModel> filterByPriceRange(double min, double max) {
    return services.where((service) {
      // Extract number from price string (e.g., "Rp 500.000/unit" → 500000)
      final priceString = service.price.replaceAll(RegExp(r'[^0-9]'), '');
      final price = double.tryParse(priceString) ?? 0;
      return price >= min && price <= max;
    }).toList();
  }
}