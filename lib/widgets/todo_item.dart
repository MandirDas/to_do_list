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
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: _getBorderColor(isOverdue, isDueSoon, theme),
            width: isOverdue || isDueSoon ? 1.5 : 0,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              if (todo.priority == Priority.HIGH && !todo.isCompleted)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Priority.priorityColor(todo.priority),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: const Icon(
                      Icons.priority_high_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildPriorityIndicator(todo.priority),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            todo.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              decoration: todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: todo.isCompleted
                                  ? Colors.grey
                                  : theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Transform.scale(
                          scale: 1.1,
                          child: Checkbox(
                            value: todo.isCompleted,
                            onChanged: (bool? value) {
                              controller.toggleTodoStatus(todo);
                            },
                            activeColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                    if (todo.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 32, right: 8),
                        child: Text(
                          todo.description,
                          style: TextStyle(
                            color:
                                todo.isCompleted ? Colors.grey : Colors.black87,
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            height: 1.3,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    SizedBox(height: todo.description.isNotEmpty ? 12 : 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 32),
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: _getDueDateIconColor(
                              isOverdue, isDueSoon, todo.isCompleted, theme),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            DateFormatter.formatDueDate(todo.dueDate),
                            style: TextStyle(
                              color: _getDueDateTextColor(isOverdue, isDueSoon,
                                  todo.isCompleted, theme),
                              fontWeight: isOverdue || isDueSoon
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(int priority) {
    final Color color = Priority.priorityColor(priority);

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Color _getBorderColor(bool isOverdue, bool isDueSoon, ThemeData theme) {
    if (isOverdue) return Colors.red.shade400;
    if (isDueSoon) return Colors.orange.shade400;
    if (todo.isCompleted) return Colors.grey.shade200;
    return Colors.transparent;
  }

  Color _getDueDateIconColor(
      bool isOverdue, bool isDueSoon, bool isCompleted, ThemeData theme) {
    if (isCompleted) return Colors.grey;
    if (isOverdue) return Colors.red.shade400;
    if (isDueSoon) return Colors.orange.shade400;
    return theme.colorScheme.primary;
  }

  Color _getDueDateTextColor(
      bool isOverdue, bool isDueSoon, bool isCompleted, ThemeData theme) {
    if (isCompleted) return Colors.grey;
    if (isOverdue) return Colors.red.shade700;
    if (isDueSoon) return Colors.orange.shade700;
    return Colors.grey.shade700;
  }
}
