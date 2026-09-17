// INFRASTRUCTURE LAYER
// This is the ONLY file in the whole app that knows about
// SharedPreferences and JSON. It "implements" the TaskRepository
// contract from the domain layer, filling in the actual how.
//
// If you later wanted to save tasks to a real database instead,
// you would write a new class here (e.g. SqliteTaskRepository)
// that also implements TaskRepository — and nothing in
// TaskService or the UI would need to change.

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