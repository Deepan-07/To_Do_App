enum TaskPriority { low, medium, high }

class Task {
  final String id;
  String title;
  String description;
  DateTime? dueDate;
  bool isComplete;
  TaskPriority priority;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.dueDate,
    this.isComplete = false,
    this.priority = TaskPriority.medium,
  });
} 