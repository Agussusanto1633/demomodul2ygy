import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/service_controller.dart';
import 'service_detail_page.dart';
import 'orders_page.dart';
import 'profile_page.dart';
import 'crud_test_page.dart';

class RepairServicePage extends StatefulWidget {
  const RepairServicePage({super.key});

  @override
  State<RepairServicePage> createState() => _RepairServicePageState();
}

class _RepairServicePageState extends State<RepairServicePage>
    with TickerProviderStateMixin {
  
  // GetX Controller
  final ServiceController controller = Get.put(ServiceController());
  
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup animation controllers
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

    // Listen to animation state changes from controller
    ever(controller.isPulsing, (isPulsing) {
      if (isPulsing) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    });

    ever(controller.isRotating, (isRotating) {
      if (isRotating) {
        _rotateController.repeat();
      } else {
        _rotateController.stop();
        _rotateController.reset();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isLandscape),
            
            SizedBox(height: isLandscape ? 3 : 5),

            // Main Content
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
                    // Animation Controls
                    _buildAnimationControls(isLandscape),

                    // MediaQuery Info
                    _buildMediaQueryInfo(isLandscape, columns),

                    // Grid Content
                    Expanded(
                      child: _buildGridContent(isLandscape, columns),
                    ),

                    // Slider (only portrait)
                    if (!isLandscape) _buildSpacingSlider(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ============================================
  // WIDGETS
  // ============================================

  Widget _buildHeader(bool isLandscape) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, isLandscape ? 5 : 10, 20, isLandscape ? 5 : 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Layanan Bengkel',
            style: TextStyle(
              color: Colors.white,
              fontSize: isLandscape ? 16 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (!isLandscape) ...[
            const SizedBox(height: 5),
            Obx(() => Text(
              controller.isEmpty 
                ? 'Memuat layanan...'
                : '${controller.totalServices} layanan tersedia',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimationControls(bool isLandscape) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, isLandscape ? 8 : 15, 20, isLandscape ? 5 : 10),
      child: Obx(() => Container(
        padding: EdgeInsets.all(isLandscape ? 8 : 12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade300, width: 2),
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
                    onPressed: controller.togglePulse,
                    icon: Icon(
                      controller.isPulsing.value ? Icons.pause : Icons.play_arrow,
                      size: isLandscape ? 14 : 18,
                    ),
                    label: Text(
                      controller.isPulsing.value ? 'Stop Pulse' : 'Start Pulse',
                      style: TextStyle(fontSize: isLandscape ? 10 : 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.isPulsing.value ? Colors.red : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: isLandscape ? 6 : 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.toggleRotate,
                    icon: Icon(
                      controller.isRotating.value ? Icons.pause : Icons.rotate_right,
                      size: isLandscape ? 14 : 18,
                    ),
                    label: Text(
                      controller.isRotating.value ? 'Stop Rotate' : 'Start Rotate',
                      style: TextStyle(fontSize: isLandscape ? 10 : 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.isRotating.value ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: isLandscape ? 6 : 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildMediaQueryInfo(bool isLandscape, int columns) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, isLandscape ? 4 : 8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: isLandscape ? 4 : 8),
        decoration: BoxDecoration(
          color: const Color(0xFF455A64).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF455A64).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLandscape ? Icons.stay_current_landscape : Icons.stay_current_portrait,
              color: const Color(0xFF455A64),
              size: isLandscape ? 14 : 16,
            ),
            const SizedBox(width: 6),
            Text(
              '${isLandscape ? "Landscape" : "Portrait"} - $columns Kolom',
              style: TextStyle(
                color: const Color(0xFF455A64),
                fontWeight: FontWeight.bold,
                fontSize: isLandscape ? 9 : 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridContent(bool isLandscape, int columns) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int layoutBuilderColumns;
          if (constraints.maxWidth < 400) {
            layoutBuilderColumns = 2;
          } else if (constraints.maxWidth < 800) {
            layoutBuilderColumns = 3;
          } else {
            layoutBuilderColumns = 4;
          }

          return Column(
            children: [
              // LayoutBuilder Info
              Container(
                margin: EdgeInsets.only(bottom: isLandscape ? 4 : 8),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: isLandscape ? 3 : 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.architecture, color: Colors.green, size: isLandscape ? 12 : 14),
                    const SizedBox(width: 6),
                    Text(
                      'LayoutBuilder: ${constraints.maxWidth.toInt()}px → $layoutBuilderColumns Kolom',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: isLandscape ? 8 : 10,
                      ),
                    ),
                  ],
                ),
              ),

              // Main Grid with GetX
              Expanded(
                child: Obx(() {
                  // Loading State
                  if (controller.isLoading.value) {
                    return _buildLoadingState();
                  }

                  // Error State
                  if (controller.errorMessage.isNotEmpty) {
                    return _buildErrorState();
                  }

                  // Empty State
                  if (controller.isEmpty) {
                    return _buildEmptyState();
                  }

                  // Success State - Grid
                  return _buildSuccessState(isLandscape, layoutBuilderColumns, constraints);
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Memuat layanan...',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: controller.refreshServices,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF455A64),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'Belum ada layanan tersedia',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: controller.refreshServices,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF455A64),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(bool isLandscape, int columns, BoxConstraints constraints) {
    return RefreshIndicator(
      onRefresh: controller.refreshServices,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _rotateController]),
        builder: (context, child) {
          return Obx(() => GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: controller.itemSpacing.value,
              mainAxisSpacing: controller.itemSpacing.value,
              childAspectRatio: isLandscape ? 1.1 : (constraints.maxWidth > 700 ? 0.85 : 0.95),
            ),
            itemCount: controller.services.length,
            itemBuilder: (context, index) {
              final service = controller.services[index];
              final isSelected = controller.selectedIndex.value == index;

              return _buildServiceCard(service, index, isSelected, isLandscape);
            },
          ));
        },
      ),
    );
  }

  Widget _buildServiceCard(service, int index, bool isSelected, bool isLandscape) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => ServiceDetailPage(service: service, heroTag: index),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 500),
        );
      },
      child: Hero(
        tag: 'service-$index',
        child: Transform.scale(
          scale: controller.isPulsing.value ? _pulseAnimation.value : 1.0,
          child: Transform.rotate(
            angle: controller.isRotating.value ? _rotateAnimation.value * 2 * 3.14159 : 0.0,
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
                        service.name,
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
                          color: isSelected ? Colors.white.withOpacity(0.9) : service.getColor(),
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
  }

  Widget _buildSpacingSlider() {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jarak Antar Item',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF455A64),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${controller.itemSpacing.value.toInt()} px',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: const SliderThemeData(
              trackHeight: 3,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: controller.itemSpacing.value,
              min: 5,
              max: 30,
              divisions: 25,
              activeColor: const Color(0xFF455A64),
              inactiveColor: const Color(0xFF455A64).withOpacity(0.2),
              onChanged: controller.updateItemSpacing,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        if (index == 1) {
          Get.to(() => const OrdersPage(), transition: Transition.fade);
        } else if (index == 2) {
          Get.to(() => const ProfilePage(), transition: Transition.zoom);
        } else if (index == 3) {
          Get.snackbar(
            'Info',
            'Halaman Pengaturan sedang dalam pengembangan',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        } else if (index == 4) {
          Get.to(() => const CrudTestPage());
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF455A64),
      unselectedItemColor: Colors.grey.shade400,
      selectedFontSize: 12,
      unselectedFontSize: 11,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Pesanan'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Akun'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Pengaturan'),
        BottomNavigationBarItem(icon: Icon(Icons.api), label: 'API Test'),
      ],
    );
  }
}