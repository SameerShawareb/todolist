// COMPOSITION ROOT
// This is the ONLY file that knows about every layer at once. Its
// job is just to build the concrete objects (the repository) and
// wire them into the things that need them (the service, then the
// UI). This wiring is called "dependency injection" — passing
// dependencies IN through constructors, rather than a class
// creating its own dependencies internally.

import 'package:flutter/material.dart';
import 'application/task_service.dart';
import 'infrastructure/shared_prefs_task_repository.dart';
import 'presentation/todo_home_page.dart';

void main() {
  final repository = SharedPrefsTaskRepository();
  final taskService = TaskService(repository);
  runApp(TodoApp(taskService: taskService));
}

class TodoApp extends StatelessWidget {
  final TaskService taskService;

  const TodoApp({super.key, required this.taskService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Today',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAF9F7),
        fontFamily: 'Roboto',
      ),
      home: TodoHomePage(taskService: taskService),
    );
  }
}