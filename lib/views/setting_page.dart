// ============================================
// SETTINGS PAGE
// ============================================
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoUpdateEnabled = true;
  bool _soundEnabled = true;
  String _selectedLanguage = 'Bahasa Indonesia';
  double _fontSize = 14.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: const Color(0xFF455A64),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
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
            colors: [const Color(0xFF455A64), Colors.grey.shade200],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header Card
            _buildHeaderCard(),
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

            // Tampilan Section
            _buildSectionTitle('Tampilan'),
            _buildSettingsCard(
              children: [
                _buildSwitchTile(
                  icon: Icons.dark_mode,
                  title: 'Mode Gelap',
                  subtitle: 'Ubah tema aplikasi',
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _darkModeEnabled = value;
                    });
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
            ),
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

            // Sistem Section
            _buildSectionTitle('Sistem'),
            _buildSettingsCard(
              children: [
                _buildSwitchTile(
                  icon: Icons.update,
                  title: 'Update Otomatis',
                  subtitle: 'Perbarui aplikasi secara otomatis',
                  value: _autoUpdateEnabled,
                  onChanged: (value) {
                    setState(() {
                      _autoUpdateEnabled = value;
                    });
                  },
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.cached,
                  title: 'Bersihkan Cache',
                  subtitle: 'Hapus data sementara',
                  iconColor: Colors.orange,
                  onTap: () => _showClearCacheDialog(),
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.storage,
                  title: 'Penyimpanan',
                  subtitle: 'Kelola penyimpanan aplikasi',
                  iconColor: Colors.blue,
                  onTap: () => _showStorageInfo(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Akun Section
            _buildSectionTitle('Akun'),
            _buildSettingsCard(
              children: [
                _buildActionTile(
                  icon: Icons.lock_reset,
                  title: 'Ubah Password',
                  subtitle: 'Perbarui kata sandi Anda',
                  iconColor: Colors.blue,
                  onTap: () => _showChangePasswordDialog(),
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.logout,
                  title: 'Keluar',
                  subtitle: 'Logout dari aplikasi',
                  iconColor: Colors.red,
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
                  subtitle: 'v1.0.0 (Build 100)',
                  iconColor: Colors.purple,
                  onTap: () => _showAboutDialog(),
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.policy,
                  title: 'Kebijakan Privasi',
                  subtitle: 'Baca kebijakan privasi kami',
                  iconColor: Colors.green,
                  onTap: () {
                    _showSnackbar('Membuka kebijakan privasi...', Colors.green);
                  },
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.gavel,
                  title: 'Syarat & Ketentuan',
                  subtitle: 'Baca syarat penggunaan',
                  iconColor: Colors.teal,
                  onTap: () {
                    _showSnackbar(
                        'Membuka syarat & ketentuan...', Colors.teal);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Animation Info Badge
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.purple, width: 2),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.animation, color: Colors.purple, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Transisi: Slide Animation',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.settings,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pengaturan Aplikasi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Kelola preferensi dan akun Anda',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blue.shade700),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF455A64),
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
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.orange.shade700),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: value.toStringAsFixed(0),
            onChanged: onChanged,
            activeColor: const Color(0xFF455A64),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.green.shade700),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
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
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showSnackbar(String message, Color color) {
    Get.snackbar(
      '',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Bahasa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('Bahasa Indonesia', '🇮🇩'),
            _buildLanguageOption('English', '🇬🇧'),
            _buildLanguageOption('中文', '🇨🇳'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String language, String flag) {
    final isSelected = _selectedLanguage == language;
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(language),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFF455A64))
          : null,
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
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
          'Apakah Anda yakin ingin menghapus semua data cache? Ini akan membebaskan ruang penyimpanan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informasi Penyimpanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStorageItem('Cache', '45 MB', Colors.orange),
            _buildStorageItem('Data Aplikasi', '120 MB', Colors.blue),
            _buildStorageItem('Media', '230 MB', Colors.green),
            const Divider(),
            _buildStorageItem('Total', '395 MB', Colors.purple),
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

  Widget _buildStorageItem(String label, String size, Color color) {
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
            size,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Lama',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Baru',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi Password',
                prefixIcon: Icon(Icons.lock),
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
              _showSnackbar('Password berhasil diubah!', Colors.green);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF455A64),
            ),
            child: const Text('Ubah'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.offAllNamed('/login');
              _showSnackbar('Berhasil logout', Colors.red);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
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
        title: const Row(
          children: [
            Icon(Icons.info, color: Color(0xFF455A64)),
            SizedBox(width: 8),
            Text('Informasi'),
          ],
        ),
        content: const Text(
          'Halaman pengaturan ini memungkinkan Anda untuk mengkustomisasi aplikasi sesuai preferensi Anda. '
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
      applicationName: 'Layanan Bengkel',
      applicationVersion: 'v1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF455A64).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.build_circle,
          size: 40,
          color: Color(0xFF455A64),
        ),
      ),
      children: [
        const SizedBox(height: 16),
        const Text(
          'Aplikasi manajemen layanan bengkel untuk memudahkan pelanggan dalam memesan dan melacak layanan perbaikan kendaraan.',
        ),
        const SizedBox(height: 12),
        const Text(
          '© 2024 Layanan Bengkel\nDikembangkan dengan ❤️ menggunakan Flutter',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}