import 'package:flutter/material.dart';
import '../../application/task_service.dart';
import '../../domain/task.dart';

class TodoHomePage extends StatefulWidget {
  final TaskService taskService;

  const TodoHomePage({super.key, required this.taskService});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final List<String> categories = ['Design', 'Personal', 'House'];
  String selectedCategory = 'Personal';
  final TextEditingController taskController = TextEditingController();

  TaskService get service => widget.taskService;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await service.loadTasks();
    setState(() {});
  }

  Future<void> _add() async {
    await service.addTask(taskController.text, selectedCategory);
    taskController.clear();
    setState(() {});
  }

  Future<void> _toggle(Task task) async {
    await service.toggleTask(task);
    setState(() {});
  }

  Future<void> _delete(Task task) async {
    await service.deleteTask(task);
    setState(() {});
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
            Expanded(child: _buildTaskList()),
            _buildInputRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    final tasks = service.tasks;

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
              _buildTaskRow(task),
          ],
        ],
      ],
    );
  }

  Widget _buildTaskRow(Task task) {
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
            onChanged: (_) => _toggle(task),
            activeColor: const Color(0xFF383430),
          ),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                fontSize: 15,
                color: task.done ? Colors.grey : const Color(0xFF1C1B1A),
                decoration: task.done
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.grey),
            onPressed: () => _delete(task),
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      decoration: const BoxDecoration(
        color: Color(0xFFFAF9F7),
        border: Border(top: BorderSide(color: Color(0xFFE6E4E1))),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: DropdownButton<String>(
              value: selectedCategory,
              underline: const SizedBox(),
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
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
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE6E4E1)),
                    ),
                  ),
                  onSubmitted: (_) => _add(),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _add,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF383430),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
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