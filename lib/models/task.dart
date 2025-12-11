import 'package:hive/hive.dart';

// 1. Run `flutter pub run build_runner build` to generate task.g.dart
part 'task.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String category; // E.g., 'Work', 'Personal', 'Study'

  @HiveField(3)
  DateTime dueDate;

  @HiveField(4)
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.category,
    required this.dueDate,
    this.isCompleted = false,
  });

  // Simple factory for generating unique IDs
  factory Task.create({
    required String title,
    required String category,
    required DateTime dueDate,
  }) {
    return Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: category,
      dueDate: dueDate,
    );
  }
}