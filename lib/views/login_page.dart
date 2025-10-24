import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/service_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'repaint@gmail.com');
  final _passwordController = TextEditingController(text: 'repaint123');
  bool _obscurePassword = true;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Kredensial yang valid
  static const String _validEmail = 'repaint@gmail.com';
  static const String _validPassword = 'repaint123';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text;

        if (email != _validEmail) {
          throw Exception('Email tidak terdaftar. Gunakan: $_validEmail');
        }

        if (password != _validPassword) {
          throw Exception('Password salah. Silakan coba lagi.');
        }

        Get.snackbar(
          'Berhasil',
          'Login berhasil! Selamat datang.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 2),
        );

        Future.delayed(const Duration(milliseconds: 800), () {
          setState(() {
            _isLoading = false;
          });
          Get.offAllNamed('/home');
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        Get.snackbar(
          'Login Gagal',
          e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceController = Get.find<ServiceController>();
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
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
                  shadowColor: Colors.black.withOpacity(0.2),
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
                                colors: [
                                  Colors.blue.shade100,
                                  Colors.blue.shade50,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/icon.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 20 : 24),

                          // Title
                          Text(
                            'Corner Garage',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 26 : 30,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E3A5F),
                              letterSpacing: 0.5,
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 6 : 8),

                          Text(
                            'Silakan login untuk melanjutkan',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 13 : 14,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 28 : 32),

                          // API Toggle
                          Obx(() => Container(
                            padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
                            decoration: BoxDecoration(
                              color: serviceController.useDio.value
                                  ? Colors.green.shade50
                                  : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: serviceController.useDio.value
                                    ? Colors.green.shade300
                                    : Colors.blue.shade300,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // HTTP
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.http,
                                            color: !serviceController.useDio.value
                                                ? Colors.blue.shade700
                                                : Colors.grey.shade400,
                                            size: isSmallScreen ? 26 : 28,
                                          ),
                                          SizedBox(height: isSmallScreen ? 4 : 6),
                                          Text(
                                            'HTTP',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: isSmallScreen ? 13 : 14,
                                              color: !serviceController.useDio.value
                                                  ? Colors.blue.shade700
                                                  : Colors.grey.shade400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Switch
                                    Transform.scale(
                                      scale: isSmallScreen ? 1.0 : 1.2,
                                      child: Switch(
                                        value: serviceController.useDio.value,
                                        onChanged: (value) {
                                          serviceController.toggleApiMode();
                                        },
                                        activeColor: Colors.green.shade600,
                                        activeTrackColor: Colors.green.shade200,
                                        inactiveThumbColor: Colors.blue.shade600,
                                        inactiveTrackColor: Colors.blue.shade200,
                                      ),
                                    ),

                                    // DIO
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.rocket_launch,
                                            color: serviceController.useDio.value
                                                ? Colors.green.shade700
                                                : Colors.grey.shade400,
                                            size: isSmallScreen ? 26 : 28,
                                          ),
                                          SizedBox(height: isSmallScreen ? 4 : 6),
                                          Text(
                                            'DIO',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: isSmallScreen ? 13 : 14,
                                              color: serviceController.useDio.value
                                                  ? Colors.green.shade700
                                                  : Colors.grey.shade400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: isSmallScreen ? 10 : 12),

                                // Badge
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 12 : 14,
                                    vertical: isSmallScreen ? 6 : 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: serviceController.useDio.value
                                        ? Colors.green.shade600
                                        : Colors.blue.shade600,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                        size: isSmallScreen ? 14 : 16,
                                      ),
                                      SizedBox(width: isSmallScreen ? 6 : 8),
                                      Text(
                                        serviceController.useDio.value
                                            ? 'Using DIO Package'
                                            : 'Using HTTP Package',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: isSmallScreen ? 11 : 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),

                          SizedBox(height: isSmallScreen ? 22 : 28),

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !_isLoading,
                            style: TextStyle(fontSize: isSmallScreen ? 14 : 15),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                fontSize: isSmallScreen ? 13 : 14,
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                size: isSmallScreen ? 20 : 22,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Colors.blue.shade600,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
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
                          ),

                          SizedBox(height: isSmallScreen ? 16 : 18),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            enabled: !_isLoading,
                            style: TextStyle(fontSize: isSmallScreen ? 14 : 15),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                fontSize: isSmallScreen ? 13 : 14,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                size: isSmallScreen ? 20 : 22,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: isSmallScreen ? 20 : 22,
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
                                  color: Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Colors.blue.shade600,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
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
                          ),

                          SizedBox(height: isSmallScreen ? 24 : 28),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: isSmallScreen ? 48 : 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A5F),
                                disabledBackgroundColor: Colors.grey.shade400,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 3,
                                shadowColor: Colors.blue.withOpacity(0.3),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      height: isSmallScreen ? 22 : 24,
                                      width: isSmallScreen ? 22 : 24,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 15 : 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 18 : 20),

                          // Credentials Info
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.amber.shade200,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: isSmallScreen ? 16 : 18,
                                      color: Colors.amber.shade800,
                                    ),
                                    SizedBox(width: isSmallScreen ? 6 : 8),
                                    Text(
                                      'Kredensial Login',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber.shade900,
                                        fontSize: isSmallScreen ? 12 : 13,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isSmallScreen ? 8 : 10),
                                Text(
                                  'Email: $_validEmail',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 11 : 12,
                                    color: Colors.amber.shade900,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 3 : 4),
                                Text(
                                  'Password: $_validPassword',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 11 : 12,
                                    color: Colors.amber.shade900,
                                    fontWeight: FontWeight.w500,
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