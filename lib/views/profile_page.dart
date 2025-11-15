import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ============================================
// PROFILE PAGE - IMPROVED DARK MODE CONTRAST
// ============================================
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offNamed('/home'),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF263238), // Dark blue grey (LEBIH TERANG)
                    const Color(0xFF1A1A1A), // Dark grey (BUKAN HITAM)
                  ]
                : [
                    const Color(0xFF455A64),
                    Colors.grey.shade200,
                  ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person_outline,
                  size: 80,
                  // PENTING: Icon warna terang di dark mode!
                  color: isDark 
                      ? const Color(0xFF90A4AE) // LIGHT GREY
                      : Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 30),
              
              // Text otomatis terang dari theme
              Text(
                'Halaman Profil',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 10),
              Text(
                'Kelola informasi akun Anda',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 30),
              
              // Badge dengan background yang kontras
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.blue.withOpacity(0.2) // Transparan di dark
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark 
                        ? const Color(0xFF64B5F6) // Light blue di dark mode
                        : Colors.blue,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.animation, 
                      color: isDark 
                          ? const Color(0xFF64B5F6)
                          : Colors.blue, 
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Transisi: Scale Animation',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark 
                            ? const Color(0xFF64B5F6)
                            : Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Button otomatis adaptive dari theme
              ElevatedButton.icon(
                onPressed: () => Get.offNamed('/home'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali ke Beranda'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}