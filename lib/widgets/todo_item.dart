import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../utils/priority.dart';
import '../utils/date_formatter.dart';
import '../controllers/todo_controller.dart';
import 'package:get/get.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onTap;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TodoController>();
    final isOverdue =
        DateFormatter.isOverdue(todo.dueDate) && !todo.isCompleted;
    final isDueSoon =
        DateFormatter.isDueSoon(todo.dueDate) && !todo.isCompleted;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isOverdue
              ? Colors.red
              : isDueSoon
                  ? Colors.orange
                  : Colors.transparent,
          width: isOverdue || isDueSoon ? 1.5 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: todo.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: todo.isCompleted ? Colors.grey : null,
                      ),
                    ),
                  ),
                  Priority.priorityIcon(todo.priority),
                ],
              ),
              if (todo.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  todo.description,
                  style: TextStyle(
                    color: todo.isCompleted ? Colors.grey : null,
                    decoration:
                        todo.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: isOverdue
                            ? Colors.red
                            : isDueSoon
                                ? Colors.orange
                                : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.formatDueDate(todo.dueDate),
                        style: TextStyle(
                          color: isOverdue
                              ? Colors.red
                              : isDueSoon
                                  ? Colors.orange
                                  : Colors.grey,
                          fontWeight: isOverdue || isDueSoon
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  Checkbox(
                    value: todo.isCompleted,
                    onChanged: (bool? value) {
                      controller.toggleTodoStatus(todo);
                    },
                    activeColor: Priority.priorityColor(todo.priority),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
