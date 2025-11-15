import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/local_storage_service.dart';
import '../services/supabase_service.dart';
import '../models/user_model.dart';

// ============================================
// AUTHENTICATION CONTROLLER - WITH SUPABASE
// ============================================
class AuthController extends GetxController {
  // Services
  final _supabaseService = SupabaseService();
  
  // Observable variables
  var isLoggedIn = false.obs;
  var currentUser = Rxn<UserModel>();
  var isLoading = false.obs;
  var rememberMe = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }

  // ========================================
  // INITIALIZE AUTHENTICATION
  // ========================================
  Future<void> _initializeAuth() async {
    print('\n🔐 Initializing Authentication...');
    
    // Listen to Supabase auth state changes
    _supabaseService.authStateChanges.listen((AuthState state) {
      final user = state.session?.user;
      if (user != null) {
        print('✅ Supabase user detected: ${user.email}');
        _onUserLoggedIn(user);
      } else {
        print('❌ No Supabase user');
        _onUserLoggedOut();
      }
    });

    // Check local storage for remember me
    loadRememberMe();
    
    print('✅ Authentication initialized\n');
  }

  // ========================================
  // SUPABASE AUTH STATE HANDLERS
  // ========================================
  
  /// Handle user logged in
  Future<void> _onUserLoggedIn(User supabaseUser) async {
    try {
      isLoggedIn.value = true;

      // Get user profile from Supabase
      final userData = await _supabaseService.getUserProfile(supabaseUser.id);

      if (userData != null) {
        currentUser.value = userData;
        
        // Save to local storage for offline access
        await LocalStorageService.setLoggedIn(true);
        await LocalStorageService.setUserData(userData.toJson());
        await LocalStorageService.setUsername(userData.username);
        await LocalStorageService.setEmail(userData.email);
        await LocalStorageService.setUserId(userData.id);
        
        print('✅ User data loaded: ${userData.username}');
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
    }
  }

  /// Handle user logged out
  Future<void> _onUserLoggedOut() async {
    isLoggedIn.value = false;
    currentUser.value = null;
    
    // Keep local storage if remember me is enabled
    if (!rememberMe.value) {
      await LocalStorageService.clearUserData();
    }
  }

  // ========================================
  // SIGN UP (EMAIL & PASSWORD)
  // ========================================
  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      isLoading.value = true;

      print('\n🔐 Signing up new user...');
      
      // Sign up with Supabase
      await _supabaseService.signUpWithEmail(
        email: email,
        password: password,
        username: username,
      );

      Get.snackbar(
        '✅ Registrasi Berhasil',
        'Akun berhasil dibuat. Selamat datang, $username!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      return true;
    } catch (e) {
      print('❌ Sign up error: $e');
      
      Get.snackbar(
        '❌ Registrasi Gagal',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ========================================
  // SIGN IN (EMAIL & PASSWORD)
  // ========================================
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      print('\n🔐 Signing in with email...');

      // Validate input
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email dan password tidak boleh kosong');
      }

      // Sign in with Supabase
      await _supabaseService.signInWithEmail(
        email: email,
        password: password,
      );

      // Save credentials if remember me is enabled
      if (rememberMe.value) {
        await LocalStorageService.setSavedCredentials(email, password);
        await LocalStorageService.setRememberMe(true);
      }

      Get.snackbar(
        '✅ Login Berhasil',
        'Selamat datang kembali!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      return true;
    } catch (e) {
      print('❌ Sign in error: $e');
      
      Get.snackbar(
        '❌ Login Gagal',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ========================================
  // SIGN OUT
  // ========================================
  Future<void> signOut() async {
    try {
      isLoading.value = true;

      print('\n🚪 Signing out...');

      // Sign out from Supabase
      await _supabaseService.signOut();

      // Clear local storage (but keep remember me if enabled)
      await LocalStorageService.clearUserData();
      
      if (!rememberMe.value) {
        await LocalStorageService.clearSavedCredentials();
      }

      Get.snackbar(
        '✅ Logout Berhasil',
        'Sampai jumpa lagi!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Navigate to login
      Get.offAllNamed('/login');
    } catch (e) {
      print('❌ Sign out error: $e');
      
      Get.snackbar(
        '❌ Logout Gagal',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========================================
  // FORGOT PASSWORD
  // ========================================
  Future<bool> resetPassword(String email) async {
    try {
      isLoading.value = true;

      if (email.isEmpty) {
        throw Exception('Email tidak boleh kosong');
      }

      print('\n📧 Sending password reset email to: $email');

      await _supabaseService.resetPassword(email);

      Get.snackbar(
        '✅ Email Terkirim',
        'Link reset password telah dikirim ke $email',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      return true;
    } catch (e) {
      print('❌ Reset password error: $e');
      
      Get.snackbar(
        '❌ Gagal Mengirim Email',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ========================================
  // CHANGE PASSWORD
  // ========================================
  Future<bool> changePassword(String newPassword) async {
    try {
      isLoading.value = true;

      print('\n🔑 Changing password...');

      await _supabaseService.updatePassword(newPassword);

      Get.snackbar(
        '✅ Password Diubah',
        'Password berhasil diperbarui',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      return true;
    } catch (e) {
      print('❌ Change password error: $e');
      
      Get.snackbar(
        '❌ Gagal Mengubah Password',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ========================================
  // UPDATE PROFILE
  // ========================================
  Future<void> updateProfile({
    String? username,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    try {
      if (currentUser.value == null) {
        throw Exception('No user logged in');
      }

      isLoading.value = true;

      print('\n✏️ Updating profile...');

      final uid = currentUser.value!.id;

      // Update in Supabase
      await _supabaseService.updateUserProfile(
        uid: uid,
        username: username,
        phoneNumber: phoneNumber,
        photoUrl: photoUrl,
      );

      // Update local user model
      currentUser.value = currentUser.value!.copyWith(
        username: username ?? currentUser.value!.username,
        phoneNumber: phoneNumber ?? currentUser.value!.phoneNumber,
        photoUrl: photoUrl ?? currentUser.value!.photoUrl,
      );

      // Update local storage
      await LocalStorageService.setUserData(currentUser.value!.toJson());
      await LocalStorageService.setUsername(currentUser.value!.username);

      Get.snackbar(
        '✅ Profil Diperbarui',
        'Data profil berhasil diperbarui',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Update profile error: $e');
      
      Get.snackbar(
        '❌ Update Gagal',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========================================
  // REMEMBER ME
  // ========================================
  
  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
    LocalStorageService.setRememberMe(rememberMe.value);
  }

  void loadRememberMe() {
    rememberMe.value = LocalStorageService.getRememberMe();
  }

  Map<String, String> getSavedCredentials() {
    if (LocalStorageService.getRememberMe()) {
      return LocalStorageService.getSavedCredentials();
    }
    return {'email': '', 'password': ''};
  }

  // ========================================
  // UTILITY METHODS
  // ========================================

  Map<String, dynamic> getStorageInfo() {
    return LocalStorageService.getStorageInfo();
  }

  void printStorageInfo() {
    LocalStorageService.printAllKeys();
  }

  Future<void> clearAllData() async {
    try {
      await LocalStorageService.clearAll();
      
      isLoggedIn.value = false;
      currentUser.value = null;
      rememberMe.value = false;

      Get.snackbar(
        '✅ Data Dihapus',
        'Semua data lokal telah dihapus',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );

      Get.offAllNamed('/login');
    } catch (e) {
      print('❌ Clear data error: $e');
    }
  }
}