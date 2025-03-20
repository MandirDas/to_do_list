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
      // Edit mode
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo == null ? 'Add Task' : 'Edit Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                minLines: 3,
                maxLines: 5,
              ),
              const SizedBox(height: 16),

              // Priority section
              const Text(
                'Priority',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _PriorityOption(
                      value: Priority.LOW,
                      groupValue: _priority,
                      label: 'Low',
                      color: Colors.green,
                      onChanged: (value) {
                        setState(() {
                          _priority = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: _PriorityOption(
                      value: Priority.MEDIUM,
                      groupValue: _priority,
                      label: 'Medium',
                      color: Colors.orange,
                      onChanged: (value) {
                        setState(() {
                          _priority = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: _PriorityOption(
                      value: Priority.HIGH,
                      groupValue: _priority,
                      label: 'High',
                      color: Colors.red,
                      onChanged: (value) {
                        setState(() {
                          _priority = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Due date section
              const Text(
                'Due Date & Time',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectDate(context),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(DateFormat('MMM dd, yyyy').format(_dueDate)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectTime(context),
                      icon: const Icon(Icons.access_time),
                      label: Text(_dueTime.format(context)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Status toggle
              if (widget.todo != null) ...[
                SwitchListTile(
                  title: const Text(
                    'Mark as completed',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  value: _isCompleted,
                  onChanged: (bool value) {
                    setState(() {
                      _isCompleted = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Save button
              ElevatedButton(
                onPressed: _saveTodo,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.todo == null ? 'Add Task' : 'Save Changes',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityOption extends StatelessWidget {
  final int value;
  final int groupValue;
  final String label;
  final Color color;
  final ValueChanged<int> onChanged;

  const _PriorityOption({
    required this.value,
    required this.groupValue,
    required this.label,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Radio<int>(
              value: value,
              groupValue: groupValue,
              onChanged: (int? newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
              activeColor: color,
            ),
            Text(
              label,
              style: TextStyle(
                color: groupValue == value ? color : null,
                fontWeight: groupValue == value ? FontWeight.bold : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
