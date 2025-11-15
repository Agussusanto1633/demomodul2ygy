import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo_model.dart';

// ============================================
// HIVE SERVICE - LOCAL TODO STORAGE
// ============================================
class HiveService {
  static const String _todoBoxName = 'todos';
  static Box<TodoModel>? _todoBox;

  // ========================================
  // INITIALIZATION
  // ========================================

  /// Initialize Hive
  static Future<void> init() async {
    try {
      print('📦 [Hive] Initializing Hive...');

      // Initialize Hive Flutter
      await Hive.initFlutter();

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TodoModelAdapter());
      }

      // Open boxes
      _todoBox = await Hive.openBox<TodoModel>(_todoBoxName);

      print('✅ [Hive] Hive initialized successfully');
      print('📊 [Hive] Todos in storage: ${_todoBox?.length ?? 0}');
    } catch (e) {
      print('❌ [Hive] Initialization error: $e');
      throw Exception('Failed to initialize Hive: $e');
    }
  }

  /// Get todo box
  static Box<TodoModel> get todoBox {
    if (_todoBox == null || !_todoBox!.isOpen) {
      throw Exception('Todo box is not initialized. Call init() first.');
    }
    return _todoBox!;
  }

  // ========================================
  // TODO CRUD OPERATIONS
  // ========================================

  /// Get all todos
  static List<TodoModel> getAllTodos() {
    try {
      return todoBox.values.toList();
    } catch (e) {
      print('❌ [Hive] Get all todos error: $e');
      return [];
    }
  }

  /// Get todo by ID
  static TodoModel? getTodoById(String id) {
    try {
      return todoBox.values.firstWhere(
        (todo) => todo.id == id,
        orElse: () => throw Exception('Todo not found'),
      );
    } catch (e) {
      print('❌ [Hive] Get todo by ID error: $e');
      return null;
    }
  }

  /// Add new todo
  static Future<void> addTodo(TodoModel todo) async {
    try {
      print('📦 [Hive] Adding todo: ${todo.title}');
      await todoBox.add(todo);
      print('✅ [Hive] Todo added successfully');
    } catch (e) {
      print('❌ [Hive] Add todo error: $e');
      throw Exception('Failed to add todo: $e');
    }
  }

  /// Update todo
  static Future<void> updateTodo(TodoModel todo) async {
    try {
      print('📦 [Hive] Updating todo: ${todo.title}');
      await todo.save();
      print('✅ [Hive] Todo updated successfully');
    } catch (e) {
      print('❌ [Hive] Update todo error: $e');
      throw Exception('Failed to update todo: $e');
    }
  }

  /// Delete todo
  static Future<void> deleteTodo(TodoModel todo) async {
    try {
      print('📦 [Hive] Deleting todo: ${todo.title}');
      await todo.delete();
      print('✅ [Hive] Todo deleted successfully');
    } catch (e) {
      print('❌ [Hive] Delete todo error: $e');
      throw Exception('Failed to delete todo: $e');
    }
  }

  /// Delete todo by ID
  static Future<void> deleteTodoById(String id) async {
    try {
      final todo = getTodoById(id);
      if (todo != null) {
        await deleteTodo(todo);
      }
    } catch (e) {
      print('❌ [Hive] Delete todo by ID error: $e');
      throw Exception('Failed to delete todo: $e');
    }
  }

  /// Toggle todo completion
  static Future<void> toggleTodoCompletion(String id) async {
    try {
      final todo = getTodoById(id);
      if (todo != null) {
        todo.toggleComplete();
        print('✅ [Hive] Todo completion toggled');
      }
    } catch (e) {
      print('❌ [Hive] Toggle completion error: $e');
      throw Exception('Failed to toggle completion: $e');
    }
  }

  /// Clear all todos
  static Future<void> clearAllTodos() async {
    try {
      print('📦 [Hive] Clearing all todos');
      await todoBox.clear();
      print('✅ [Hive] All todos cleared');
    } catch (e) {
      print('❌ [Hive] Clear all todos error: $e');
      throw Exception('Failed to clear todos: $e');
    }
  }

  // ========================================
  // QUERY OPERATIONS
  // ========================================

  /// Get completed todos
  static List<TodoModel> getCompletedTodos() {
    try {
      return todoBox.values.where((todo) => todo.isCompleted).toList();
    } catch (e) {
      print('❌ [Hive] Get completed todos error: $e');
      return [];
    }
  }

  /// Get pending todos
  static List<TodoModel> getPendingTodos() {
    try {
      return todoBox.values.where((todo) => !todo.isCompleted).toList();
    } catch (e) {
      print('❌ [Hive] Get pending todos error: $e');
      return [];
    }
  }

  /// Get todos count
  static int getTodosCount() {
    return todoBox.length;
  }

  /// Get completed todos count
  static int getCompletedTodosCount() {
    return todoBox.values.where((todo) => todo.isCompleted).length;
  }

  /// Get pending todos count
  static int getPendingTodosCount() {
    return todoBox.values.where((todo) => !todo.isCompleted).length;
  }

  // ========================================
  // STREAM OPERATIONS
  // ========================================

  /// Watch todos (real-time updates)
  static Stream<List<TodoModel>> watchTodos() {
    return todoBox.watch().map((_) => getAllTodos());
  }

  /// Watch completed todos count
  static Stream<int> watchCompletedCount() {
    return todoBox.watch().map((_) => getCompletedTodosCount());
  }

  /// Watch pending todos count
  static Stream<int> watchPendingCount() {
    return todoBox.watch().map((_) => getPendingTodosCount());
  }

  // ========================================
  // UTILITY METHODS
  // ========================================

  /// Check if todo exists
  static bool todoExists(String id) {
    return todoBox.values.any((todo) => todo.id == id);
  }

  /// Get storage info
  static Map<String, dynamic> getStorageInfo() {
    return {
      'totalTodos': getTodosCount(),
      'completedTodos': getCompletedTodosCount(),
      'pendingTodos': getPendingTodosCount(),
      'boxIsOpen': _todoBox?.isOpen ?? false,
    };
  }

  /// Print all todos (debug)
  static void printAllTodos() {
    print('\n📋 All Todos in Hive:');
    print('═' * 50);
    if (todoBox.isEmpty) {
      print('(No todos)');
    } else {
      for (var todo in todoBox.values) {
        print('${todo.isCompleted ? "✅" : "⏳"} ${todo.title}');
        print('   ${todo.description}');
        print('   Created: ${todo.formattedDate}');
        print('─' * 50);
      }
    }
    print('═' * 50);
    print('Total: ${getTodosCount()} | Completed: ${getCompletedTodosCount()} | Pending: ${getPendingTodosCount()}\n');
  }

  // ========================================
  // CLEANUP
  // ========================================

  /// Close all boxes
  static Future<void> close() async {
    try {
      await _todoBox?.close();
      print('✅ [Hive] Boxes closed');
    } catch (e) {
      print('❌ [Hive] Close error: $e');
    }
  }

  /// Compact database
  static Future<void> compact() async {
    try {
      await todoBox.compact();
      print('✅ [Hive] Database compacted');
    } catch (e) {
      print('❌ [Hive] Compact error: $e');
    }
  }
}