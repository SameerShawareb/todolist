import 'package:flutter/material.dart';
import '../application/task_service.dart';
import '../domain/task.dart';

class TodoHomePage extends StatefulWidget {
  final TaskService taskService;

  const TodoHomePage({super.key, required this.taskService});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final List<String> categories = ['Design', 'Personal', 'House'];
  final Set<String> _collapsedCategories = {};
  final Map<String, TextEditingController> _inputControllers = {};

  bool _loading = true;

  TaskService get service => widget.taskService;

  @override
  void initState() {
    super.initState();
    for (final category in categories) {
      _inputControllers[category] = TextEditingController();
    }
    _load();
  }

  @override
  void dispose() {
    for (final controller in _inputControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    await service.loadTasks();
    setState(() => _loading = false);
  }

  Future<void> _addToCategory(String category) async {
    final controller = _inputControllers[category]!;
    await service.addTask(controller.text, category);
    controller.clear();
    setState(() {});
  }

  Future<void> _toggleDone(Task task) async {
    await service.toggleTask(task);
    setState(() {});
  }

  Future<void> _toggleUrgent(Task task) async {
    await service.toggleUrgent(task);
    setState(() {});
  }

  Future<void> _deleteTask(Task task) async {
    await service.deleteTask(task);
    setState(() {});
  }

  Future<void> _deleteSubtask(Task parent, Task subtask) async {
    await service.deleteSubtask(parent, subtask);
    setState(() {});
  }

  Future<void> _pickDueDate(Task task) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: task.dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      await service.setDueDate(task, picked);
      setState(() {});
    }
  }

  Future<void> _addSubtaskDialog(Task parent) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add subtask'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Subtask title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      await service.addSubtask(parent, result.trim());
      setState(() {});
    }
  }

  // "Due in 3 days" / "Due today" / "Overdue" — computed from the
  // gap between today and the stored due date.
  String _dueLabel(DateTime due) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(due.year, due.month, due.day);
    final diff = dueDay.difference(today).inDays;

    if (diff < 0) return 'Overdue';
    if (diff == 0) return 'Due today';
    if (diff == 1) return 'Due tomorrow';
    return 'Due in $diff days';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tasks',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C1B1A),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _loading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF383430),
                  ),
                )
                    : ListView(
                  children: [
                    for (final category in categories)
                      _buildCategorySection(category),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(String category) {
    final categoryTasks =
    service.tasks.where((t) => t.category == category).toList();
    final isCollapsed = _collapsedCategories.contains(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (isCollapsed) {
                  _collapsedCategories.remove(category);
                } else {
                  _collapsedCategories.add(category);
                }
              });
            },
            child: Row(
              children: [
                const Icon(Icons.folder_outlined,
                    size: 18, color: Color(0xFF6B6864)),
                const SizedBox(width: 8),
                Text(
                  category,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF1C1B1A),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(height: 1, color: const Color(0xFFE6E4E1)),
                ),
                const SizedBox(width: 10),
                Icon(
                  isCollapsed ? Icons.expand_more : Icons.expand_less,
                  size: 20,
                  color: Colors.grey,
                ),
                if (isCollapsed) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF383430),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${categoryTasks.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!isCollapsed) ...[
            const SizedBox(height: 10),
            for (final task in categoryTasks) _buildTaskRow(task),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputControllers[category],
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Write a task...',
                      isDense: true,
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _addToCategory(category),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      size: 20, color: Colors.grey),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _addToCategory(category),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskRow(Task task, {Task? parent}) {
    final isSubtask = parent != null;

    return Padding(
      padding: EdgeInsets.only(left: isSubtask ? 30 : 0, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleDone(task),
                onLongPress: isSubtask ? null : () => _toggleUrgent(task),
                child: _buildCheckbox(task),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: isSubtask ? 13.5 : 14.5,
                    color: task.done
                        ? const Color(0xFFA9A6A1)
                        : const Color(0xFF1C1B1A),
                    decoration: task.done
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ),
              if (!isSubtask)
                IconButton(
                  icon: const Icon(Icons.calendar_today_outlined,
                      size: 15, color: Colors.grey),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _pickDueDate(task),
                ),
              IconButton(
                icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                visualDensity: VisualDensity.compact,
                onPressed: () => isSubtask
                    ? _deleteSubtask(parent, task)
                    : _deleteTask(task),
              ),
            ],
          ),
          if (task.dueDate != null)
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 2, bottom: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.event, size: 12, color: Color(0xFF6B6FE3)),
                  const SizedBox(width: 4),
                  Text(
                    _dueLabel(task.dueDate!),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B6FE3),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          if (!isSubtask && task.subtasks.isNotEmpty)
            for (final sub in task.subtasks)
              _buildTaskRow(sub, parent: task),
          if (!isSubtask)
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 2),
              child: GestureDetector(
                onTap: () => _addSubtaskDialog(task),
                child: const Text(
                  '+ Add subtask',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(Task task) {
    final Color borderColor;
    if (task.done) {
      borderColor = const Color(0xFFA9A6A1);
    } else if (task.urgent) {
      borderColor = const Color(0xFFE5686F);
    } else {
      borderColor = const Color(0xFFCFCCC7);
    }

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: task.done ? const Color(0xFFA9A6A1) : Colors.transparent,
        border: Border.all(color: borderColor, width: 1.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: task.done
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}