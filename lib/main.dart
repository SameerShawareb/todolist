import 'dart:convert';

import 'package:flutter/material.dart';
//to save the data
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const TodoApp());
}

// A simple model class for one task.
// Plain OOP: a class with fields, plus toMap/fromMap so it can be
// turned into JSON text and back (needed to save it to disk).
class Task {
  String title;
  String category;
  bool done;

  Task({required this.title, required this.category, this.done = false});

  Map<String, dynamic> toMap() {
    return {'title': title, 'category': category, 'done': done};
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'],
      category: map['category'],
      done: map['done'],
    );
  }
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

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
      home: const TodoHomePage(),
    );
  }
}

// main screen.
class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final List<Task> tasks = [];
  final List<String> categories = ['Design', 'Personal', 'House'];
  String selectedCategory = 'Personal';

  final TextEditingController taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  // Reading from disk isn't instant, so this is async: we `await`
  // the result instead of freezing the UI while it loads.
  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('tasks');

    if (savedData != null) {
      final List decodedList = jsonDecode(savedData);
      setState(() {
        tasks.addAll(decodedList.map((item) => Task.fromMap(item)));
      });
    }
  }

  // Writing to disk is also async for the same reason.
  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> taskMaps =
    tasks.map((task) => task.toMap()).toList();
    await prefs.setString('tasks', jsonEncode(taskMaps));
  }

  void addTask() {
    final text = taskController.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      tasks.add(Task(title: text, category: selectedCategory));
      taskController.clear();
    });

    saveTasks();
  }

  void toggleTask(Task task) {
    setState(() {
      task.done = !task.done;
    });
    saveTasks();
  }

  void deleteTask(Task task) {
    setState(() {
      tasks.remove(task);
    });
    saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C1B1A),
                  ),
                ),
              ),
            ),

            // Expanded makes this list take up all the remaining
            // vertical space, so the input row below always stays
            // pinned at the bottom.
            Expanded(
              child: buildTaskList(),
            ),

            buildInputRow(),
          ],
        ),
      ),
    );
  }

  //scrollable list, grouped by category.
  Widget buildTaskList() {
    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          'No tasks yet. Add one below.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        for (final category in categories) ...[
          if (tasks.any((t) => t.category == category)) ...[
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 6),
              child: Text(
                category.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFE39B87),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
            for (final task in tasks.where((t) => t.category == category))
              buildTaskRow(task),
          ],
        ],
      ],
    );
  }

  Widget buildTaskRow(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F0EE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Checkbox(
            value: task.done,
            onChanged: (value) => toggleTask(task),
            activeColor: const Color(0xFF383430),
          ),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                fontSize: 15,
                color: task.done ? Colors.grey : const Color(0xFF1C1B1A),
                decoration:
                task.done ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.grey),
            onPressed: () => deleteTask(task),
          ),
        ],
      ),
    );
  }

  // The bottom bar: a category dropdown, a text field, and an add button.
  Widget buildInputRow() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      decoration: const BoxDecoration(
        color: Color(0xFFFAF9F7),
        border: Border(top: BorderSide(color: Color(0xFFE6E4E1))),
      ),
      child: Column(
        children: [
          // Lets user pick category new task goes into.
          Align(
            alignment: Alignment.centerLeft,
            child: DropdownButton<String>(
              value: selectedCategory,
              underline: const SizedBox(),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: taskController,
                  decoration: InputDecoration(
                    hintText: 'Write a task...',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE6E4E1)),
                    ),
                  ),
                  onSubmitted: (_) => addTask(),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: addTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF383430),
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}