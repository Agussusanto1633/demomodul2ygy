import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/service_controller.dart';
import '../controllers/auth_controller.dart';
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
    final authController = Get.find<AuthController>();
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final mediaQuery = MediaQuery.of(context);
    
    // ✅ DETECT DARK MODE
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // ✅ ADAPTIVE COLORS
    final appBarColor = isDark ? const Color(0xFF263238) : const Color(0xFF455A64);
    final backgroundColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5);
    final headerGradientStart = isDark ? const Color(0xFF263238) : const Color(0xFF455A64);
    final headerGradientEnd = isDark ? const Color(0xFF37474F) : const Color(0xFF607D8B);
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
        extendBodyBehindAppBar: false,
        
        appBar: AppBar(
          title: const Text('Corner Garage'),
          backgroundColor: appBarColor,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: appBarColor,
            statusBarIconBrightness: Brightness.light,
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFFFF6F00), const Color(0xFFFF8F00)]
                      : [Colors.orange.shade600, Colors.orange.shade400],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud, size: 16, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'SUPABASE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Get.toNamed('/settings'),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => authController.signOut(),
            ),
          ],
        ),
        
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: backgroundColor,
          child: RefreshIndicator(
            onRefresh: () => serviceController.fetchAllServices(),
            color: isDark ? const Color(0xFF64B5F6) : null,
            backgroundColor: isDark ? const Color(0xFF263238) : null,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ✅ HEADER SECTION - ADAPTIVE
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [headerGradientStart, headerGradientEnd],
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      isLandscape ? mediaQuery.padding.left + 16 : 20,
                      isLandscape ? 12 : 20,
                      isLandscape ? mediaQuery.padding.right + 16 : 20,
                      isLandscape ? 12 : 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() {
                          final user = authController.currentUser.value;
                          return Row(
                            children: [
                              // ✅ AVATAR - ADAPTIVE
                              CircleAvatar(
                                radius: isLandscape ? 20 : 24,
                                backgroundColor: isDark 
                                    ? const Color(0xFF455A64)
                                    : Colors.white.withOpacity(0.3),
                                child: Text(
                                  user?.initials ?? '??',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isLandscape ? 14 : 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selamat Datang! 👋',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isLandscape ? 14 : 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      user?.username ?? 'Guest',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: isLandscape ? 12 : 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                        SizedBox(height: isLandscape ? 12 : 20),
                        Text(
                          '🚗 Layanan Kami',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isLandscape ? 16 : 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: isLandscape ? 4 : 8),
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: isLandscape ? 12 : 14,
                              color: isDark 
                                  ? const Color(0xFFFFB74D)
                                  : Colors.orange.shade300,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Pilih layanan yang Anda butuhkan',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: isLandscape ? 10 : 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ✅ STATS CARD - ADAPTIVE
                SliverToBoxAdapter(
                  child: Obx(() {
                    final serviceCount = serviceController.services.length;
                    
                    return Container(
                      margin: EdgeInsets.all(isLandscape ? 12 : 16),
                      padding: EdgeInsets.all(isLandscape ? 12 : 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFFFF6F00), const Color(0xFFFF8F00)]
                              : [Colors.orange.shade50, Colors.orange.shade100],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border(
                          bottom: BorderSide(
                            color: isDark 
                                ? const Color(0xFFFFB74D)
                                : Colors.orange.shade200,
                            width: 2,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark 
                                ? Colors.orange.withOpacity(0.3)
                                : Colors.orange.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isLandscape ? 8 : 12),
                            decoration: BoxDecoration(
                              color: isDark 
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.orange.shade700,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.build_circle,
                              color: Colors.white,
                              size: isLandscape ? 20 : 28,
                            ),
                          ),
                          SizedBox(width: isLandscape ? 12 : 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Layanan Tersedia',
                                  style: TextStyle(
                                    color: isDark 
                                        ? Colors.white
                                        : Colors.orange.shade900,
                                    fontSize: isLandscape ? 11 : 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: isLandscape ? 2 : 4),
                                Text(
                                  '$serviceCount Layanan',
                                  style: TextStyle(
                                    color: isDark 
                                        ? Colors.white
                                        : Colors.orange.shade700,
                                    fontSize: isLandscape ? 16 : 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: isDark 
                                ? Colors.white70
                                : Colors.orange.shade700,
                            size: isLandscape ? 16 : 20,
                          ),
                        ],
                      ),
                    );
                  }),
                ),

                // ✅ SERVICE GRID - ADAPTIVE
                Obx(() {
                  final services = serviceController.services;
                  
                  if (serviceController.isLoading.value) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (services.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: isLandscape ? 60 : 80,
                              color: emptyStateColor,
                            ),
                            SizedBox(height: isLandscape ? 12 : 16),
                            Text(
                              'Belum ada layanan',
                              style: TextStyle(
                                fontSize: isLandscape ? 14 : 18,
                                color: emptyStateColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: isLandscape ? 6 : 8),
                            Text(
                              'Tarik ke bawah untuk memuat ulang',
                              style: TextStyle(
                                fontSize: isLandscape ? 11 : 14,
                                color: emptyStateColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      isLandscape ? 12 : 16,
                      isLandscape ? 6 : 8,
                      isLandscape ? 12 : 16,
                      isLandscape ? 60 : 80,
                    ),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isLandscape ? 4 : 2,
                        childAspectRatio: isLandscape ? 0.9 : 0.85,
                        crossAxisSpacing: _itemSpacing,
                        mainAxisSpacing: _itemSpacing,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final service = services[index];
                          final isSelected = selectedIndex == index;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = isSelected ? null : index;
                              });
                              
                              if (!isSelected) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ServiceDetailPage(service: service),
                                  ),
                                );
                              }
                            },
                            child: AnimatedBuilder(
                              animation: _isPulsing && isSelected
                                  ? _pulseAnimation
                                  : const AlwaysStoppedAnimation(1.0),
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _isPulsing && isSelected
                                      ? _pulseAnimation.value
                                      : 1.0,
                                  child: child,
                                );
                              },
                              child: AnimatedBuilder(
                                animation: _isRotating && isSelected
                                    ? _rotateAnimation
                                    : const AlwaysStoppedAnimation(0.0),
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _isRotating && isSelected
                                        ? _rotateAnimation.value * 2 * 3.14159
                                        : 0.0,
                                    child: child,
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        service.getColor(),
                                        service.getColor().withOpacity(0.7),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(isLandscape ? 12 : 20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected
                                            ? service.getColor().withOpacity(0.5)
                                            : service.getColor().withOpacity(0.3),
                                        blurRadius: isSelected ? 20 : 10,
                                        offset: Offset(0, isSelected ? 8 : 4),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.transparent,
                                      width: isSelected ? 3 : 0,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(isLandscape ? 8 : 16),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(isLandscape ? 8 : 16),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.3),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            service.getIcon(),
                                            size: isLandscape ? 24 : 40,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: isLandscape ? 6 : 12),
                                        Text(
                                          service.name,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isLandscape ? 11 : 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: isLandscape ? 4 : 8),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isLandscape ? 6 : 10,
                                            vertical: isLandscape ? 3 : 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            service.price,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isLandscape ? 9 : 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
        ),
        
        // ✅ BOTTOM NAV - ADAPTIVE
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
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
                // Already on Home
                break;
              case 1:
                Get.offAllNamed('/crud-test');
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
        
        // ✅ FAB - ADAPTIVE
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'pulse',
              mini: true,
              backgroundColor: _isPulsing 
                  ? Colors.red 
                  : (isDark ? const Color(0xFF1976D2) : Colors.blue),
              onPressed: _togglePulse,
              tooltip: 'Toggle Pulse',
              child: Icon(_isPulsing ? Icons.pause : Icons.play_arrow),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'rotate',
              mini: true,
              backgroundColor: _isRotating 
                  ? Colors.red 
                  : (isDark ? const Color(0xFFFF6F00) : Colors.orange),
              onPressed: _toggleRotate,
              tooltip: 'Toggle Rotate',
              child: Icon(_isRotating ? Icons.stop : Icons.rotate_right),
            ),
          ],
        ),
      ),
    );
  }
}