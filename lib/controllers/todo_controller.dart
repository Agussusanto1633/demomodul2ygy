import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/hive_service.dart';
import '../models/todo_model.dart';

// ============================================
// TODO CONTROLLER - HIVE LOCAL STORAGE
// ============================================
class TodoController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var todos = <TodoModel>[].obs;
  var selectedTodo = Rxn<TodoModel>();
  
  // Filter
  var showCompleted = true.obs;
  var showPending = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadTodos();
    listenToTodos();
  }

  // ========================================
  // LOAD TODOS
  // ========================================
  void loadTodos() {
    try {
      isLoading.value = true;
      print('📦 [Hive] Loading todos...');

      final result = HiveService.getAllTodos();
      todos.value = result;

      print('✅ [Hive] Loaded ${result.length} todos');
    } catch (e) {
      print('❌ [Hive] Error: $e');
      
      Get.snackbar(
        '❌ Error',
        'Failed to load todos: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========================================
  // CREATE TODO
  // ========================================
  Future<void> createTodo({
    required String title,
    required String description,
  }) async {
    try {
      isLoading.value = true;
      print('📦 [Hive] Creating todo...');

      final newTodo = TodoModel.create(
        title: title,
        description: description,
      );

      await HiveService.addTodo(newTodo);
      
      // Reload todos
      loadTodos();

      print('✅ [Hive] Todo created: ${newTodo.title}');

      Get.snackbar(
        '✅ Success',
        'Todo created: ${newTodo.title}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('❌ [Hive] Error: $e');
      
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
  // UPDATE TODO
  // ========================================
  Future<void> updateTodo({
    required TodoModel todo,
    String? title,
    String? description,
  }) async {
    try {
      isLoading.value = true;
      print('📦 [Hive] Updating todo...');

      if (title != null) todo.title = title;
      if (description != null) todo.description = description;

      await HiveService.updateTodo(todo);
      
      // Reload todos
      loadTodos();

      print('✅ [Hive] Todo updated');

      Get.snackbar(
        '✅ Success',
        'Todo updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ [Hive] Error: $e');
      
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
  // DELETE TODO
  // ========================================
  Future<void> deleteTodo(TodoModel todo) async {
    try {
      isLoading.value = true;
      print('📦 [Hive] Deleting todo...');

      await HiveService.deleteTodo(todo);
      
      // Reload todos
      loadTodos();

      print('✅ [Hive] Todo deleted');

      Get.snackbar(
        '✅ Success',
        'Todo deleted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ [Hive] Error: $e');
      
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
  // TOGGLE COMPLETION
  // ========================================
  Future<void> toggleCompletion(String todoId) async {
    try {
      await HiveService.toggleTodoCompletion(todoId);
      
      // Reload todos
      loadTodos();

      print('✅ [Hive] Todo completion toggled');
    } catch (e) {
      print('❌ [Hive] Error: $e');
      
      Get.snackbar(
        '❌ Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ========================================
  // CLEAR ALL TODOS
  // ========================================
  Future<void> clearAllTodos() async {
    try {
      isLoading.value = true;
      
      await HiveService.clearAllTodos();
      todos.clear();

      Get.snackbar(
        '✅ Success',
        'All todos cleared',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ [Hive] Error: $e');
      
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
  // LISTEN TO TODOS (REAL-TIME)
  // ========================================
  void listenToTodos() {
    print('📦 [Hive] Listening to todos (real-time)...');
    
    HiveService.watchTodos().listen((todosList) {
      todos.value = todosList;
      print('🔄 [Hive] Todos updated: ${todosList.length} items');
    });
  }

  // ========================================
  // FILTERS
  // ========================================
  
  List<TodoModel> get filteredTodos {
    return todos.where((todo) {
      if (!showCompleted.value && todo.isCompleted) return false;
      if (!showPending.value && !todo.isCompleted) return false;
      return true;
    }).toList();
  }

  List<TodoModel> get completedTodos {
    return todos.where((todo) => todo.isCompleted).toList();
  }

  List<TodoModel> get pendingTodos {
    return todos.where((todo) => !todo.isCompleted).toList();
  }

  // ========================================
  // STATISTICS
  // ========================================
  
  int get totalCount => todos.length;
  int get completedCount => completedTodos.length;
  int get pendingCount => pendingTodos.length;
  
  double get completionRate {
    if (totalCount == 0) return 0.0;
    return (completedCount / totalCount) * 100;
  }

  // ========================================
  // TOGGLE FILTERS
  // ========================================
  
  void toggleShowCompleted() {
    showCompleted.value = !showCompleted.value;
  }

  void toggleShowPending() {
    showPending.value = !showPending.value;
  }

  // ========================================
  // SELECT TODO
  // ========================================
  
  void selectTodo(TodoModel todo) {
    selectedTodo.value = todo;
  }

  void clearSelection() {
    selectedTodo.value = null;
  }

  // ========================================
  // REFRESH
  // ========================================
  
  void refresh() {
    loadTodos();
  }

  // ========================================
  // PRINT DEBUG INFO
  // ========================================
  
  void printDebugInfo() {
    HiveService.printAllTodos();
  }
}