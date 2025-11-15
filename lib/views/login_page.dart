import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSignUpMode = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    
    _loadSavedCredentials();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  void _loadSavedCredentials() {
    final credentials = authController.getSavedCredentials();
    if (credentials['email']!.isNotEmpty) {
      _emailController.text = credentials['email']!;
      _passwordController.text = credentials['password']!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    bool success;

    if (_isSignUpMode) {
      final username = _usernameController.text.trim();
      success = await authController.signUp(
        email: email,
        password: password,
        username: username,
      );

      if (success) {
        _passwordController.clear();
        _confirmPasswordController.clear();
        _emailController.text = email;
        
        setState(() {
          _isSignUpMode = false;
        });
        
        Get.snackbar(
          '✅ Registrasi Berhasil!',
          'Akun Anda telah dibuat. Silakan login dengan email dan password yang baru dibuat.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      }
    } else {
      // ✅ FIXED: Gunakan signIn (bukan signInWithEmailAndPassword)
      success = await authController.signIn(
        email: email,
        password: password,
      );

      if (success) {
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offAllNamed('/home');
        });
      }
    }
  }

  // ✅ REMOVED: Google Sign In tidak tersedia di Supabase basic setup
  // Jika ingin menggunakan Google Sign In, perlu konfigurasi tambahan di Supabase
  
  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    
    if (email.isEmpty) {
      Get.snackbar(
        '⚠️ Email Kosong',
        'Masukkan email terlebih dahulu',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    await authController.resetPassword(email);
  }

  void _toggleMode() {
    setState(() {
      _isSignUpMode = !_isSignUpMode;
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1A1A1A),
                    const Color(0xFF263238),
                    const Color(0xFF37474F),
                  ]
                : [
                    const Color(0xFF1E3A5F),
                    const Color(0xFF2E5984),
                    Colors.blue.shade600,
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 20 : 28,
                vertical: 20,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Card(
                  elevation: 12,
                  shadowColor: Colors.black.withOpacity(isDark ? 0.5 : 0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo
                          Container(
                            width: isSmallScreen ? 90 : 100,
                            height: isSmallScreen ? 90 : 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [
                                        const Color(0xFF455A64),
                                        const Color(0xFF37474F),
                                      ]
                                    : [
                                        Colors.blue.shade100,
                                        Colors.blue.shade50,
                                      ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (isDark ? Colors.blue.shade800 : Colors.blue)
                                      .withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.car_repair,
                              size: isSmallScreen ? 50 : 55,
                              color: isDark 
                                  ? const Color(0xFF64B5F6)
                                  : Colors.blue.shade700,
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 20 : 24),

                          // Title
                          Text(
                            'Corner Garage',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 26 : 30,
                              fontWeight: FontWeight.bold,
                              color: isDark 
                                  ? const Color(0xFFECEFF1)
                                  : const Color(0xFF1E3A5F),
                              letterSpacing: 0.5,
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 6 : 8),

                          // Subtitle
                          Text(
                            _isSignUpMode ? 'Daftar Akun Baru' : 'Silakan login untuk melanjutkan',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 13 : 14,
                              color: isDark 
                                  ? const Color(0xFF90A4AE)
                                  : Colors.grey.shade600,
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 28 : 32),

                          // Username Field (only for Sign Up)
                          if (_isSignUpMode) ...[
                            Obx(() => TextFormField(
                              controller: _usernameController,
                              enabled: !authController.isLoading.value,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 15,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Nama Lengkap',
                                labelStyle: TextStyle(
                                  fontSize: isSmallScreen ? 13 : 14,
                                  color: isDark 
                                      ? const Color(0xFF90A4AE)
                                      : Colors.grey.shade600,
                                ),
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  size: isSmallScreen ? 20 : 22,
                                  color: isDark 
                                      ? const Color(0xFF90A4AE)
                                      : Colors.grey.shade600,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: isDark 
                                        ? const Color(0xFF37474F)
                                        : Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: isDark 
                                        ? const Color(0xFF64B5F6)
                                        : Colors.blue.shade600,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: isSmallScreen ? 14 : 16,
                                ),
                              ),
                              validator: (value) {
                                if (_isSignUpMode && (value == null || value.isEmpty)) {
                                  return 'Nama tidak boleh kosong';
                                }
                                return null;
                              },
                            )),
                            SizedBox(height: isSmallScreen ? 16 : 18),
                          ],

                          // Email Field
                          Obx(() => TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !authController.isLoading.value,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 15,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                fontSize: isSmallScreen ? 13 : 14,
                                color: isDark 
                                    ? const Color(0xFF90A4AE)
                                    : Colors.grey.shade600,
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                size: isSmallScreen ? 20 : 22,
                                color: isDark 
                                    ? const Color(0xFF90A4AE)
                                    : Colors.grey.shade600,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: isDark 
                                      ? const Color(0xFF37474F)
                                      : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: isDark 
                                      ? const Color(0xFF64B5F6)
                                      : Colors.blue.shade600,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: isSmallScreen ? 14 : 16,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email tidak boleh kosong';
                              }
                              if (!value.contains('@')) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          )),

                          SizedBox(height: isSmallScreen ? 16 : 18),

                          // Password Field
                          Obx(() => TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            enabled: !authController.isLoading.value,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 15,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                fontSize: isSmallScreen ? 13 : 14,
                                color: isDark 
                                    ? const Color(0xFF90A4AE)
                                    : Colors.grey.shade600,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                size: isSmallScreen ? 20 : 22,
                                color: isDark 
                                    ? const Color(0xFF90A4AE)
                                    : Colors.grey.shade600,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword 
                                      ? Icons.visibility_outlined 
                                      : Icons.visibility_off_outlined,
                                  size: isSmallScreen ? 20 : 22,
                                  color: isDark 
                                      ? const Color(0xFF90A4AE)
                                      : Colors.grey.shade600,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: isDark 
                                      ? const Color(0xFF37474F)
                                      : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: isDark 
                                      ? const Color(0xFF64B5F6)
                                      : Colors.blue.shade600,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: isSmallScreen ? 14 : 16,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password tidak boleh kosong';
                              }
                              if (value.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return null;
                            },
                          )),

                          // Confirm Password (only for Sign Up)
                          if (_isSignUpMode) ...[
                            SizedBox(height: isSmallScreen ? 16 : 18),
                            Obx(() => TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              enabled: !authController.isLoading.value,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 15,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Konfirmasi Password',
                                labelStyle: TextStyle(
                                  fontSize: isSmallScreen ? 13 : 14,
                                  color: isDark 
                                      ? const Color(0xFF90A4AE)
                                      : Colors.grey.shade600,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  size: isSmallScreen ? 20 : 22,
                                  color: isDark 
                                      ? const Color(0xFF90A4AE)
                                      : Colors.grey.shade600,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword 
                                        ? Icons.visibility_outlined 
                                        : Icons.visibility_off_outlined,
                                    size: isSmallScreen ? 20 : 22,
                                    color: isDark 
                                        ? const Color(0xFF90A4AE)
                                        : Colors.grey.shade600,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: isDark 
                                        ? const Color(0xFF37474F)
                                        : Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: isDark 
                                        ? const Color(0xFF64B5F6)
                                        : Colors.blue.shade600,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: isSmallScreen ? 14 : 16,
                                ),
                              ),
                              validator: (value) {
                                if (_isSignUpMode && value != _passwordController.text) {
                                  return 'Password tidak cocok';
                                }
                                return null;
                              },
                            )),
                          ],

                          SizedBox(height: isSmallScreen ? 10 : 12),

                          // Remember Me & Forgot Password
                          if (!_isSignUpMode)
                            Obx(() => Row(
                              children: [
                                Checkbox(
                                  value: authController.rememberMe.value,
                                  onChanged: authController.isLoading.value 
                                      ? null 
                                      : (value) {
                                          authController.toggleRememberMe();
                                        },
                                  activeColor: isDark 
                                      ? const Color(0xFF64B5F6)
                                      : Colors.blue.shade600,
                                ),
                                Text(
                                  'Ingat Saya',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 13 : 14,
                                    color: isDark 
                                        ? const Color(0xFF90A4AE)
                                        : Colors.grey.shade700,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: authController.isLoading.value 
                                      ? null 
                                      : _handleForgotPassword,
                                  child: Text(
                                    'Lupa Password?',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 12 : 13,
                                      color: isDark 
                                          ? const Color(0xFF64B5F6)
                                          : Colors.blue.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            )),

                          SizedBox(height: isSmallScreen ? 20 : 24),

                          // Auth Button
                          Obx(() => SizedBox(
                            width: double.infinity,
                            height: isSmallScreen ? 48 : 52,
                            child: ElevatedButton(
                              onPressed: authController.isLoading.value ? null : _handleAuth,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark 
                                    ? const Color(0xFF455A64)
                                    : const Color(0xFF1E3A5F),
                                disabledBackgroundColor: Colors.grey.shade400,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 3,
                                shadowColor: (isDark ? Colors.blue.shade800 : Colors.blue)
                                    .withOpacity(0.3),
                              ),
                              child: authController.isLoading.value
                                  ? SizedBox(
                                      height: isSmallScreen ? 22 : 24,
                                      width: isSmallScreen ? 22 : 24,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      _isSignUpMode ? 'Daftar' : 'Login',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 15 : 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          )),

                          SizedBox(height: isSmallScreen ? 18 : 20),

                          // Toggle Sign In / Sign Up
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isSignUpMode 
                                    ? 'Sudah punya akun?' 
                                    : 'Belum punya akun?',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 13 : 14,
                                  color: isDark 
                                      ? const Color(0xFF90A4AE)
                                      : Colors.grey.shade700,
                                ),
                              ),
                              TextButton(
                                onPressed: _toggleMode,
                                child: Text(
                                  _isSignUpMode ? 'Login' : 'Daftar',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 13 : 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark 
                                        ? const Color(0xFF64B5F6)
                                        : Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: isSmallScreen ? 12 : 14),

                          // ✅ UPDATED: Supabase Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.green.shade400, Colors.teal.shade600],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.cloud, color: Colors.white, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'Powered by Supabase',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 10 : 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }
}