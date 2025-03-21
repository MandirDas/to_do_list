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
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom App Bar
            SliverAppBar(
              // expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: theme.appBarTheme.backgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: const Text(
                  'My Tasks',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                    ),
                  ),
                ),
              ),

              actions: [
                IconButton(
                  icon: const Icon(Icons.sort_rounded, size: 28),
                  onPressed: () {
                    _showSortOptions(context, controller);
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    Get.to(() => const TodoFormScreen());
                  },
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),

            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        controller.setSearchQuery('');
                      },
                    ),
                  ),
                  onChanged: controller.setSearchQuery,
                ),
              ),
            ),

            // Filters
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Obx(() => Row(
                      children: [
                        _FilterChip(
                          label: 'All',
                          icon: Icons.calendar_view_day_rounded,
                          isSelected:
                              controller.sortCriteria.value == 'createdAt',
                          onSelected: (_) =>
                              controller.setSortCriteria('createdAt'),
                        ),
                        const SizedBox(width: 12),
                        _FilterChip(
                          label: 'Priority',
                          icon: Icons.priority_high_rounded,
                          isSelected:
                              controller.sortCriteria.value == 'priority',
                          onSelected: (_) =>
                              controller.setSortCriteria('priority'),
                        ),
                        const SizedBox(width: 12),
                        _FilterChip(
                          label: 'Due Date',
                          icon: Icons.event_rounded,
                          isSelected:
                              controller.sortCriteria.value == 'dueDate',
                          onSelected: (_) =>
                              controller.setSortCriteria('dueDate'),
                        ),
                      ],
                    )),
              ),
            ),

            // Todo list
            Obx(() {
              if (controller.isLoading.value) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (controller.filteredTodos.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.only(bottom: 80), // For FAB space
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final todo = controller.filteredTodos[index];
                      return TodoItem(
                        todo: todo,
                        onTap: () {
                          Get.to(() => TodoDetailScreen(todo: todo));
                        },
                      );
                    },
                    childCount: controller.filteredTodos.length,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/empty_task.png',
            height: 180,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.check_circle_outline_rounded,
              size: 120,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No tasks found',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a new task to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 40),
          // ElevatedButton.icon(
          //   onPressed: () {
          //     Get.to(() => const TodoFormScreen());
          //   },
          //   icon: const Icon(Icons.add_rounded),
          //   label: Center(child: const Text("Create Task")),
          // style: ElevatedButton.styleFrom(
          //   padding: const EdgeInsets.symmetric(
          //     horizontal: 24,
          //     vertical: 12,
          //   ),
          // ),
          // ),
          GestureDetector(
            onTap: () {
              Get.to(() => const TodoFormScreen());
            },
            child: Container(
              width: 200,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white),
                  Text("Create Task", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context, TodoController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
                margin: const EdgeInsets.only(bottom: 20),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.sort_rounded),
                    SizedBox(width: 12),
                    Text(
                      'Sort by',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Obx(() => _SortOption(
                    icon: Icons.access_time_rounded,
                    title: 'Created Date',
                    subtitle: 'Newest first',
                    isSelected: controller.sortCriteria.value == 'createdAt',
                    onTap: () {
                      controller.setSortCriteria('createdAt');
                      Navigator.pop(context);
                    },
                  )),
              Obx(() => _SortOption(
                    icon: Icons.low_priority_rounded,
                    title: 'Priority',
                    subtitle: 'High to low',
                    isSelected: controller.sortCriteria.value == 'priority',
                    onTap: () {
                      controller.setSortCriteria('priority');
                      Navigator.pop(context);
                    },
                  )),
              Obx(() => _SortOption(
                    icon: Icons.event_rounded,
                    title: 'Due Date',
                    subtitle: 'Upcoming first',
                    isSelected: controller.sortCriteria.value == 'dueDate',
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
  final IconData icon;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : null,
              fontWeight: isSelected ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: theme.chipTheme.backgroundColor,
      selectedColor: theme.colorScheme.primary,
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: isSelected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isSelected
            ? BorderSide.none
            : BorderSide(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? theme.colorScheme.primary : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : null,
          color: isSelected ? theme.colorScheme.primary : null,
        ),
      ),
      subtitle: Text(subtitle),
      selected: isSelected,
      trailing: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
