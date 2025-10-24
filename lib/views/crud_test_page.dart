import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/service_controller.dart';
import '../models/service_model.dart';

class CrudTestPage extends StatelessWidget {
  const CrudTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceController = Get.find<ServiceController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Testing CRUD API'),
        backgroundColor: const Color(0xFF455A64),
        elevation: 0,
        actions: [
          Obx(() => Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: serviceController.useDio.value
                      ? Colors.green
                      : Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      serviceController.useDio.value
                          ? Icons.rocket_launch
                          : Icons.http,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      serviceController.useDio.value ? 'DIO' : 'HTTP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
      body: Column(
        children: [
          // ========== API TOGGLE SECTION ==========
          Obx(() => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: serviceController.useDio.value
                    ? [Colors.green.shade50, Colors.green.shade100]
                    : [Colors.blue.shade50, Colors.blue.shade100],
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // HTTP Side
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: !serviceController.useDio.value
                            ? Colors.blue
                            : Colors.transparent,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(25),
                          bottomLeft: Radius.circular(25),
                        ),
                        border: Border.all(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.http,
                            color: !serviceController.useDio.value
                                ? Colors.white
                                : Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'HTTP',
                            style: TextStyle(
                              color: !serviceController.useDio.value
                                  ? Colors.white
                                  : Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Toggle Button
                    GestureDetector(
                      onTap: () => serviceController.toggleApiMode(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        color: Colors.white,
                        child: Icon(
                          Icons.swap_horiz,
                          color: const Color(0xFF455A64),
                          size: 24,
                        ),
                      ),
                    ),

                    // Dio Side
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: serviceController.useDio.value
                            ? Colors.green
                            : Colors.transparent,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                        border: Border.all(
                          color: Colors.green,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.rocket_launch,
                            color: serviceController.useDio.value
                                ? Colors.white
                                : Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'DIO',
                            style: TextStyle(
                              color: serviceController.useDio.value
                                  ? Colors.white
                                  : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Mode Info
                Text(
                  'Tap the middle icon to switch API library',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          )),

          // CRUD Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildCrudButton(
                  context: context,
                  icon: Icons.download,
                  label: 'GET ALL - Ambil Semua Data',
                  color: Colors.blue,
                  onPressed: () => serviceController.fetchAllServices(),
                ),
                const SizedBox(height: 12),
                _buildCrudButton(
                  context: context,
                  icon: Icons.search,
                  label: 'GET BY ID - Ambil Data ID: 1',
                  color: Colors.green,
                  onPressed: () => serviceController.fetchServiceById('1'),
                ),
                const SizedBox(height: 12),
                _buildCrudButton(
                  context: context,
                  icon: Icons.add_circle,
                  label: 'POST - Tambah Data Baru',
                  color: Colors.orange,
                  onPressed: () => _showCreateDialog(context, serviceController),
                ),
                const SizedBox(height: 12),
                _buildCrudButton(
                  context: context,
                  icon: Icons.edit,
                  label: 'PUT - Update Data ID: 1',
                  color: Colors.purple,
                  onPressed: () => _showUpdateDialog(context, serviceController),
                ),
                const SizedBox(height: 12),
                _buildCrudButton(
                  context: context,
                  icon: Icons.delete,
                  label: 'DELETE - Hapus Data ID: 1',
                  color: Colors.red,
                  onPressed: () => _showDeleteConfirm(context, serviceController),
                ),
              ],
            ),
          ),

          const Divider(thickness: 2),

          // Loading Indicator
          Obx(() => serviceController.isLoading.value
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                )
              : const SizedBox.shrink()),

          // Data List
          Expanded(
            child: Obx(() {
              if (serviceController.services.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Belum ada data\nTekan "GET ALL" untuk memuat data',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: serviceController.services.length,
                itemBuilder: (context, index) {
                  final service = serviceController.services[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF455A64),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        service.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        service.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          serviceController.deleteService(service.id);
                        },
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCrudButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, ServiceController controller) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Data Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final newService = ServiceModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleController.text,
                description: descController.text,
                price: priceController.text,
                icon: 'build',
                color: 'blue',
              );
              controller.createService(newService);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, ServiceController controller) {
    final titleController = TextEditingController(text: 'Updated Title');
    final descController = TextEditingController(text: 'Updated Description');
    final priceController = TextEditingController(text: 'Rp 500.000');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Data ID: 1'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedService = ServiceModel(
                id: '1',
                title: titleController.text,
                description: descController.text,
                price: priceController.text,
                icon: 'build',
                color: 'blue',
              );
              controller.updateService('1', updatedService);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, ServiceController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin menghapus data ID: 1?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteService('1');
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}