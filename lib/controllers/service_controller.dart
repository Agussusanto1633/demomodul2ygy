import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/service_model.dart';

// ============================================
// SERVICE CONTROLLER - WITH SUPABASE
// ============================================
class ServiceController extends GetxController {
  // Supabase instance
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'services';

  // Observable variables
  var isLoading = false.obs;
  var services = <ServiceModel>[].obs;
  var selectedService = Rxn<ServiceModel>();
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Auto load services on init
    fetchAllServices();
  }

  // ========================================
  // GET ALL SERVICES FROM SUPABASE
  // ========================================
  Future<void> fetchAllServices() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('🔥 [Supabase] Fetching all services...');

      // Get data from Supabase
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);

      // Convert to ServiceModel list
      final List<ServiceModel> result = (response as List)
          .map((data) {
            // Convert colorHex to color if needed
            if (data.containsKey('color_hex') && !data.containsKey('color')) {
              data['color'] = _hexToColorName(data['color_hex']);
            }
            return ServiceModel.fromJson(data);
          })
          .toList();

      services.value = result;

      print('✅ [Supabase] Loaded ${result.length} services');

      Get.snackbar(
        '✅ Success',
        'Loaded ${result.length} services from Supabase',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      print('❌ [Supabase] Error: $e');
      
      Get.snackbar(
        '❌ Error',
        'Failed to load services: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========================================
  // GET SERVICE BY ID FROM SUPABASE
  // ========================================
  Future<void> fetchServiceById(String id) async {
    try {
      isLoading.value = true;

      print('🔥 [Supabase] Fetching service ID: $id');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      final data = response;
      
      if (data.containsKey('color_hex') && !data.containsKey('color')) {
        data['color'] = _hexToColorName(data['color_hex']);
      }

      selectedService.value = ServiceModel.fromJson(data);

      print('✅ [Supabase] Service loaded: ${selectedService.value?.name}');

      Get.snackbar(
        '✅ Success',
        'Service loaded: ${selectedService.value?.name}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('❌ [Supabase] Error: $e');
      
      Get.snackbar(
        '❌ Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========================================
  // CREATE SERVICE IN SUPABASE
  // ========================================
  Future<void> createService(ServiceModel service) async {
    try {
      isLoading.value = true;

      print('🔥 [Supabase] Creating service...');

      // Prepare data
      final data = service.toJson();
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();

      // Add to Supabase
      final response = await _supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      // Create ServiceModel with new data
      final newService = ServiceModel.fromJson(response);

      // Add to local list
      services.add(newService);

      print('✅ [Supabase] Service created: ${newService.name}');

      Get.snackbar(
        '✅ Success',
        'Service created: ${newService.name}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('❌ [Supabase] Error: $e');
      
      Get.snackbar(
        '❌ Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========================================
  // UPDATE SERVICE IN SUPABASE
  // ========================================
  Future<void> updateService(String id, ServiceModel service) async {
    try {
      isLoading.value = true;

      print('🔥 [Supabase] Updating service ID: $id');

      // Prepare data
      final data = service.toJson();
      data['updated_at'] = DateTime.now().toIso8601String();

      // Update in Supabase
      await _supabase
          .from(_tableName)
          .update(data)
          .eq('id', id);

      // Update in local list
      final index = services.indexWhere((s) => s.id == id);
      if (index != -1) {
        services[index] = service.copyWith(id: id);
      }

      print('✅ [Supabase] Service updated: ${service.name}');

      Get.snackbar(
        '✅ Success',
        'Service updated: ${service.name}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('❌ [Supabase] Error: $e');
      
      Get.snackbar(
        '❌ Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========================================
  // DELETE SERVICE FROM SUPABASE
  // ========================================
  Future<void> deleteService(String id) async {
    try {
      isLoading.value = true;

      print('🔥 [Supabase] Deleting service ID: $id');

      // Find service to get image URL
      final service = services.firstWhere((s) => s.id == id);

      // Delete image from storage if exists
      if (service.imageUrl != null && service.imageUrl!.isNotEmpty) {
        await deleteImage(service.imageUrl!);
      }

      // Delete from Supabase
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);

      // Remove from local list
      services.removeWhere((service) => service.id == id);

      print('✅ [Supabase] Service deleted');

      Get.snackbar(
        '✅ Success',
        'Service deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('❌ [Supabase] Error: $e');

      Get.snackbar(
        '❌ Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========================================
  // STREAM SERVICES (REAL-TIME)
  // ========================================
  Stream<List<ServiceModel>> streamServices() {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) {
          return data.map((json) {
            if (json.containsKey('color_hex') && !json.containsKey('color')) {
              json['color'] = _hexToColorName(json['color_hex']);
            }
            return ServiceModel.fromJson(json);
          }).toList();
        });
  }

  // ========================================
  // LISTEN TO SERVICES (REAL-TIME AUTO-UPDATE)
  // ========================================
  void listenToServices() {
    print('🔥 [Supabase] Listening to services (real-time)...');
    
    streamServices().listen((result) {
      services.value = result;
      print('🔄 [Supabase] Services updated: ${result.length} items');
    }, onError: (error) {
      print('❌ [Supabase] Stream error: $error');
      errorMessage.value = error.toString();
    });
  }

  // ========================================
  // HELPER: Convert Hex to Color Name
  // ========================================
  String _hexToColorName(String hex) {
    // Remove # if present
    hex = hex.replaceAll('#', '').toUpperCase();
    
    // Map hex to color names
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

    return colorMap[hex] ?? 'blue'; // Default to blue
  }

  // ========================================
  // IMAGE PICKER
  // ========================================
  Future<File?> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        print('✅ [ImagePicker] Image selected: ${image.path}');
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('❌ [ImagePicker] Error: $e');
      Get.snackbar(
        '❌ Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  // ========================================
  // UPLOAD IMAGE TO SUPABASE STORAGE
  // ========================================
  Future<String?> uploadImage(File imageFile, String serviceName) async {
    try {
      print('🔥 [Supabase Storage] Uploading image...');

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${serviceName.replaceAll(' ', '_')}_$timestamp.jpg';
      final filePath = 'services/$fileName';

      // Upload to Supabase Storage
      await _supabase.storage
          .from('service-images')
          .upload(filePath, imageFile);

      // Get public URL
      final imageUrl = _supabase.storage
          .from('service-images')
          .getPublicUrl(filePath);

      print('✅ [Supabase Storage] Image uploaded: $imageUrl');

      Get.snackbar(
        '✅ Success',
        'Image uploaded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      return imageUrl;
    } catch (e) {
      print('❌ [Supabase Storage] Error: $e');

      Get.snackbar(
        '❌ Error',
        'Failed to upload image: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  // ========================================
  // DELETE IMAGE FROM SUPABASE STORAGE
  // ========================================
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // Find 'service-images' bucket path
      final bucketIndex = pathSegments.indexOf('service-images');
      if (bucketIndex == -1) return;

      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      print('🔥 [Supabase Storage] Deleting image: $filePath');

      await _supabase.storage
          .from('service-images')
          .remove([filePath]);

      print('✅ [Supabase Storage] Image deleted');
    } catch (e) {
      print('❌ [Supabase Storage] Error deleting image: $e');
      // Don't show error to user for delete image failures
    }
  }

  // ========================================
  // REFRESH DATA
  // ========================================
  Future<void> refresh() async {
    await fetchAllServices();
  }
}