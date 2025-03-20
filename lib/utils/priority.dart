import 'package:flutter/material.dart';

class Priority {
  static const int LOW = 1;
  static const int MEDIUM = 2;
  static const int HIGH = 3;

  static String priorityText(int priority) {
    switch (priority) {
      case Priority.LOW:
        return 'Low';
      case Priority.MEDIUM:
        return 'Medium';
      case Priority.HIGH:
        return 'High';
      default:
        return 'Unknown';
    }
  }

  static Color priorityColor(int priority) {
    switch (priority) {
      case Priority.LOW:
        return Colors.green;
      case Priority.MEDIUM:
        return Colors.orange;
      case Priority.HIGH:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static Icon priorityIcon(int priority) {
    switch (priority) {
      case Priority.LOW:
        return const Icon(Icons.arrow_downward, color: Colors.green);
      case Priority.MEDIUM:
        return const Icon(Icons.remove, color: Colors.orange);
      case Priority.HIGH:
        return const Icon(Icons.arrow_upward, color: Colors.red);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }
}
