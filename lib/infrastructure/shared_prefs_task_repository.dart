import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/task.dart';
import '../../domain/task_repository.dart';

class SharedPrefsTaskRepository implements TaskRepository {
  static const _key = 'tasks';

  @override
  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(_key);

    if (savedData == null) {
      return [];
    }

    final List decoded = jsonDecode(savedData);
    return decoded
        .map((item) => Task(
      title: item['title'],
      category: item['category'],
      done: item['done'],
    ))
        .toList();
  }

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final maps = tasks
        .map((t) => {
      'title': t.title,
      'category': t.category,
      'done': t.done,
    })
        .toList();
    await prefs.setString(_key, jsonEncode(maps));
  }
}