import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../models/note_model.dart';

// ============================================
// SUPABASE SERVICE - AUTHENTICATION & DATABASE
// ============================================
class SupabaseService {
  // Supabase client
  final SupabaseClient _supabase = Supabase.instance.client;

  // Table names
  final String _usersTable = 'users';
  final String _notesTable = 'notes';
  final String _imagesBucket = 'profile-images';
  final String _serviceImagesBucket = 'service-images';  // 🆕 NEW: Bucket for service images

  // ========================================
  // AUTHENTICATION
  // ========================================

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => _supabase.auth.currentUser != null;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      print('🔥 [Supabase] Signing up with email: $email');

      // Sign up with Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      if (response.user != null) {
        // Create user profile in database
        await _createUserProfile(
          uid: response.user!.id,
          email: email,
          username: username,
        );
      }

      print('✅ [Supabase] Sign up successful');
      return response;
    } catch (e) {
      print('❌ [Supabase] Sign up error: $e');
      throw _handleSupabaseException(e);
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      print('🔥 [Supabase] Signing in with email: $email');

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Update last login
      if (response.user != null) {
        await _updateLastLogin(response.user!.id);
      }

      print('✅ [Supabase] Sign in successful');
      return response;
    } catch (e) {
      print('❌ [Supabase] Sign in error: $e');
      throw _handleSupabaseException(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      print('🔥 [Supabase] Signing out');
      await _supabase.auth.signOut();
      print('✅ [Supabase] Sign out successful');
    } catch (e) {
      print('❌ [Supabase] Sign out error: $e');
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      print('🔥 [Supabase] Sending password reset email to: $email');
      
      await _supabase.auth.resetPasswordForEmail(email);

      print('✅ [Supabase] Password reset email sent');
    } catch (e) {
      print('❌ [Supabase] Password reset error: $e');
      throw _handleSupabaseException(e);
    }
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      print('🔥 [Supabase] Updating password');

      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      print('✅ [Supabase] Password updated successfully');
    } catch (e) {
      print('❌ [Supabase] Update password error: $e');
      throw _handleSupabaseException(e);
    }
  }

  // ========================================
  // USER PROFILE MANAGEMENT
  // ========================================

  /// Create user profile in database
  Future<void> _createUserProfile({
    required String uid,
    required String email,
    required String username,
    String? photoUrl,
  }) async {
    try {
      print('🔥 [Supabase] Creating user profile for: $uid');

      final now = DateTime.now().toUtc();
      await _supabase.from(_usersTable).insert({
        'id': uid,
        'email': email,
        'username': username,
        'photo_url': photoUrl,
        'created_at': now.toIso8601String(),
        'last_login': now.toIso8601String(),
      });

      print('✅ [Supabase] User profile created');
    } catch (e) {
      print('❌ [Supabase] Create profile error: $e');
      throw Exception('Failed to create user profile: $e');
    }
  }

  /// Update last login
  Future<void> _updateLastLogin(String uid) async {
    try {
      await _supabase.from(_usersTable).update({
        'last_login': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', uid);
    } catch (e) {
      print('⚠️ [Supabase] Update last login error: $e');
    }
  }

  /// Get user profile
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      print('🔥 [Supabase] Getting user profile for: $uid');

      final response = await _supabase
          .from(_usersTable)
          .select()
          .eq('id', uid)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('❌ [Supabase] Get user profile error: $e');
      return null;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? username,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    try {
      print('🔥 [Supabase] Updating user profile: $uid');

      final updates = <String, dynamic>{};
      if (username != null) updates['username'] = username;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (photoUrl != null) updates['photo_url'] = photoUrl;

      if (updates.isEmpty) return;

      await _supabase.from(_usersTable).update(updates).eq('id', uid);

      print('✅ [Supabase] User profile updated');
    } catch (e) {
      print('❌ [Supabase] Update profile error: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Stream user profile (real-time)
  Stream<UserModel?> streamUserProfile(String uid) {
    return _supabase
        .from(_usersTable)
        .stream(primaryKey: ['id'])
        .eq('id', uid)
        .map((data) {
          if (data.isEmpty) return null;
          return UserModel.fromJson(data.first);
        });
  }

  // ========================================
  // NOTES MANAGEMENT
  // ========================================

  /// Get all notes for current user
  Future<List<NoteModel>> getNotes() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      print('🔥 [Supabase] Fetching notes for user: $userId');

      final response = await _supabase
          .from(_notesTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final notes = (response as List)
          .map((json) => NoteModel.fromJson(json))
          .toList();

      print('✅ [Supabase] Loaded ${notes.length} notes');
      return notes;
    } catch (e) {
      print('❌ [Supabase] Get notes error: $e');
      throw Exception('Failed to get notes: $e');
    }
  }

  /// Create new note
  Future<NoteModel> createNote({
    required String title,
    required String content,
  }) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      print('🔥 [Supabase] Creating note');

      final now = DateTime.now().toUtc();
      final noteData = {
        'user_id': userId,
        'title': title,
        'content': content,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final response = await _supabase
          .from(_notesTable)
          .insert(noteData)
          .select()
          .single();

      print('✅ [Supabase] Note created');
      return NoteModel.fromJson(response);
    } catch (e) {
      print('❌ [Supabase] Create note error: $e');
      throw Exception('Failed to create note: $e');
    }
  }

  /// Update note
  Future<void> updateNote({
    required String noteId,
    String? title,
    String? content,
  }) async {
    try {
      print('🔥 [Supabase] Updating note: $noteId');

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
      if (title != null) updates['title'] = title;
      if (content != null) updates['content'] = content;

      await _supabase.from(_notesTable).update(updates).eq('id', noteId);

      print('✅ [Supabase] Note updated');
    } catch (e) {
      print('❌ [Supabase] Update note error: $e');
      throw Exception('Failed to update note: $e');
    }
  }

  /// Delete note
  Future<void> deleteNote(String noteId) async {
    try {
      print('🔥 [Supabase] Deleting note: $noteId');

      await _supabase.from(_notesTable).delete().eq('id', noteId);

      print('✅ [Supabase] Note deleted');
    } catch (e) {
      print('❌ [Supabase] Delete note error: $e');
      throw Exception('Failed to delete note: $e');
    }
  }

  /// Stream notes (real-time)
  Stream<List<NoteModel>> streamNotes() {
    final userId = currentUser?.id;
    if (userId == null) return Stream.value([]);

    return _supabase
        .from(_notesTable)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) {
          return data.map((json) => NoteModel.fromJson(json)).toList();
        });
  }

  // ========================================
  // IMAGE UPLOAD
  // ========================================

  /// Upload profile image
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      print('🔥 [Supabase] Uploading profile image');

      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$userId/$fileName';

      // Upload to Supabase Storage
      await _supabase.storage.from(_imagesBucket).upload(
            path,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // Get public URL
      final imageUrl = _supabase.storage.from(_imagesBucket).getPublicUrl(path);

      print('✅ [Supabase] Image uploaded: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('❌ [Supabase] Upload image error: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete profile image
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      print('🔥 [Supabase] Deleting profile image');

      // Extract path from URL
      final uri = Uri.parse(imageUrl);
      final path = uri.pathSegments.last;

      await _supabase.storage.from(_imagesBucket).remove([path]);

      print('✅ [Supabase] Image deleted');
    } catch (e) {
      print('❌ [Supabase] Delete image error: $e');
      throw Exception('Failed to delete image: $e');
    }
  }

  // ========================================
  // SERVICE IMAGE STORAGE (NEW!)
  // ========================================

  /// Upload service image to Supabase Storage
  /// Returns the public URL of the uploaded image
  Future<String> uploadServiceImage(File imageFile) async {
    try {
      print('📤 [Supabase] Uploading service image...');

      // Generate unique filename
      final fileName = 'service_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'services/$fileName';

      // Upload file to storage
      await _supabase.storage.from(_serviceImagesBucket).upload(
        path,
        imageFile,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: false,
        ),
      );

      // Get public URL
      final imageUrl = _supabase.storage.from(_serviceImagesBucket).getPublicUrl(path);

      print('✅ [Supabase] Service image uploaded: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('❌ [Supabase] Upload service image error: $e');
      throw Exception('Failed to upload service image: $e');
    }
  }

  /// Delete service image from Supabase Storage
  Future<void> deleteServiceImage(String imageUrl) async {
    try {
      print('🗑️ [Supabase] Deleting service image...');

      // Extract path from URL
      final uri = Uri.parse(imageUrl);
      final path = uri.pathSegments.skip(5).join('/'); // Skip bucket prefix

      // Delete file from storage
      await _supabase.storage.from(_serviceImagesBucket).remove([path]);

      print('✅ [Supabase] Service image deleted');
    } catch (e) {
      print('❌ [Supabase] Delete service image error: $e');
      throw Exception('Failed to delete service image: $e');
    }
  }

  // ========================================
  // ERROR HANDLING
  // ========================================

  Exception _handleSupabaseException(dynamic e) {
    String message;

    if (e is AuthException) {
      switch (e.statusCode) {
        case '400':
          message = 'Email atau password tidak valid';
          break;
        case '422':
          message = 'Email sudah terdaftar';
          break;
        default:
          message = e.message;
      }
    } else if (e is PostgrestException) {
      message = 'Database error: ${e.message}';
    } else {
      message = 'Terjadi kesalahan: $e';
    }

    return Exception(message);
  }
}