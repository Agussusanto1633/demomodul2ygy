import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/service_controller.dart';
import '../models/service_model.dart';

// ============================================
// CRUD SUPABASE PAGE - WITH DARK MODE SUPPORT 🌙
// ============================================
class CrudFirestorePage extends StatelessWidget {
  const CrudFirestorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceController = Get.find<ServiceController>();
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final mediaQuery = MediaQuery.of(context);
    
    // ✅ DETECT DARK MODE
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // ✅ ADAPTIVE COLORS
    final appBarColor = isDark ? const Color(0xFF263238) : const Color(0xFF455A64);
    final backgroundColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5);
    final cardBackground = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? const Color(0xFFECEFF1) : Colors.black87;
    final subtitleColor = isDark ? const Color(0xFF90A4AE) : Colors.grey.shade600;
    final emptyStateColor = isDark ? const Color(0xFF78909C) : Colors.grey.shade500;
    final bottomNavBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final bottomNavSelected = isDark ? const Color(0xFF64B5F6) : const Color(0xFF455A64);
    final bottomNavUnselected = isDark ? const Color(0xFF78909C) : Colors.grey;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: appBarColor,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: bottomNavBg,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: appBarColor,
        appBar: AppBar(
          title: const Text('CRUD Supabase Testing'),
          backgroundColor: appBarColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.offNamed('/home'),
          ),
          actions: [
            // Refresh button
            Obx(() => IconButton(
                  icon: serviceController.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.refresh),
                  onPressed: () => serviceController.fetchAllServices(),
                )),
          ],
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: backgroundColor,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ========================================
              // HEADER INFO - ADAPTIVE
              // ========================================
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    isLandscape ? mediaQuery.padding.left + 16 : 16,
                    16,
                    isLandscape ? mediaQuery.padding.right + 16 : 16,
                    16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFFFF6F00), const Color(0xFFFF8F00)]
                          : [Colors.orange.shade400, Colors.yellow.shade600],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud, color: Colors.white, size: 24),
                          SizedBox(width: 12),
                          Text(
                            'Supabase PostgreSQL CRUD',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Obx(() => Text(
                            'Total Services: ${serviceController.services.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                    ],
                  ),
                ),
              ),

              // ========================================
              // SERVICES LIST - ADAPTIVE
              // ========================================
              Obx(() {
                // Loading State
                if (serviceController.isLoading.value &&
                    serviceController.services.isEmpty) {
                  return SliverFillRemaining(
                    child: Container(
                      color: backgroundColor,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: isDark ? const Color(0xFF64B5F6) : null,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading data from Supabase...',
                              style: TextStyle(color: subtitleColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                // Empty State
                if (serviceController.services.isEmpty) {
                  return SliverFillRemaining(
                    child: Container(
                      color: backgroundColor,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox,
                              size: 80,
                              color: emptyStateColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Services Found',
                              style: TextStyle(
                                fontSize: 18,
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap + to add new service',
                              style: TextStyle(
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                // Services List
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    isLandscape ? mediaQuery.padding.left + 16 : 16,
                    16,
                    isLandscape ? mediaQuery.padding.right + 16 : 16,
                    16,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final service = serviceController.services[index];
                        return _buildServiceCard(
                          context, 
                          service, 
                          serviceController,
                          isDark,
                          cardBackground,
                          textColor,
                          subtitleColor,
                        );
                      },
                      childCount: serviceController.services.length,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showCreateDialog(context, serviceController, isDark),
          backgroundColor: isDark ? const Color(0xFFFF6F00) : Colors.orange,
          icon: const Icon(Icons.add),
          label: const Text('Add Service'),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          selectedItemColor: bottomNavSelected,
          unselectedItemColor: bottomNavUnselected,
          type: BottomNavigationBarType.fixed,
          backgroundColor: bottomNavBg,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: 'CRUD',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.note),
              label: 'Notes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_box),
              label: 'Todos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                Get.offAllNamed('/home');
                break;
              case 1:
                // Already on CRUD
                break;
              case 2:
                Get.offAllNamed('/notes');
                break;
              case 3:
                Get.offAllNamed('/todos');
                break;
              case 4:
                Get.offAllNamed('/orders');
                break;
              case 5:
                Get.offAllNamed('/profile');
                break;
              case 6:
                Get.offAllNamed('/settings');
                break;
            }
          },
        ),
      ),
    );
  }

  // ========================================
  // SERVICE CARD - ADAPTIVE
  // ========================================
  Widget _buildServiceCard(
    BuildContext context,
    ServiceModel service,
    ServiceController controller,
    bool isDark,
    Color cardBackground,
    Color textColor,
    Color subtitleColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isDark ? 8 : 4,
      color: cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showDetailDialog(context, service, controller, isDark),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Image or Icon
              service.imageUrl != null && service.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        service.imageUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to icon if image fails to load
                          return Container(
                            width: 60,
                            height: 60,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  service.getColor(),
                                  service.getColor().withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: service.getColor().withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              service.getIcon(),
                              color: Colors.white,
                              size: 28,
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            service.getColor(),
                            service.getColor().withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: service.getColor().withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        service.getIcon(),
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.price,
                      style: TextStyle(
                        fontSize: 14,
                        color: service.getColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${service.id}',
                      style: TextStyle(
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: isDark ? const Color(0xFFFFB74D) : Colors.orange,
                    ),
                    onPressed: () => _showEditDialog(context, service, controller, isDark),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: isDark ? const Color(0xFFEF5350) : Colors.red,
                    ),
                    onPressed: () => _showDeleteDialog(context, service, controller, isDark),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========================================
  // CREATE DIALOG - ADAPTIVE
  // ========================================
  void _showCreateDialog(BuildContext context, ServiceController controller, bool isDark) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    String selectedIcon = 'build';
    String selectedColor = 'blue';
    File? selectedImage;

    final dialogBg = isDark ? const Color(0xFF263238) : Colors.white;
    final inputFill = isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50;
    final labelColor = isDark ? const Color(0xFF90A4AE) : Colors.grey.shade700;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: dialogBg,
          title: Row(
            children: [
              Icon(
                Icons.add_circle,
                color: isDark ? const Color(0xFF66BB6A) : Colors.green,
              ),
              const SizedBox(width: 12),
              Text(
                'Create New Service',
                style: TextStyle(
                  color: isDark ? const Color(0xFFECEFF1) : Colors.black87,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ========================================
                  // IMAGE PICKER SECTION
                  // ========================================
                  GestureDetector(
                    onTap: () async {
                      final image = await controller.pickImage();
                      if (image != null) {
                        setState(() {
                          selectedImage = image;
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: inputFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF546E7A) : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                selectedImage!,
                                width: double.infinity,
                                height: 160,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 48,
                                  color: isDark ? const Color(0xFF90A4AE) : Colors.grey.shade400,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to add image',
                                  style: TextStyle(
                                    color: labelColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Service Name *',
                    labelStyle: TextStyle(color: labelColor),
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.title,
                      color: isDark ? const Color(0xFF90A4AE) : null,
                    ),
                    filled: true,
                    fillColor: inputFill,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Price *',
                    labelStyle: TextStyle(color: labelColor),
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.attach_money,
                      color: isDark ? const Color(0xFF90A4AE) : null,
                    ),
                    hintText: 'e.g., Rp 100.000/unit',
                    hintStyle: TextStyle(
                      color: isDark ? const Color(0xFF546E7A) : Colors.grey.shade400,
                    ),
                    filled: true,
                    fillColor: inputFill,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: labelColor),
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.description,
                      color: isDark ? const Color(0xFF90A4AE) : null,
                    ),
                    filled: true,
                    fillColor: inputFill,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedIcon,
                  dropdownColor: dialogBg,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Icon',
                    labelStyle: TextStyle(color: labelColor),
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.widgets,
                      color: isDark ? const Color(0xFF90A4AE) : null,
                    ),
                    filled: true,
                    fillColor: inputFill,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'build', child: Text('Build')),
                    DropdownMenuItem(value: 'format_paint', child: Text('Paint')),
                    DropdownMenuItem(value: 'settings', child: Text('Settings')),
                    DropdownMenuItem(value: 'sports_motorsports', child: Text('Helmet')),
                    DropdownMenuItem(value: 'oil_barrel', child: Text('Oil')),
                    DropdownMenuItem(value: 'water_drop', child: Text('Water')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedIcon = value!;
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedColor,
                  dropdownColor: dialogBg,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Color',
                    labelStyle: TextStyle(color: labelColor),
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.color_lens,
                      color: isDark ? const Color(0xFF90A4AE) : null,
                    ),
                    filled: true,
                    fillColor: inputFill,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'blue', child: Text('Blue')),
                    DropdownMenuItem(value: 'green', child: Text('Green')),
                    DropdownMenuItem(value: 'red', child: Text('Red')),
                    DropdownMenuItem(value: 'orange', child: Text('Orange')),
                    DropdownMenuItem(value: 'purple', child: Text('Purple')),
                    DropdownMenuItem(value: 'teal', child: Text('Teal')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedColor = value!;
                    });
                  },
                ),
              ],
            ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? const Color(0xFF90A4AE) : Colors.grey.shade700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  Get.snackbar('Error', 'Service name is required');
                  return;
                }

                // Upload image first if selected
                String? imageUrl;
                if (selectedImage != null) {
                  imageUrl = await controller.uploadImage(
                    selectedImage!,
                    nameController.text,
                  );
                }

                final newService = ServiceModel(
                  id: '', // Supabase will generate UUID
                  name: nameController.text,
                  price: priceController.text.isEmpty
                      ? 'Rp 0'
                      : priceController.text,
                  description: descController.text.isEmpty
                      ? 'No description'
                      : descController.text,
                  icon: selectedIcon,
                  color: selectedColor,
                  imageUrl: imageUrl,
                );

                await controller.createService(newService);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF66BB6A) : Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // EDIT DIALOG - ADAPTIVE
  // ========================================
  void _showEditDialog(
    BuildContext context,
    ServiceModel service,
    ServiceController controller,
    bool isDark,
  ) {
    final nameController = TextEditingController(text: service.name);
    final priceController = TextEditingController(text: service.price);
    final descController = TextEditingController(text: service.description);
    File? selectedImage;
    String? existingImageUrl = service.imageUrl;

    final dialogBg = isDark ? const Color(0xFF263238) : Colors.white;
    final inputFill = isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50;
    final labelColor = isDark ? const Color(0xFF90A4AE) : Colors.grey.shade700;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: dialogBg,
          title: Row(
            children: [
              Icon(
                Icons.edit,
                color: isDark ? const Color(0xFFFFB74D) : Colors.orange,
              ),
              const SizedBox(width: 12),
              Text(
                'Edit Service',
                style: TextStyle(
                  color: isDark ? const Color(0xFFECEFF1) : Colors.black87,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ========================================
                  // IMAGE PICKER SECTION
                  // ========================================
                  GestureDetector(
                    onTap: () async {
                      final image = await controller.pickImage();
                      if (image != null) {
                        setState(() {
                          selectedImage = image;
                          existingImageUrl = null; // Clear existing URL when new image selected
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: inputFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF546E7A) : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: selectedImage != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    selectedImage!,
                                    width: double.infinity,
                                    height: 160,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  radius: 16,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.close, size: 16, color: Colors.white),
                                    onPressed: () {
                                      setState(() {
                                        selectedImage = null;
                                        existingImageUrl = service.imageUrl;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          )
                        : existingImageUrl != null && existingImageUrl!.isNotEmpty
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      existingImageUrl!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.broken_image,
                                              size: 48,
                                              color: isDark ? const Color(0xFF90A4AE) : Colors.grey.shade400,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Failed to load image',
                                              style: TextStyle(
                                                color: labelColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black54,
                                      radius: 16,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.close, size: 16, color: Colors.white),
                                        onPressed: () {
                                          setState(() {
                                            existingImageUrl = null;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 48,
                                    color: isDark ? const Color(0xFF90A4AE) : Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to change image',
                                    style: TextStyle(
                                      color: labelColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Service Name',
                    labelStyle: TextStyle(color: labelColor),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: inputFill,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(color: labelColor),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: inputFill,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: labelColor),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: inputFill,
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? const Color(0xFF90A4AE) : Colors.grey.shade700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Upload new image if selected
                String? imageUrl = existingImageUrl;
                if (selectedImage != null) {
                  // Delete old image if exists
                  if (service.imageUrl != null && service.imageUrl!.isNotEmpty) {
                    await controller.deleteImage(service.imageUrl!);
                  }

                  // Upload new image
                  imageUrl = await controller.uploadImage(
                    selectedImage!,
                    nameController.text,
                  );
                } else if (existingImageUrl == null && service.imageUrl != null) {
                  // User removed the image
                  await controller.deleteImage(service.imageUrl!);
                }

                final updatedService = ServiceModel(
                  id: service.id,
                  name: nameController.text,
                  price: priceController.text,
                  description: descController.text,
                  icon: service.icon,
                  color: service.color,
                  colorHex: service.colorHex,
                  imageUrl: imageUrl,  // Explicitly set imageUrl (can be null)
                  createdAt: service.createdAt,
                  updatedAt: service.updatedAt,
                );

                await controller.updateService(service.id, updatedService);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFFFFB74D) : Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // DELETE DIALOG - ADAPTIVE
  // ========================================
  void _showDeleteDialog(
    BuildContext context,
    ServiceModel service,
    ServiceController controller,
    bool isDark,
  ) {
    final dialogBg = isDark ? const Color(0xFF263238) : Colors.white;
    final textColor = isDark ? const Color(0xFFECEFF1) : Colors.black87;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg,
        title: Row(
          children: [
            Icon(
              Icons.warning, 
              color: isDark ? const Color(0xFFEF5350) : Colors.red,
            ),
            const SizedBox(width: 12),
            Text(
              'Delete Service',
              style: TextStyle(color: textColor),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${service.name}"?\n\nThis action cannot be undone!',
          style: TextStyle(color: textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? const Color(0xFF90A4AE) : Colors.grey.shade700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.deleteService(service.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFFEF5350) : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ========================================
  // DETAIL DIALOG - ADAPTIVE
  // ========================================
  void _showDetailDialog(
    BuildContext context,
    ServiceModel service,
    ServiceController controller,
    bool isDark,
  ) {
    final dialogBg = isDark ? const Color(0xFF263238) : Colors.white;
    final textColor = isDark ? const Color(0xFFECEFF1) : Colors.black87;
    final subtitleColor = isDark ? const Color(0xFF90A4AE) : Colors.grey.shade700;
    final inputFill = isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg,
        title: Row(
          children: [
            Icon(service.getIcon(), color: service.getColor()),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                service.name,
                style: TextStyle(
                  fontSize: 18,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ========================================
                // IMAGE PREVIEW
                // ========================================
                if (service.imageUrl != null && service.imageUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        service.imageUrl!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: inputFill,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? const Color(0xFF546E7A) : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 48,
                                color: isDark ? const Color(0xFF90A4AE) : Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Failed to load image',
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              _buildDetailRow('ID', service.id, textColor, subtitleColor),
              _buildDetailRow('Price', service.price, textColor, subtitleColor),
              _buildDetailRow('Description', service.description, textColor, subtitleColor),
              _buildDetailRow('Icon', service.icon, textColor, subtitleColor),
              _buildDetailRow('Color', service.color, textColor, subtitleColor),
              if (service.imageUrl != null && service.imageUrl!.isNotEmpty)
                _buildDetailRow('Image', 'Available', textColor, subtitleColor),
              if (service.createdAt != null)
                _buildDetailRow(
                  'Created',
                  _formatDate(service.createdAt!),
                  textColor,
                  subtitleColor,
                ),
              if (service.updatedAt != null)
                _buildDetailRow(
                  'Updated',
                  _formatDate(service.updatedAt!),
                  textColor,
                  subtitleColor,
                ),
            ],
          ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: isDark ? const Color(0xFF90A4AE) : Colors.grey.shade700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditDialog(context, service, controller, isDark);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF64B5F6) : Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label, 
    String value,
    Color textColor,
    Color subtitleColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: subtitleColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}