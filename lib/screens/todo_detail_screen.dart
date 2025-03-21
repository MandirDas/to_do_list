import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/todo.dart';
import '../utils/priority.dart';
import '../utils/date_formatter.dart';
import '../controllers/todo_controller.dart';
import 'todo_form_screen.dart';

class TodoDetailScreen extends StatelessWidget {
  final Todo todo;

  const TodoDetailScreen({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TodoController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Get.to(() => TodoFormScreen(todo: todo));
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () {
              _showDeleteConfirmation(context, controller);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    todo.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _buildStatusChip(),
              ],
            ),
            const SizedBox(height: 20),

            // Priority indicator
            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              color: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Due date
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.calendar_today_rounded,
                            color: theme.colorScheme.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Due Date',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormatter.formatDateTime(todo.dueDate),
                                style: TextStyle(
                                  color: _getDueDateColor(
                                      todo.dueDate, todo.isCompleted),
                                  fontWeight:
                                      DateFormatter.isOverdue(todo.dueDate) &&
                                              !todo.isCompleted
                                          ? FontWeight.bold
                                          : null,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Created at
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.access_time_rounded,
                            color: theme.colorScheme.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Created',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormatter.formatDateTime(todo.createdAt),
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Priority
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getPriorityIcon(todo.priority),
                            color: Priority.priorityColor(todo.priority),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Priority',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                Priority.priorityText(todo.priority),
                                style: TextStyle(
                                  color: Priority.priorityColor(todo.priority),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
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
            const SizedBox(height: 24),

            // Description
            const Text(
              'Description',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2)),
              ),
              child: Text(
                todo.description.isEmpty
                    ? 'No description provided'
                    : todo.description,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  fontStyle: todo.description.isEmpty ? FontStyle.italic : null,
                  color: todo.description.isEmpty
                      ? theme.colorScheme.onSurface.withOpacity(0.6)
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Toggle Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.toggleTodoStatus(todo);
                  Get.back();
                },
                icon: Icon(todo.isCompleted
                    ? Icons.refresh
                    : Icons.check_circle_outline_rounded),
                label: Text(
                  todo.isCompleted ? 'Mark as Incomplete' : 'Mark as Complete',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: todo.isCompleted
                      ? Colors.orange
                      : theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Chip(
      label: Text(
        _getStatusText(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      backgroundColor: _getStatusColor(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  String _getStatusText() {
    if (todo.isCompleted) {
      return 'Completed';
    } else if (DateFormatter.isOverdue(todo.dueDate)) {
      return 'Overdue';
    } else if (DateFormatter.isDueSoon(todo.dueDate)) {
      return 'Due Soon';
    } else {
      return 'Pending';
    }
  }

  Color _getStatusColor() {
    if (todo.isCompleted) {
      return Colors.green;
    } else if (DateFormatter.isOverdue(todo.dueDate)) {
      return Colors.red;
    } else if (DateFormatter.isDueSoon(todo.dueDate)) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  IconData _getPriorityIcon(int priority) {
    switch (priority) {
      case Priority.LOW:
        return Icons.arrow_downward_rounded;
      case Priority.MEDIUM:
        return Icons.remove_rounded;
      case Priority.HIGH:
        return Icons.arrow_upward_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Color _getDueDateColor(DateTime dueDate, bool isCompleted) {
    if (isCompleted) {
      return Colors.grey;
    } else if (DateFormatter.isOverdue(dueDate)) {
      return Colors.red;
    } else if (DateFormatter.isDueSoon(dueDate)) {
      return Colors.orange;
    } else {
      return Colors.black87;
    }
  }

  void _showDeleteConfirmation(
      BuildContext context, TodoController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                controller.deleteTodo(todo.id!);
                Get.back();
                Get.back();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}
