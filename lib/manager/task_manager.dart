import 'package:flutter/foundation.dart';
import '../data/data_service.dart';
import '../models/task.dart';

// Enum for filtering options
enum TaskFilter { all, pending, completed }

class TaskManager extends ChangeNotifier {
  final HiveDataService _dataService = HiveDataService();
  List<Task> _tasks = [];
  TaskFilter _currentFilter = TaskFilter.all;
  String _currentGrouping = 'All'; // 'All', 'Week', 'Month', or Category Name

  List<Task> get tasks => _tasks;
  TaskFilter get currentFilter => _currentFilter;
  String get currentGrouping => _currentGrouping;

  TaskManager() {
    loadTasks();
  }

  // --- Data Loading ---
  Future<void> loadTasks() async {
    await _dataService.init();
    _tasks = _dataService.getAllTasks();
    notifyListeners();
  }

  // --- CRUD Operations ---
  Future<void> addTask(Task task) async {
    await _dataService.addTask(task);
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(Task task) async {
    task.isCompleted = !task.isCompleted;
    await _dataService.updateTask(task);
    notifyListeners();
  }

  Future<void> deleteTask(Task task) async {
    await _dataService.deleteTask(task.id);
    _tasks.removeWhere((t) => t.id == task.id);
    notifyListeners();
  }

  // --- Filtering & Grouping Control ---
  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void setGrouping(String grouping) {
    _currentGrouping = grouping;
    notifyListeners();
  }

  // --- Filtered/Grouped Tasks Getter ---
  List<Task> get filteredTasks {
    List<Task> list = _tasks;

    // 1. Apply Status Filter
    if (_currentFilter == TaskFilter.pending) {
      list = list.where((t) => !t.isCompleted).toList();
    } else if (_currentFilter == TaskFilter.completed) {
      list = list.where((t) => t.isCompleted).toList();
    }

    // 2. Apply Grouping Filter (Category, Week, Month)
    if (_currentGrouping != 'All') {
      if (_currentGrouping == 'Week') {
        final now = DateTime.now();
        // Filter tasks due this week (start of day Monday to end of day Sunday)
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));

        list = list.where((t) {
          final date = t.dueDate;
          return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && date.isBefore(endOfWeek.add(const Duration(days: 1)));
        }).toList();

      } else if (_currentGrouping == 'Month') {
        final now = DateTime.now();
        list = list.where((t) => t.dueDate.year == now.year && t.dueDate.month == now.month).toList();

      } else {
        // Category Filter
        list = list.where((t) => t.category == _currentGrouping).toList();
      }
    }

    // Sort by Due Date
    list.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return list;
  }

  // --- Category Management ---
  Set<String> get allCategories {
    return _tasks.map((t) => t.category).toSet();
  }

  // --- Chart Data Preparation ---
  // Returns map of {Category Name: Percentage Completed}
  Map<String, double> get categoryCompletionData {
    final categories = allCategories;
    final Map<String, int> totalTasks = {};
    final Map<String, int> completedTasks = {};

    for (var cat in categories) {
      totalTasks[cat] = _tasks.where((t) => t.category == cat).length;
      completedTasks[cat] = _tasks.where((t) => t.category == cat && t.isCompleted).length;
    }

    final Map<String, double> completionPercentages = {};
    totalTasks.forEach((category, total) {
      if (total > 0) {
        completionPercentages[category] = (completedTasks[category] ?? 0) / total;
      } else {
        completionPercentages[category] = 0.0;
      }
    });

    return completionPercentages;
  }

  // Returns map of {Status: Count} for Bar Chart
  Map<String, int> get statusCountData {
    int pending = _tasks.where((t) => !t.isCompleted).length;
    int completed = _tasks.where((t) => t.isCompleted).length;
    return {'Pending': pending, 'Completed': completed};
  }
}