import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/supabase_service.dart';
import '../models/note_model.dart';

// ============================================
// NOTE CONTROLLER - SUPABASE NOTES
// ============================================
class NoteController extends GetxController {
  final _supabaseService = SupabaseService();

  // Observable variables
  var isLoading = false.obs;
  var notes = <NoteModel>[].obs;
  var selectedNote = Rxn<NoteModel>();

  @override
  void onInit() {
    super.onInit();
    fetchAllNotes();
    listenToNotes();
  }

  // ========================================
  // FETCH ALL NOTES
  // ========================================
  Future<void> fetchAllNotes() async {
    try {
      isLoading.value = true;
      print('🔥 [Supabase] Fetching all notes...');

      final result = await _supabaseService.getNotes();
      notes.value = result;

      print('✅ [Supabase] Loaded ${result.length} notes');

      Get.snackbar(
        '✅ Success',
        'Loaded ${result.length} notes',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ [Supabase] Error: $e');
      
      Get.snackbar(
        '❌ Error',
        'Failed to load notes: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========================================
  // CREATE NOTE
  // ========================================
  Future<void> createNote({
    required String title,
    required String content,
  }) async {
    try {
      isLoading.value = true;
      print('🔥 [Supabase] Creating note...');

      final newNote = await _supabaseService.createNote(
        title: title,
        content: content,
      );

      notes.insert(0, newNote);

      print('✅ [Supabase] Note created: ${newNote.title}');

      Get.snackbar(
        '✅ Success',
        'Note created: ${newNote.title}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ [Supabase] Error: $e');
      
      Get.snackbar(
        '❌ Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========================================
  // UPDATE NOTE
  // ========================================
  Future<void> updateNote({
    required String noteId,
    String? title,
    String? content,
  }) async {
    try {
      isLoading.value = true;
      print('🔥 [Supabase] Updating note...');

      await _supabaseService.updateNote(
        noteId: noteId,
        title: title,
        content: content,
      );

      // Update local list
      final index = notes.indexWhere((n) => n.id == noteId);
      if (index != -1) {
        notes[index] = notes[index].copyWith(
          title: title ?? notes[index].title,
          content: content ?? notes[index].content,
          updatedAt: DateTime.now(),
        );
      }

      print('✅ [Supabase] Note updated');

      Get.snackbar(
        '✅ Success',
        'Note updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ [Supabase] Error: $e');
      
      Get.snackbar(
        '❌ Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========================================
  // DELETE NOTE
  // ========================================
  Future<void> deleteNote(String noteId) async {
    try {
      isLoading.value = true;
      print('🔥 [Supabase] Deleting note...');

      await _supabaseService.deleteNote(noteId);

      // Remove from local list
      notes.removeWhere((note) => note.id == noteId);

      print('✅ [Supabase] Note deleted');

      Get.snackbar(
        '✅ Success',
        'Note deleted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ [Supabase] Error: $e');
      
      Get.snackbar(
        '❌ Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========================================
  // LISTEN TO NOTES (REAL-TIME)
  // ========================================
  void listenToNotes() {
    print('🔥 [Supabase] Listening to notes (real-time)...');
    
    _supabaseService.streamNotes().listen((notesList) {
      notes.value = notesList;
      print('🔄 [Supabase] Notes updated: ${notesList.length} items');
    }, onError: (error) {
      print('❌ [Supabase] Stream error: $error');
    });
  }

  // ========================================
  // REFRESH
  // ========================================
  Future<void> refresh() async {
    await fetchAllNotes();
  }

  // ========================================
  // SELECT NOTE
  // ========================================
  void selectNote(NoteModel note) {
    selectedNote.value = note;
  }

  void clearSelection() {
    selectedNote.value = null;
  }
}