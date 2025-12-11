import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../manager/task_manager.dart';
import '../widgets/task_tile.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch TaskManager for updates to the task list and filters
    final taskManager = context.watch<TaskManager>();

    // Check screen size for responsiveness
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(taskManager.currentGrouping == 'All'
            ? 'All Tasks'
            : '${taskManager.currentGrouping} Tasks'
        ),
        actions: [
          // Optional action for a large screen to quickly navigate to settings
          if (isLargeScreen)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
        ],
      ),
      drawer: isLargeScreen ? null : const CustomAppDrawer(), // Hide drawer on large screens, rely on fixed sidebar if implemented
      body: SafeArea(
        child: Column(
          children: [
            // Responsive Filter Bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
              child: _buildFilterChips(context, taskManager),
            ),

            // Task List Area
            Expanded(
              child: taskManager.filteredTasks.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 80, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                    const SizedBox(height: 10),
                    Text(
                      'No tasks found for this view.',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Add a new task using the + button.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: taskManager.filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = taskManager.filteredTasks[index];
                  return TaskTile(task: task);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addTaskFab',
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddTaskModal(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Reusable widget builder for the filter chips
  Widget _buildFilterChips(BuildContext context, TaskManager taskManager) {
    // List of filter definitions
    final filters = [
      {'label': 'All', 'filter': TaskFilter.all},
      {'label': 'Pending', 'filter': TaskFilter.pending},
      {'label': 'Completed', 'filter': TaskFilter.completed},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: filters.map((data) {
          final filter = data['filter'] as TaskFilter;
          final isSelected = taskManager.currentFilter == filter;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(data['label'] as String),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  taskManager.setFilter(filter);
                }
              },
              selectedColor: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).cardColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium!.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              elevation: isSelected ? 3 : 1,
            ),
          );
        }).toList(),
      ),
    );
  }
}