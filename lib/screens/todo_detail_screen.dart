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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Get.to(() => TodoFormScreen(todo: todo));
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmation(context, controller);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Expanded(
                  child: Text(
                    todo.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(),
              ],
            ),
            const SizedBox(height: 8),

            // Priority indicator
            Row(
              children: [
                const Text(
                  'Priority: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Chip(
                  label: Text(
                    Priority.priorityText(todo.priority),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Priority.priorityColor(todo.priority),
                  avatar: Icon(
                    _getPriorityIcon(todo.priority),
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Due date
            Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Due Date',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      DateFormatter.formatDateTime(todo.dueDate),
                      style: TextStyle(
                        color: _getDueDateColor(todo.dueDate, todo.isCompleted),
                        fontWeight: DateFormatter.isOverdue(todo.dueDate) &&
                                !todo.isCompleted
                            ? FontWeight.bold
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Created at
            Row(
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Created',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(DateFormatter.formatDateTime(todo.createdAt)),
                  ],
                ),
              ],
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
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                todo.description.isEmpty
                    ? 'No description provided'
                    : todo.description,
                style: TextStyle(
                  fontStyle: todo.description.isEmpty ? FontStyle.italic : null,
                  color: todo.description.isEmpty ? Colors.grey : null,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Toggle completion button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.toggleTodoStatus(todo);
                  Get.back();
                },
                icon: Icon(todo.isCompleted ? Icons.refresh : Icons.check),
                label: Text(
                  todo.isCompleted ? 'Mark as Incomplete' : 'Mark as Complete',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor:
                      todo.isCompleted ? Colors.orange : Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    if (todo.isCompleted) {
      return const Chip(
        label: Text(
          'Completed',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      );
    } else if (DateFormatter.isOverdue(todo.dueDate)) {
      return const Chip(
        label: Text(
          'Overdue',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      );
    } else if (DateFormatter.isDueSoon(todo.dueDate)) {
      return const Chip(
        label: Text(
          'Due Soon',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      );
    } else {
      return const Chip(
        label: Text(
          'Pending',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      );
    }
  }

  IconData _getPriorityIcon(int priority) {
    switch (priority) {
      case Priority.LOW:
        return Icons.arrow_downward;
      case Priority.MEDIUM:
        return Icons.remove;
      case Priority.HIGH:
        return Icons.arrow_upward;
      default:
        return Icons.help_outline;
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
      return Colors.black;
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
        );
      },
    );
  }
}
