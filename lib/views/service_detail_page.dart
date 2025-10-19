import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/service_model.dart';

class ServiceDetailPage extends StatelessWidget {
  final ServiceModel service;
  final int heroTag;

  const ServiceDetailPage({
    super.key,
    required this.service,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: service.getColor(),
      body: SafeArea(
        child: isLandscape
            ? _buildLandscapeLayout(context)
            : _buildPortraitLayout(context),
      ),
    );
  }

  // ============================================
  // PORTRAIT LAYOUT
  // ============================================
  Widget _buildPortraitLayout(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              const Spacer(),
              const Text(
                'Detail Layanan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Hero Icon
        Hero(
          tag: 'service-$heroTag',
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              service.getIcon(),
              size: 80,
              color: service.getColor(),
            ),
          ),
        ),
        const SizedBox(height: 30),

        // Content
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Name
                    Text(
                      service.name,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: service.getColor(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Price
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: service.getBackgroundColor(),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        service.price,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: service.getColor(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Description Section
                    const Text(
                      'Deskripsi Layanan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      service.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Features Section
                    const Text(
                      'Keunggulan:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildFeature(
                      Icons.check_circle,
                      'Garansi 30 hari',
                      service.getColor(),
                    ),
                    _buildFeature(
                      Icons.check_circle,
                      'Teknisi berpengalaman',
                      service.getColor(),
                    ),
                    _buildFeature(
                      Icons.check_circle,
                      'Harga terjangkau',
                      service.getColor(),
                    ),
                    _buildFeature(
                      Icons.check_circle,
                      'Pengerjaan cepat',
                      service.getColor(),
                    ),
                    const SizedBox(height: 30),

                    // Order Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.snackbar(
                            'Berhasil',
                            'Memesan ${service.name}...',
                            backgroundColor: service.getColor(),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                            duration: const Duration(seconds: 2),
                          );
                          Future.delayed(
                            const Duration(seconds: 2),
                            () => Get.back(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: service.getColor(),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Pesan Sekarang',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================
  // LANDSCAPE LAYOUT
  // ============================================
  Widget _buildLandscapeLayout(BuildContext context) {
    return Row(
      children: [
        // Left Side - Header & Hero
        Container(
          width: MediaQuery.of(context).size.width * 0.35,
          color: service.getColor(),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Get.back(),
                    ),
                    const Expanded(
                      child: Text(
                        'Detail Layanan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              const Spacer(),

              // Hero Icon
              Hero(
                tag: 'service-$heroTag',
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    service.getIcon(),
                    size: 50,
                    color: service.getColor(),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),

        // Right Side - Content
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Name
                    Text(
                      service.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: service.getColor(),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Price
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: service.getBackgroundColor(),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        service.price,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: service.getColor(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Description Section
                    const Text(
                      'Deskripsi Layanan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      service.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Features Section
                    const Text(
                      'Keunggulan:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFeature(
                      Icons.check_circle,
                      'Garansi 30 hari',
                      service.getColor(),
                    ),
                    _buildFeature(
                      Icons.check_circle,
                      'Teknisi berpengalaman',
                      service.getColor(),
                    ),
                    _buildFeature(
                      Icons.check_circle,
                      'Harga terjangkau',
                      service.getColor(),
                    ),
                    _buildFeature(
                      Icons.check_circle,
                      'Pengerjaan cepat',
                      service.getColor(),
                    ),
                    const SizedBox(height: 20),

                    // Order Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.snackbar(
                            'Berhasil',
                            'Memesan ${service.name}...',
                            backgroundColor: service.getColor(),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                            duration: const Duration(seconds: 2),
                          );
                          Future.delayed(
                            const Duration(seconds: 2),
                            () => Get.back(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: service.getColor(),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Pesan Sekarang',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================
  // HELPER WIDGET: Feature Item
  // ============================================
  Widget _buildFeature(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}