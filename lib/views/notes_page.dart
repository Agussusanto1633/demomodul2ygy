import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/note_controller.dart';
import '../models/note_model.dart';

// ============================================
// NOTES PAGE - SUPABASE CLOUD STORAGE
// ============================================
class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final noteController = Get.find<NoteController>();

    // ✅ DETECT DARK MODE
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ ADAPTIVE COLORS
    final bottomNavBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final bottomNavSelected = isDark ? const Color(0xFF64B5F6) : const Color(0xFF455A64);
    final bottomNavUnselected = isDark ? const Color(0xFF78909C) : Colors.grey;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offNamed('/home'),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('My Notes'),
            Text(
              'Stored in Supabase',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => noteController.refresh(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (noteController.isLoading.value && noteController.notes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (noteController.notes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.note_alt_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 20),
                Text(
                  'No notes yet',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Text(
                  'Tap + to create your first note',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => noteController.refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: noteController.notes.length,
            itemBuilder: (context, index) {
              final note = noteController.notes[index];
              return _NoteCard(note: note);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddNoteDialog(context, noteController),
        icon: const Icon(Icons.add),
        label: const Text('Add Note'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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
              Get.offAllNamed('/home');
              break;
            case 1:
              Get.offAllNamed('/crud-test');
              break;
            case 2:
              // Already on Notes
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
    );
  }

  void _showAddNoteDialog(BuildContext context, NoteController controller) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('New Note'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter note title',
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Enter note content',
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  contentController.text.isNotEmpty) {
                controller.createNote(
                  title: titleController.text,
                  content: contentController.text,
                );
                Get.back();
              } else {
                Get.snackbar(
                  'Error',
                  'Please fill all fields',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

// ============================================
// NOTE CARD WIDGET
// ============================================
class _NoteCard extends StatelessWidget {
  final NoteModel note;

  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final noteController = Get.find<NoteController>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showNoteDetailDialog(context, note, noteController),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _showDeleteConfirmation(
                      context,
                      note,
                      noteController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.preview,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    note.formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud,
                          size: 14,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Supabase',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNoteDetailDialog(
    BuildContext context,
    NoteModel note,
    NoteController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: Text(note.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(note.content),
              const SizedBox(height: 16),
              Text(
                'Created: ${note.formattedDate}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showEditNoteDialog(context, note, controller);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _showEditNoteDialog(
    BuildContext context,
    NoteModel note,
    NoteController controller,
  ) {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Note'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.updateNote(
                noteId: note.id,
                title: titleController.text,
                content: contentController.text,
              );
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    NoteModel note,
    NoteController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await controller.deleteNote(note.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}