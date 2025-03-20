import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy - HH:mm').format(date);
  }

  static String formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDateDay = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (dueDateDay.isBefore(today)) {
      return 'Overdue (${formatDate(dueDate)})';
    } else if (dueDateDay == today) {
      return 'Today (${DateFormat('HH:mm').format(dueDate)})';
    } else if (dueDateDay == tomorrow) {
      return 'Tomorrow (${DateFormat('HH:mm').format(dueDate)})';
    } else {
      return formatDate(dueDate);
    }
  }

  static bool isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now());
  }

  static bool isDueSoon(DateTime dueDate) {
    final now = DateTime.now();
    final soon = now.add(const Duration(days: 1));
    return dueDate.isAfter(now) && dueDate.isBefore(soon);
  }
}
