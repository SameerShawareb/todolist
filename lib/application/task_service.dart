import '../domain/task.dart';
import '../domain/task_repository.dart';

class TaskService {
  final TaskRepository repository;
  final List<Task> tasks = [];

  TaskService(this.repository);

  Future<void> loadTasks() async {
    final loaded = await repository.loadTasks();
    tasks
      ..clear()
      ..addAll(loaded);
  }

  Future<void> addTask(String title, String category) async {
    final text = title.trim();
    if (text.isEmpty) {
      return;
    }
    tasks.add(Task(title: text, category: category));
    await repository.saveTasks(tasks);
  }

  Future<void> toggleTask(Task task) async {
    task.done = !task.done;
    await repository.saveTasks(tasks);
  }

  Future<void> deleteTask(Task task) async {
    tasks.remove(task);
    await repository.saveTasks(tasks);
  }

  Future<void> toggleUrgent(Task task) async {
    task.urgent = !task.urgent;
    await repository.saveTasks(tasks);
  }

  Future<void> setDueDate(Task task, DateTime? date) async {
    task.dueDate = date;
    await repository.saveTasks(tasks);
  }

  Future<void> addSubtask(Task parent, String title) async {
    final text = title.trim();
    if (text.isEmpty) {
      return;
    }
    parent.subtasks.add(Task(title: text, category: parent.category));
    await repository.saveTasks(tasks);
  }

  Future<void> deleteSubtask(Task parent, Task subtask) async {
    parent.subtasks.remove(subtask);
    await repository.saveTasks(tasks);
  }
}