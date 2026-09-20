import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/task.dart';
import '../domain/task_repository.dart';

Map<String, dynamic> _taskToMap(Task task) {
  return {
    'title': task.title,
    'category': task.category,
    'done': task.done,
    'urgent': task.urgent,
    'dueDate': task.dueDate?.toIso8601String(),
    'subtasks': task.subtasks.map(_taskToMap).toList(),
  };
}

Task _taskFromMap(Map<String, dynamic> map) {
  return Task(
    title: map['title'],
    category: map['category'],
    done: map['done'],
    urgent: map['urgent'] ?? false,
    dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
    subtasks: ((map['subtasks'] as List?) ?? [])
        .map((item) => _taskFromMap(item))
        .toList(),
  );
}

class SharedPrefsTaskRepository implements TaskRepository {
  static const _key = 'tasks_v3';

  @override
  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(_key);

    if (savedData == null) {
      return [];
    }

    final List decoded = jsonDecode(savedData);
    return decoded.map((item) => _taskFromMap(item)).toList();
  }

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final maps = tasks.map(_taskToMap).toList();
    await prefs.setString(_key, jsonEncode(maps));
  }
}