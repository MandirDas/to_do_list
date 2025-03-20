import 'package:get/get.dart';
import '../models/todo.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';

class TodoController extends GetxController {
  final todos = <Todo>[].obs;
  final filteredTodos = <Todo>[].obs;
  final isLoading = false.obs;
  final sortCriteria = 'createdAt'.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTodos();
  }

  Future<void> fetchTodos() async {
    isLoading.value = true;
    try {
      todos.value = await DatabaseHelper.instance.readAllTodos();
      applyFilters();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTodo(Todo todo) async {
    isLoading.value = true;
    try {
      final id = await DatabaseHelper.instance.create(todo);
      final newTodo = todo.copyWith(id: id);
      todos.add(newTodo);
      applyFilters();

      // Schedule notification
      await NotificationService.instance.scheduleTodoNotification(newTodo);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTodo(Todo todo) async {
    isLoading.value = true;
    try {
      await DatabaseHelper.instance.update(todo);
      final index = todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        todos[index] = todo;
        applyFilters();
      }

      // Update notification
      await NotificationService.instance.cancelNotification(todo.id ?? 0);
      await NotificationService.instance.scheduleTodoNotification(todo);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTodo(int id) async {
    isLoading.value = true;
    try {
      await DatabaseHelper.instance.delete(id);
      todos.removeWhere((todo) => todo.id == id);
      applyFilters();

      // Remove notification
      await NotificationService.instance.cancelNotification(id);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleTodoStatus(Todo todo) async {
    final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);
    await updateTodo(updatedTodo);
  }

  void setSortCriteria(String criteria) {
    if (sortCriteria.value != criteria) {
      sortCriteria.value = criteria;
      applyFilters();
    }
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void applyFilters() {
    List<Todo> result = List<Todo>.from(todos);

    // Apply search filter if there's a query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result
          .where((todo) =>
              todo.title.toLowerCase().contains(query) ||
              todo.description.toLowerCase().contains(query))
          .toList();
    }

    // Apply sorting
    switch (sortCriteria.value) {
      case 'priority':
        result.sort((a, b) => b.priority.compareTo(a.priority));
        break;
      case 'dueDate':
        result.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case 'createdAt':
      default:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    filteredTodos.value = result;
  }
}
