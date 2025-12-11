import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

// Hive box name constant
const String taskBoxName = 'tasks';

class HiveDataService {
  late Box<Task> _taskBox;

  // Initializes Hive, registers adapter, and opens the box
  Future<void> init() async {
    // Await this to ensure Hive is ready
    await Hive.initFlutter();

    // Register the adapter (generated via build_runner)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }

    _taskBox = await Hive.openBox<Task>(taskBoxName);

    if (kDebugMode) {
      print('Hive Box Opened. Total tasks: ${_taskBox.length}');
    }
  }

  // Get all tasks
  List<Task> getAllTasks() {
    return _taskBox.values.toList();
  }

  // Add a new task
  Future<void> addTask(Task task) async {
    await _taskBox.put(task.id, task);
  }

  // Update an existing task
  Future<void> updateTask(Task task) async {
    await _taskBox.put(task.id, task);
  }

  // Delete a task by its ID
  Future<void> deleteTask(String taskId) async {
    await _taskBox.delete(taskId);
  }
}