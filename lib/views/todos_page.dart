import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/todo_controller.dart';
import '../models/todo_model.dart';

// ============================================
// TODOS PAGE - HIVE LOCAL STORAGE
// ============================================
class TodosPage extends StatelessWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final todoController = Get.find<TodoController>();

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Todos'),
            Obx(() => Text(
                  'Hive Local Storage • ${todoController.totalCount} items',
                  style: const TextStyle(fontSize: 12),
                )),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, todoController),
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _showClearAllConfirmation(context, todoController),
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Card
          _StatisticsCard(),
          
          // Todos List
          Expanded(
            child: Obx(() {
              if (todoController.isLoading.value &&
                  todoController.todos.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final filteredTodos = todoController.filteredTodos;

              if (filteredTodos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_alt,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No todos yet',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tap + to create your first todo',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredTodos.length,
                itemBuilder: (context, index) {
                  final todo = filteredTodos[index];
                  return _TodoCard(todo: todo);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTodoDialog(context, todoController),
        icon: const Icon(Icons.add),
        label: const Text('Add Todo'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
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
              Get.offAllNamed('/notes');
              break;
            case 3:
              // Already on Todos
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

  void _showAddTodoDialog(BuildContext context, TodoController controller) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('New Todo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter todo title',
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter description (optional)',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
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
              if (titleController.text.isNotEmpty) {
                controller.createTodo(
                  title: titleController.text,
                  description: descriptionController.text,
                );
                Get.back();
              } else {
                Get.snackbar(
                  'Error',
                  'Please enter a title',
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

  void _showFilterDialog(BuildContext context, TodoController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Filter Todos'),
        content: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: const Text('Show Completed'),
                  value: controller.showCompleted.value,
                  onChanged: (value) => controller.toggleShowCompleted(),
                ),
                CheckboxListTile(
                  title: const Text('Show Pending'),
                  value: controller.showPending.value,
                  onChanged: (value) => controller.toggleShowPending(),
                ),
              ],
            )),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showClearAllConfirmation(
      BuildContext context, TodoController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear All Todos'),
        content: const Text(
            'Are you sure you want to delete all todos? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.clearAllTodos();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

// ============================================
// STATISTICS CARD
// ============================================
class _StatisticsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final todoController = Get.find<TodoController>();

    return Obx(() => Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.purple.shade700],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    icon: Icons.list,
                    label: 'Total',
                    value: todoController.totalCount.toString(),
                  ),
                  _StatItem(
                    icon: Icons.check_circle,
                    label: 'Completed',
                    value: todoController.completedCount.toString(),
                  ),
                  _StatItem(
                    icon: Icons.pending,
                    label: 'Pending',
                    value: todoController.pendingCount.toString(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: todoController.completionRate / 100,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${todoController.completionRate.toStringAsFixed(1)}% Completed',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ));
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ============================================
// TODO CARD WIDGET
// ============================================
class _TodoCard extends StatelessWidget {
  final TodoModel todo;

  const _TodoCard({required this.todo});

  @override
  Widget build(BuildContext context) {
    final todoController = Get.find<TodoController>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (value) => todoController.toggleCompletion(todo.id),
          activeColor: Colors.green,
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: todo.isCompleted ? Colors.grey : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                todo.description,
                style: TextStyle(
                  color: todo.isCompleted ? Colors.grey : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  todo.formattedDate,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.storage,
                        size: 10,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Hive',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.orange.shade700,
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
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
              onTap: () {
                Future.delayed(
                  const Duration(milliseconds: 100),
                  () => _showEditTodoDialog(context, todo, todoController),
                );
              },
            ),
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
              onTap: () {
                Future.delayed(
                  const Duration(milliseconds: 100),
                  () => _showDeleteConfirmation(context, todo, todoController),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTodoDialog(
    BuildContext context,
    TodoModel todo,
    TodoController controller,
  ) {
    final titleController = TextEditingController(text: todo.title);
    final descriptionController =
        TextEditingController(text: todo.description);

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Todo'),
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
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
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
              controller.updateTodo(
                todo: todo,
                title: titleController.text,
                description: descriptionController.text,
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
    TodoModel todo,
    TodoController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Todo'),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteTodo(todo);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}