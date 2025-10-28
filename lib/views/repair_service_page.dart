import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/service_controller.dart';
import 'service_detail_page.dart';

class RepairServicePage extends StatefulWidget {
  const RepairServicePage({super.key});

  @override
  State<RepairServicePage> createState() => _RepairServicePageState();
}

class _RepairServicePageState extends State<RepairServicePage>
    with TickerProviderStateMixin {
  
  int? selectedIndex;
  double _itemSpacing = 15.0;
  
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  
  bool _isPulsing = false;
  bool _isRotating = false;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _togglePulse() {
    setState(() {
      _isPulsing = !_isPulsing;
      if (_isPulsing) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    });
  }

  void _toggleRotate() {
    setState(() {
      _isRotating = !_isRotating;
      if (_isRotating) {
        _rotateController.repeat();
      } else {
        _rotateController.stop();
        _rotateController.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final serviceController = Get.find<ServiceController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    int columns;
    if (isLandscape) {
      columns = 4;
    } else if (screenWidth >= 600) {
      columns = 3;
    } else {
      columns = 2;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF455A64),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF455A64),
        elevation: 0,
        title: const Text(
          'Corner Garage',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          // API Library indicator with tap to toggle
          Obx(() => GestureDetector(
            onTap: () => serviceController.toggleApiMode(),
            child: Container(
              margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: serviceController.useDio.value
                    ? Colors.green
                    : Colors.blue,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (serviceController.useDio.value
                            ? Colors.green
                            : Colors.blue)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          )),
          
          // CRUD Test Button
          IconButton(
            icon: const Icon(Icons.code, color: Colors.white),
            tooltip: 'Testing API CRUD',
            onPressed: () {
              Get.toNamed('/crud-test');
            },
          ),

          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () {
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(20, isLandscape ? 5 : 10, 20, isLandscape ? 5 : 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Layanan Repaint',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isLandscape ? 16 : 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!isLandscape) ...[
                            const SizedBox(height: 5),
                            Obx(() => Text(
                              'Data dari: ${serviceController.useDio.value ? "DIO Package 🚀" : "HTTP Package 🔵"}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            )),
                          ],
                        ],
                      ),
                      // Refresh Button
                      Obx(() => IconButton(
                        onPressed: serviceController.isLoading.value 
                          ? null 
                          : () => serviceController.fetchAllServices(),
                        icon: Icon(
                          serviceController.isLoading.value 
                            ? Icons.hourglass_empty 
                            : Icons.refresh,
                          color: Colors.white,
                        ),
                        tooltip: 'Refresh Data',
                      )),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: isLandscape ? 3 : 5),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isLandscape ? 15 : 25),
                    topRight: Radius.circular(isLandscape ? 15 : 25),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, isLandscape ? 8 : 15, 20, isLandscape ? 5 : 10),
                      child: Container(
                        padding: EdgeInsets.all(isLandscape ? 8 : 12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.shade300,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.control_camera, color: Colors.orange, size: isLandscape ? 16 : 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Kontrol Animasi Eksplisit',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isLandscape ? 11 : 13,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isLandscape ? 6 : 10),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _togglePulse,
                                    icon: Icon(_isPulsing ? Icons.pause : Icons.play_arrow, size: isLandscape ? 14 : 18),
                                    label: Text(
                                      _isPulsing ? 'Stop Pulse' : 'Start Pulse',
                                      style: TextStyle(fontSize: isLandscape ? 10 : 13),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isPulsing ? Colors.red : Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: isLandscape ? 6 : 10),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _toggleRotate,
                                    icon: Icon(_isRotating ? Icons.pause : Icons.rotate_right, size: isLandscape ? 14 : 18),
                                    label: Text(
                                      _isRotating ? 'Stop Rotate' : 'Start Rotate',
                                      style: TextStyle(fontSize: isLandscape ? 10 : 13),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isRotating ? Colors.red : Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: isLandscape ? 6 : 10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // GRID VIEW DENGAN DATA DARI CONTROLLER
                    Expanded(
                      child: Obx(() {
                        // Cek jika sedang loading
                        if (serviceController.isLoading.value) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: serviceController.useDio.value 
                                    ? Colors.green 
                                    : Colors.blue,
                                ),
                                const SizedBox(height: 16),
                                Obx(() => Text(
                                  serviceController.useDio.value
                                    ? 'Loading dengan DIO... 🚀'
                                    : 'Loading dengan HTTP... 🔵',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )),
                              ],
                            ),
                          );
                        }

                        // Cek jika tidak ada data
                        if (serviceController.services.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Obx(() => Text(
                                  serviceController.useDio.value
                                    ? 'Tidak ada data dari DIO 🚀'
                                    : 'Tidak ada data dari HTTP 🔵',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                )),
                                const SizedBox(height: 8),
                                Obx(() => Text(
                                  'Mode: ${serviceController.useDio.value ? "DIO Package" : "HTTP Package"}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                )),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => serviceController.fetchAllServices(),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Muat Data'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF455A64),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        // Tampilkan data dari controller
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: AnimatedBuilder(
                            animation: Listenable.merge([_pulseController, _rotateController]),
                            builder: (context, child) {
                              return GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: _itemSpacing,
                                  mainAxisSpacing: _itemSpacing,
                                  childAspectRatio: isLandscape ? 1.1 : 0.95,
                                ),
                                itemCount: serviceController.services.length,
                                itemBuilder: (context, index) {
                                  final service = serviceController.services[index];
                                  final isSelected = selectedIndex == index;

                                  return GestureDetector(
                                    onTap: () {
                                      // Convert ServiceModel to Map for ServiceDetailPage
                                      final serviceMap = {
                                        'name': service.title,
                                        'price': service.price,
                                        'description': service.description,
                                        'color': service.getBackgroundColor(),
                                        'iconColor': service.getColor(),
                                        'icon': service.getIcon(),
                                      };

                                      Get.to(
                                        () => ServiceDetailPage(
                                          service: serviceMap,
                                          heroTag: index,
                                        ),
                                        transition: Transition.rightToLeft,
                                        duration: const Duration(milliseconds: 500),
                                      );
                                    },
                                    child: Hero(
                                      tag: 'service-$index',
                                      child: Transform.scale(
                                        scale: _isPulsing ? _pulseAnimation.value : 1.0,
                                        child: Transform.rotate(
                                          angle: _isRotating ? _rotateAnimation.value * 2 * 3.14159 : 0.0,
                                          child: Material(
                                            color: Colors.transparent,
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 300),
                                              curve: Curves.easeInOut,
                                              decoration: BoxDecoration(
                                                color: isSelected ? service.getColor() : Colors.white,
                                                borderRadius: BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: isSelected
                                                        ? service.getColor().withOpacity(0.4)
                                                        : Colors.black.withOpacity(0.05),
                                                    blurRadius: isSelected ? 15 : 5,
                                                    offset: const Offset(0, 3),
                                                  )
                                                ],
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(isLandscape ? 8 : 12),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    AnimatedContainer(
                                                      duration: const Duration(milliseconds: 300),
                                                      padding: EdgeInsets.all(isSelected ? (isLandscape ? 12 : 16) : (isLandscape ? 10 : 14)),
                                                      decoration: BoxDecoration(
                                                        color: isSelected ? Colors.white : service.getBackgroundColor(),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Icon(
                                                        service.getIcon(),
                                                        size: isSelected ? (isLandscape ? 28 : 36) : (isLandscape ? 24 : 32),
                                                        color: service.getColor(),
                                                      ),
                                                    ),
                                                    SizedBox(height: isLandscape ? 6 : 10),
                                                    Text(
                                                      service.title,
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: isSelected ? (isLandscape ? 10 : 13) : (isLandscape ? 9 : 12),
                                                        fontWeight: FontWeight.bold,
                                                        color: isSelected ? Colors.white : Colors.black87,
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(height: isLandscape ? 2 : 4),
                                                    Text(
                                                      service.price,
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: isSelected ? (isLandscape ? 9 : 11) : (isLandscape ? 8 : 10),
                                                        color: isSelected
                                                            ? Colors.white.withOpacity(0.9)
                                                            : service.getColor(),
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // ============================================
      // BOTTOM NAVIGATION BAR
      // ============================================
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Home Button
                _buildNavItem(
                  icon: Icons.home,
                  label: 'Beranda',
                  isActive: true,
                  onTap: () {
                    // Already on home
                  },
                ),
                
                // Orders Button
                _buildNavItem(
                  icon: Icons.receipt_long,
                  label: 'Pesanan',
                  isActive: false,
                  onTap: () {
                    Get.toNamed('/orders');
                  },
                ),
                
                // Profile Button
                _buildNavItem(
                  icon: Icons.person,
                  label: 'Profil',
                  isActive: false,
                  onTap: () {
                    Get.toNamed('/profile');
                  },
                ),
                
                // Async Experiment Button - 🧪 NEW!
                _buildNavItem(
                  icon: Icons.science,
                  label: 'Async Test',
                  isActive: false,
                  onTap: () {
                    Get.toNamed('/async-experiment');
                  },
                ),
                
                // Settings Button - ✅ SUDAH DIPERBAIKI!
                _buildNavItem(
                  icon: Icons.settings,
                  label: 'Pengaturan',
                  isActive: false,
                  onTap: () {
                    Get.toNamed('/settings');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================
  // HELPER: Build Navigation Item
  // ============================================
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF455A64).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF455A64) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? const Color(0xFF455A64) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}