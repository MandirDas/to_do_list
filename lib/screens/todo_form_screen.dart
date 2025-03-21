import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../controllers/todo_controller.dart';
import '../utils/priority.dart';

class TodoFormScreen extends StatefulWidget {
  final Todo? todo;

  const TodoFormScreen({super.key, this.todo});

  @override
  State<TodoFormScreen> createState() => _TodoFormScreenState();
}

class _TodoFormScreenState extends State<TodoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _dueDate;
  late TimeOfDay _dueTime;
  int _priority = Priority.MEDIUM;
  bool _isCompleted = false;

  final TodoController _todoController = Get.find<TodoController>();

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      _titleController.text = widget.todo!.title;
      _descriptionController.text = widget.todo!.description;
      _dueDate = widget.todo!.dueDate;
      _dueTime = TimeOfDay(
        hour: widget.todo!.dueDate.hour,
        minute: widget.todo!.dueDate.minute,
      );
      _priority = widget.todo!.priority;
      _isCompleted = widget.todo!.isCompleted;
    } else {
      // Create mode
      final now = DateTime.now();
      _dueDate =
          DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
      _dueTime = const TimeOfDay(hour: 12, minute: 0);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dueTime) {
      setState(() {
        _dueTime = picked;
      });
    }
  }

  DateTime _getFullDueDate() {
    return DateTime(
      _dueDate.year,
      _dueDate.month,
      _dueDate.day,
      _dueTime.hour,
      _dueTime.minute,
    );
  }

  void _saveTodo() {
    if (_formKey.currentState!.validate()) {
      final fullDueDate = _getFullDueDate();

      if (widget.todo == null) {
        // Create a new todo
        final newTodo = Todo(
          title: _titleController.text,
          description: _descriptionController.text,
          priority: _priority,
          dueDate: fullDueDate,
          isCompleted: _isCompleted,
        );
        _todoController.addTodo(newTodo);
      } else {
        // Update existing todo
        final updatedTodo = Todo(
          id: widget.todo!.id,
          title: _titleController.text,
          description: _descriptionController.text,
          priority: _priority,
          dueDate: fullDueDate,
          isCompleted: _isCompleted,
          createdAt: widget.todo!.createdAt,
        );
        _todoController.updateTodo(updatedTodo);
      }

      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo == null ? 'Add Task' : 'Edit Task'),
        actions: [
          TextButton(
            onPressed: _saveTodo,
            child: const Text('Save'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter task title',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter task details (optional)',
                    prefixIcon: Icon(Icons.description_rounded),
                    alignLabelWithHint: true,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 3,
                  maxLines: 5,
                ),
                const SizedBox(height: 32),

                // Priority section
                const Text(
                  'Priority Level',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildPriorityRadioTile(
                        Priority.HIGH,
                        'High',
                        Colors.red,
                        'Urgent tasks requiring immediate attention',
                        Icons.arrow_upward_rounded,
                      ),
                      Divider(
                          height: 1,
                          thickness: 1,
                          color: theme.colorScheme.outline.withOpacity(0.1)),
                      _buildPriorityRadioTile(
                        Priority.MEDIUM,
                        'Medium',
                        Colors.orange,
                        'Important tasks to complete soon',
                        Icons.remove_rounded,
                      ),
                      Divider(
                          height: 1,
                          thickness: 1,
                          color: theme.colorScheme.outline.withOpacity(0.1)),
                      _buildPriorityRadioTile(
                        Priority.LOW,
                        'Low',
                        Colors.green,
                        'Tasks with less urgency',
                        Icons.arrow_downward_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Due date section
                const Text(
                  'Due Date & Time',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.calendar_today_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        title: const Text('Date'),
                        subtitle: Text(
                            DateFormat('EEEE, MMM dd, yyyy').format(_dueDate)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _selectDate(context),
                      ),
                      Divider(
                          height: 1,
                          thickness: 1,
                          color: theme.colorScheme.outline.withOpacity(0.1)),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.access_time_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        title: const Text('Time'),
                        subtitle: Text(_dueTime.format(context)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _selectTime(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Status toggle
                if (widget.todo != null) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: SwitchListTile(
                      title: const Text('Mark as completed'),
                      subtitle: const Text('Toggle task completion status'),
                      value: _isCompleted,
                      onChanged: (bool value) {
                        setState(() {
                          _isCompleted = value;
                        });
                      },
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isCompleted
                              ? Colors.green.withOpacity(0.2)
                              : theme.colorScheme.outline.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _isCompleted
                              ? Icons.check_circle_rounded
                              : Icons.check_circle_outline_rounded,
                          color: _isCompleted ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Save button
                ElevatedButton.icon(
                  onPressed: _saveTodo,
                  icon: Icon(widget.todo == null
                      ? Icons.add_rounded
                      : Icons.save_rounded),
                  label: Text(
                    widget.todo == null ? 'Add Task' : 'Save Changes',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityRadioTile(
      int value, String title, Color color, String subtitle, IconData icon) {
    return RadioListTile<int>(
      value: value,
      groupValue: _priority,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontWeight:
                  _priority == value ? FontWeight.bold : FontWeight.normal,
              color: _priority == value ? color : null,
            ),
          ),
        ],
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      activeColor: color,
      selected: _priority == value,
      onChanged: (int? newValue) {
        if (newValue != null) {
          setState(() {
            _priority = newValue;
          });
        }
      },
    );
  }
}
