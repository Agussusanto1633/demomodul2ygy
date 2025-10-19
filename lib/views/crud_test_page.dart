import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/service_controller.dart';
import '../models/service_model.dart';

class CrudTestPage extends StatelessWidget {
  const CrudTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ServiceController controller = Get.find<ServiceController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test CRUD Operations'),
        backgroundColor: const Color(0xFF455A64),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ============================================
            // INFO SECTION
            // ============================================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Mode Saat Ini',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                    'Total Services: ${controller.services.length}',
                    style: const TextStyle(fontSize: 14),
                  )),
                  const SizedBox(height: 4),
                  const Text(
                    'Mode: Local JSON (READ ONLY)',
                    style: TextStyle(fontSize: 14, color: Colors.orange),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '⚠️ POST, PUT, DELETE hanya berfungsi jika mode = "online"',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ============================================
            // 1. GET ALL (READ)
            // ============================================
            _buildSectionTitle('1️⃣ GET - Read All Services'),
            const SizedBox(height: 10),
            
            ElevatedButton.icon(
              onPressed: () {
                controller.fetchServices();
                Get.snackbar(
                  'GET Request',
                  'Mengambil semua data services...',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.blue,
                  colorText: Colors.white,
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Fetch All Services (GET)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 30),

            // ============================================
            // 2. POST (CREATE)
            // ============================================
            _buildSectionTitle('2️⃣ POST - Create New Service'),
            const SizedBox(height: 10),
            
            ElevatedButton.icon(
              onPressed: () {
                _showCreateDialog(context, controller);
              },
              icon: const Icon(Icons.add),
              label: const Text('Create New Service (POST)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 30),

            // ============================================
            // 3. PUT (UPDATE)
            // ============================================
            _buildSectionTitle('3️⃣ PUT - Update Service'),
            const SizedBox(height: 10),
            
            Obx(() {
              if (controller.services.isEmpty) {
                return const Text('Tidak ada data untuk diupdate');
              }
              return ElevatedButton.icon(
                onPressed: () {
                  _showUpdateDialog(context, controller);
                },
                icon: const Icon(Icons.edit),
                label: const Text('Update First Service (PUT)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              );
            }),

            const SizedBox(height: 30),

            // ============================================
            // 4. DELETE
            // ============================================
            _buildSectionTitle('4️⃣ DELETE - Delete Service'),
            const SizedBox(height: 10),
            
            Obx(() {
              if (controller.services.isEmpty) {
                return const Text('Tidak ada data untuk dihapus');
              }
              return ElevatedButton.icon(
                onPressed: () {
                  _showDeleteDialog(context, controller);
                },
                icon: const Icon(Icons.delete),
                label: const Text('Delete Last Service (DELETE)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              );
            }),

            const SizedBox(height: 30),

            // ============================================
            // LIST SERVICES
            // ============================================
            _buildSectionTitle('📋 Current Services'),
            const SizedBox(height: 10),
            
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.services.isEmpty) {
                return const Text('Tidak ada data');
              }

              return Column(
                children: controller.services.map((service) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        service.getIcon(),
                        color: service.getColor(),
                      ),
                      title: Text(service.name),
                      subtitle: Text(service.price),
                      trailing: Text('ID: ${service.id}'),
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF455A64),
      ),
    );
  }

  // ============================================
  // DIALOG CREATE (POST)
  // ============================================
  void _showCreateDialog(BuildContext context, ServiceController controller) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Create New Service'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (e.g., Rp 100.000/unit)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                Get.snackbar('Error', 'Name tidak boleh kosong');
                return;
              }

              final newService = ServiceModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                price: priceController.text,
                description: descController.text,
                icon: 'build',
                colorHex: '#2196F3',
              );

              Get.back();
              
              final success = await controller.createService(newService);
              
              if (success) {
                Get.snackbar(
                  'Success',
                  'Service berhasil dibuat!',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  // ============================================
  // DIALOG UPDATE (PUT)
  // ============================================
  void _showUpdateDialog(BuildContext context, ServiceController controller) {
    if (controller.services.isEmpty) return;
    
    final service = controller.services.first;
    final nameController = TextEditingController(text: service.name);
    final priceController = TextEditingController(text: service.price);

    Get.dialog(
      AlertDialog(
        title: Text('Update: ${service.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedService = ServiceModel(
                id: service.id,
                name: nameController.text,
                price: priceController.text,
                description: service.description,
                icon: service.icon,
                colorHex: service.colorHex,
              );

              Get.back();
              
              final success = await controller.updateService(
                service.id,
                updatedService,
              );
              
              if (success) {
                Get.snackbar(
                  'Success',
                  'Service berhasil diupdate!',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // ============================================
  // DIALOG DELETE
  // ============================================
  void _showDeleteDialog(BuildContext context, ServiceController controller) {
    if (controller.services.isEmpty) return;
    
    final service = controller.services.last;

    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Yakin ingin menghapus "${service.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              
              final success = await controller.deleteService(service.id);
              
              if (success) {
                Get.snackbar(
                  'Success',
                  'Service berhasil dihapus!',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}