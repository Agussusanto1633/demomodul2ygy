// ============================================
// SETTINGS PAGE - WITH SUPABASE & LOCAL STORAGE & DARK MODE
// ============================================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/theme_controller.dart';
import '../services/local_storage_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final authController = Get.find<AuthController>();
  final themeController = Get.find<ThemeController>();
  
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  String _selectedLanguage = 'Bahasa Indonesia';
  double _fontSize = 14.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load settings from local storage
  void _loadSettings() {
    setState(() {
      _notificationsEnabled = LocalStorageService.isNotificationEnabled();
      _selectedLanguage = LocalStorageService.getLanguage() == 'id' 
          ? 'Bahasa Indonesia' 
          : 'English';
    });
  }

  // Save settings to local storage
  Future<void> _saveNotification(bool value) async {
    await LocalStorageService.setNotificationEnabled(value);
  }

  Future<void> _saveLanguage(String lang) async {
    final langCode = lang == 'Bahasa Indonesia' ? 'id' : 'en';
    await LocalStorageService.setLanguage(langCode);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offNamed('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF263238),
                    const Color(0xFF1A1A1A),
                  ]
                : [
                    const Color(0xFF455A64),
                    Colors.grey.shade200,
                  ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header Card with User Info
            _buildHeaderCard(),
            const SizedBox(height: 20),

            // Storage Info Card
            _buildStorageInfoCard(),
            const SizedBox(height: 20),

            // Notifikasi Section
            _buildSectionTitle('Notifikasi'),
            _buildSettingsCard(
              children: [
                _buildSwitchTile(
                  icon: Icons.notifications_active,
                  title: 'Notifikasi Push',
                  subtitle: 'Terima pemberitahuan penting',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    _saveNotification(value);
                    _showSnackbar(
                      value
                          ? 'Notifikasi diaktifkan'
                          : 'Notifikasi dinonaktifkan',
                      value ? Colors.green : Colors.orange,
                    );
                  },
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  icon: Icons.volume_up,
                  title: 'Suara Notifikasi',
                  subtitle: 'Aktifkan suara untuk notifikasi',
                  value: _soundEnabled,
                  onChanged: (value) {
                    setState(() {
                      _soundEnabled = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tampilan Section - DARK MODE
            _buildSectionTitle('Tampilan'),
            Obx(() => _buildSettingsCard(
              children: [
                _buildSwitchTile(
                  icon: Icons.dark_mode,
                  title: 'Mode Gelap',
                  subtitle: 'Ubah tema aplikasi',
                  value: themeController.isDarkMode.value,
                  onChanged: (value) async {
                    await themeController.setDarkMode(value);
                    _showSnackbar(
                      value ? 'Mode gelap diaktifkan' : 'Mode terang diaktifkan',
                      value ? Colors.blueGrey : Colors.amber,
                    );
                  },
                ),
                const Divider(height: 1),
                _buildSliderTile(
                  icon: Icons.text_fields,
                  title: 'Ukuran Font',
                  subtitle: 'Atur ukuran teks aplikasi',
                  value: _fontSize,
                  min: 12.0,
                  max: 20.0,
                  divisions: 4,
                  onChanged: (value) {
                    setState(() {
                      _fontSize = value;
                    });
                  },
                ),
              ],
            )),
            const SizedBox(height: 20),

            // Bahasa Section
            _buildSectionTitle('Bahasa & Region'),
            _buildSettingsCard(
              children: [
                _buildLanguageTile(
                  icon: Icons.language,
                  title: 'Bahasa',
                  subtitle: _selectedLanguage,
                  onTap: () => _showLanguageDialog(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Sistem Section (WITH LOCAL STORAGE)
            _buildSectionTitle('Penyimpanan Lokal'),
            _buildSettingsCard(
              children: [
                _buildActionTile(
                  icon: Icons.cached,
                  title: 'Bersihkan Cache',
                  subtitle: 'Hapus data cache services',
                  iconColor: Colors.orange,
                  onTap: () => _showClearCacheDialog(),
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.storage,
                  title: 'Info Penyimpanan',
                  subtitle: 'Lihat data yang tersimpan',
                  iconColor: Colors.blue,
                  onTap: () => _showStorageInfo(),
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.delete_forever,
                  title: 'Hapus Semua Data Lokal',
                  subtitle: 'Reset data lokal (tanpa hapus akun)',
                  iconColor: Colors.red,
                  onTap: () => _showClearAllDataDialog(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Akun Section (WITH SUPABASE) 🔥
            _buildSectionTitle('Akun & Keamanan 🔥'),
            _buildSettingsCard(
              children: [
                _buildActionTile(
                  icon: Icons.person,
                  title: 'Edit Profil',
                  subtitle: 'Ubah data profil Anda',
                  iconColor: Colors.blue,
                  onTap: () => _showEditProfileDialog(),
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.lock_reset,
                  title: 'Ubah Password',
                  subtitle: 'Perbarui kata sandi Anda',
                  iconColor: Colors.orange,
                  onTap: () => _showChangePasswordDialog(),
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.logout,
                  title: 'Keluar',
                  subtitle: 'Logout dari aplikasi',
                  iconColor: Colors.purple,
                  onTap: () => _showLogoutDialog(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tentang Section
            _buildSectionTitle('Tentang'),
            _buildSettingsCard(
              children: [
                _buildActionTile(
                  icon: Icons.info,
                  title: 'Versi Aplikasi',
                  subtitle: 'v1.0.0 (Build 100) - Modul 4',
                  iconColor: Colors.purple,
                  onTap: () => _showAboutDialog(),
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.bug_report,
                  title: 'Debug Storage',
                  subtitle: 'Print all keys (console)',
                  iconColor: Colors.teal,
                  onTap: () {
                    authController.printStorageInfo();
                    _showSnackbar('Check console for storage info', Colors.teal);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Feature Badge
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.teal.shade600],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Powered by Supabase 🚀',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // BUILD METHODS
  // ========================================

  Widget _buildHeaderCard() {
    return Obx(() {
      final user = authController.currentUser.value;
      final isLoading = authController.isLoading.value;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: isDark 
                    ? const Color(0xFF455A64)
                    : Colors.blue.shade100,
                backgroundImage: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                    ? NetworkImage(user.photoUrl!)
                    : null,
                child: user?.photoUrl == null || user?.photoUrl?.isEmpty == true
                    ? Text(
                        user?.initials ?? '??',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark 
                              ? const Color(0xFFECEFF1)
                              : Colors.blue.shade700,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.username ?? 'Guest',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'No email',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? const Color(0xFF90A4AE)
                            : Colors.grey.shade600,
                      ),
                    ),
                    if (user?.phoneNumber != null && user!.phoneNumber!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        user.phoneNumber!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? const Color(0xFF78909C)
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStorageInfoCard() {
    final storageInfo = authController.getStorageInfo();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline, 
                  color: isDark 
                      ? const Color(0xFF64B5F6) 
                      : Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Status Penyimpanan Lokal',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Total Keys', '${storageInfo['totalKeys']}'),
            _buildInfoRow('User Login', storageInfo['isLoggedIn'] ? 'Ya' : 'Tidak'),
            _buildInfoRow('Username', storageInfo['username'] ?? '-'),
            _buildInfoRow('Cache Data', storageInfo['hasCachedData'] ? 'Ada' : 'Kosong'),
            _buildInfoRow('Cache Status', 
                storageInfo['cacheExpired'] ? 'Expired' : 'Valid'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark 
                  ? const Color(0xFF90A4AE)
                  : Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFFECEFF1)
              : Colors.white,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListTile(
      leading: Icon(
        icon, 
        color: isDark 
            ? const Color(0xFF90A4AE)
            : const Color(0xFF455A64),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        subtitle, 
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: isDark 
            ? const Color(0xFF64B5F6)
            : const Color(0xFF455A64),
      ),
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListTile(
      leading: Icon(
        icon, 
        color: isDark 
            ? const Color(0xFF90A4AE)
            : const Color(0xFF455A64),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle, 
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: value.toStringAsFixed(0),
            onChanged: onChanged,
            activeColor: isDark 
                ? const Color(0xFF64B5F6)
                : const Color(0xFF455A64),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        subtitle, 
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).iconTheme.color,
      ),
      onTap: onTap,
    );
  }

  Widget _buildLanguageTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListTile(
      leading: Icon(
        icon, 
        color: isDark 
            ? const Color(0xFF90A4AE)
            : const Color(0xFF455A64),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        subtitle, 
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).iconTheme.color,
      ),
      onTap: onTap,
    );
  }

  // ========================================
  // DIALOG METHODS
  // ========================================

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Bahasa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('🇮🇩', 'Bahasa Indonesia'),
            _buildLanguageOption('🇬🇧', 'English'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String flag, String language) {
    final isSelected = _selectedLanguage == language;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(language),
      trailing: isSelected
          ? Icon(
              Icons.check_circle, 
              color: isDark 
                  ? const Color(0xFF64B5F6)
                  : const Color(0xFF455A64),
            )
          : null,
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
        _saveLanguage(language);
        Navigator.pop(context);
        _showSnackbar('Bahasa diubah ke $language', Colors.green);
      },
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bersihkan Cache'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua data cache? '
          'Cache services akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await LocalStorageService.clearCache();
              _showSnackbar('Cache berhasil dibersihkan!', Colors.green);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Bersihkan'),
          ),
        ],
      ),
    );
  }

  void _showStorageInfo() {
    final storageInfo = authController.getStorageInfo();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informasi Penyimpanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStorageItem('Total Keys', '${storageInfo['totalKeys']}', Colors.blue),
            _buildStorageItem('Login Status', storageInfo['isLoggedIn'] ? 'Aktif' : 'Tidak Aktif', Colors.green),
            _buildStorageItem('Username', storageInfo['username'] ?? '-', Colors.orange),
            _buildStorageItem('Cached Data', storageInfo['hasCachedData'] ? 'Ada' : 'Kosong', Colors.purple),
            const Divider(),
            const Text(
              '💡 Gunakan "Debug Storage" untuk melihat semua keys di console',
              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(label),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showClearAllDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Hapus Data Lokal'),
          ],
        ),
        content: const Text(
          'Ini akan menghapus data lokal seperti cache dan settings.\n\n'
          '⚠️ Akun Supabase Anda TIDAK akan dihapus.\n'
          'Anda tetap bisa login kembali.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authController.clearAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Hapus Data Lokal'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final usernameController = TextEditingController(
      text: authController.currentUser.value?.username ?? '',
    );
    final phoneController = TextEditingController(
      text: authController.currentUser.value?.phoneNumber ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit, color: Color(0xFF455A64)),
            SizedBox(width: 8),
            Text('Edit Profil'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'No. Telepon',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.cloud, size: 16, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Data akan disimpan ke Supabase',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authController.updateProfile(
                username: usernameController.text,
                phoneNumber: phoneController.text,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF455A64),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // ✅ FIXED: Change Password Dialog - Supabase version
  void _showChangePasswordDialog() {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock_reset, color: Colors.orange),
            SizedBox(width: 8),
            Text('Ubah Password'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Baru (min. 6 karakter)',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi Password Baru',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, size: 16, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Password akan diubah di Supabase',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newPass = newPasswordController.text;
              final confirm = confirmPasswordController.text;

              if (newPass.isEmpty) {
                _showSnackbar('Password tidak boleh kosong', Colors.red);
                return;
              }

              if (newPass != confirm) {
                _showSnackbar('Password tidak cocok', Colors.red);
                return;
              }

              if (newPass.length < 6) {
                _showSnackbar('Password minimal 6 karakter', Colors.red);
                return;
              }

              Navigator.pop(context);
              
              // ✅ FIXED: Use correct method name
              final success = await authController.changePassword(newPass);

              if (success) {
                _showSnackbar('Password berhasil diubah!', Colors.green);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Ubah Password'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.purple),
            SizedBox(width: 8),
            Text('Keluar'),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authController.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.info, 
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            const Text('Informasi'),
          ],
        ),
        content: const Text(
          'Halaman pengaturan ini memungkinkan Anda untuk mengkustomisasi aplikasi sesuai preferensi Anda.\n\n'
          '• Data lokal disimpan dengan SharedPreferences\n'
          '• Data akun disimpan di Supabase PostgreSQL\n'
          '• Password dikelola oleh Supabase Auth\n'
          '• Dark mode tersimpan secara otomatis\n\n'
          'Semua perubahan akan disimpan secara otomatis.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Corner Garage',
      applicationVersion: 'v1.0.0 - Modul 4 🚀',
      applicationIcon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.car_repair,
          size: 40,
          color: Theme.of(context).primaryColor,
        ),
      ),
      children: [
        const SizedBox(height: 16),
        const Text(
          'Aplikasi manajemen layanan bengkel dengan fitur:',
        ),
        const SizedBox(height: 8),
        const Text('✅ Supabase Authentication'),
        const Text('✅ PostgreSQL Database'),
        const Text('✅ Supabase Storage'),
        const Text('✅ Hive Local Storage'),
        const Text('✅ SharedPreferences'),
        const Text('✅ CRUD Operations'),
        const Text('✅ Real-time Sync'),
        const Text('✅ Dark Mode Support'),
        const SizedBox(height: 12),
        const Text(
          '© 2024 Corner Garage\nDikembangkan dengan ❤️ menggunakan Flutter, GetX & Supabase',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}