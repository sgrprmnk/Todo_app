import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../manager/task_manager.dart';
import '../models/task.dart';


// --- Task Tile Widget (Reusability & Clean UI) ---
class TaskTile extends StatelessWidget {
  final Task task;

  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final taskManager = context.read<TaskManager>();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      color: task.isCompleted ? Colors.green.withOpacity(0.1) : Theme.of(context).cardColor,
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (bool? value) {
            taskManager.toggleTaskCompletion(task);
          },
          activeColor: Colors.green,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Due: ${DateFormat('MMM dd, yyyy').format(task.dueDate)}'),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.category,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () => taskManager.deleteTask(task),
        ),
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => AddTaskModal(taskToEdit: task),
          );
        },
      ),
    );
  }
}

// --- Add/Edit Task Modal (Reusability) ---
class AddTaskModal extends StatefulWidget {
  final Task? taskToEdit;
  const AddTaskModal({super.key, this.taskToEdit});

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  DateTime _selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskToEdit?.title ?? '');
    _categoryController = TextEditingController(text: widget.taskToEdit?.category ?? 'Personal');
    _selectedDate = widget.taskToEdit?.dueDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitTask() {
    if (_formKey.currentState!.validate()) {
      final manager = context.read<TaskManager>();

      if (widget.taskToEdit == null) {
        // Add new task
        final newTask = Task.create(
          title: _titleController.text,
          category: _categoryController.text,
          dueDate: _selectedDate,
        );
        manager.addTask(newTask);
      } else {
        // Edit existing task
        widget.taskToEdit!.title = _titleController.text;
        widget.taskToEdit!.category = _categoryController.text;
        widget.taskToEdit!.dueDate = _selectedDate;
        manager.toggleTaskCompletion(widget.taskToEdit!); // Use toggle to force notify listeners if completion changed
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        // Adaptive padding for keyboard
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.taskToEdit == null ? 'Add New Task' : 'Edit Task',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category (e.g., Work, Personal)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Due Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Select Date'),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitTask,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  widget.taskToEdit == null ? 'Add Task' : 'Save Changes',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Custom Navigation Drawer (Reusability & Structure) ---
class CustomAppDrawer extends StatelessWidget {
  const CustomAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final taskManager = context.watch<TaskManager>();
    final categories = {'All', 'Week', 'Month', ...taskManager.allCategories};

    return Drawer(
      child: Column(
        children: [
          // Adaptive Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const SafeArea(
              child: Center(
                child: Text(
                  '🙌 Task Manager Pro 💕',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Navigation to Screens
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.pushReplacementNamed(context, '/');
            },
            selected: ModalRoute.of(context)?.settings.name == '/',
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Statistics'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/stats');
            },
            selected: ModalRoute.of(context)?.settings.name == '/stats',
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/settings');
            },
            selected: ModalRoute.of(context)?.settings.name == '/settings',
          ),

          const Divider(),

          // Grouping/Category Filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Filter & Grouping', style: Theme.of(context).textTheme.titleLarge),
          ),

          Expanded(
            child: ListView(
              // Generate filter tiles dynamically
              children: categories.map((category) {
                IconData icon;
                if (category == 'All') {
                  icon = Icons.list;
                } else if (category == 'Week') {
                  icon = Icons.calendar_view_week;
                } else if (category == 'Month') {
                  icon = Icons.calendar_view_month;
                } else {
                  icon = Icons.label_important_outline;
                }

                return ListTile(
                  leading: Icon(icon),
                  title: Text(category),
                  onTap: () {
                    taskManager.setGrouping(category);
                    Navigator.pop(context);
                    if (ModalRoute.of(context)?.settings.name != '/') {
                      Navigator.pushReplacementNamed(context, '/');
                    }
                  },
                  selected: taskManager.currentGrouping == category,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}