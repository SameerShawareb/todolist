class Task {
  String title;
  String category;
  bool done;
  bool urgent;
  DateTime? dueDate;
  List<Task> subtasks;

  Task({
    required this.title,
    required this.category,
    this.done = false,
    this.urgent = false,
    this.dueDate,
    List<Task>? subtasks,
  }) : subtasks = subtasks ?? [];
}