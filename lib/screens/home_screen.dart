import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/todo_controller.dart';
import '../widgets/todo_item.dart';
import '../screens/todo_form_screen.dart';
import '../screens/todo_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TodoController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              _showSortOptions(context, controller);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: controller.setSearchQuery,
            ),
          ),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() => Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      isSelected: controller.sortCriteria.value == 'createdAt',
                      onSelected: (_) =>
                          controller.setSortCriteria('createdAt'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Priority',
                      isSelected: controller.sortCriteria.value == 'priority',
                      onSelected: (_) => controller.setSortCriteria('priority'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Due Date',
                      isSelected: controller.sortCriteria.value == 'dueDate',
                      onSelected: (_) => controller.setSortCriteria('dueDate'),
                    ),
                  ],
                )),
          ),

          const SizedBox(height: 8),

          // Todo list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredTodos.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                itemCount: controller.filteredTodos.length,
                itemBuilder: (context, index) {
                  final todo = controller.filteredTodos[index];
                  return TodoItem(
                    todo: todo,
                    onTap: () {
                      Get.to(() => TodoDetailScreen(todo: todo));
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const TodoFormScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add a new task',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context, TodoController controller) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Sort by',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const Divider(),
              Obx(() => ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Created Date (newest first)'),
                    selected: controller.sortCriteria.value == 'createdAt',
                    onTap: () {
                      controller.setSortCriteria('createdAt');
                      Navigator.pop(context);
                    },
                  )),
              Obx(() => ListTile(
                    leading: const Icon(Icons.low_priority),
                    title: const Text('Priority (high to low)'),
                    selected: controller.sortCriteria.value == 'priority',
                    onTap: () {
                      controller.setSortCriteria('priority');
                      Navigator.pop(context);
                    },
                  )),
              Obx(() => ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Due Date (upcoming first)'),
                    selected: controller.sortCriteria.value == 'dueDate',
                    onTap: () {
                      controller.setSortCriteria('dueDate');
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.grey.shade200,
      selectedColor: Theme.of(context).colorScheme.primary,
      checkmarkColor: Colors.white,
    );
  }
}
