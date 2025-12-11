import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../manager/task_manager.dart';
import '../widgets/task_tile.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskManager = context.watch<TaskManager>();
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Statistics'),
      ),
      drawer: isLargeScreen ? null : const CustomAppDrawer(),
      body: taskManager.tasks.isEmpty
          ? Center(
        child: Text(
          'Add tasks to see your statistics here!',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: isLargeScreen
            ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildCategoryPieChart(context, taskManager)),
            const SizedBox(width: 20),
            Expanded(child: _buildStatusBarChart(context, taskManager)),
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCategoryPieChart(context, taskManager),
            const SizedBox(height: 20),
            _buildStatusBarChart(context, taskManager),
          ],
        ),
      ),
    );
  }

  // --- Category Completion Pie Chart ---
  Widget _buildCategoryPieChart(BuildContext context, TaskManager taskManager) {
    final data = taskManager.categoryCompletionData;
    final totalCategories = data.length;

    List<PieChartSectionData> sections = [];
    final categoryColors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.redAccent,
      Colors.teal,
    ];

    int i = 0;
    data.forEach((category, percentage) {
      sections.add(
        PieChartSectionData(
          color: categoryColors[i % categoryColors.length],
          value: (percentage * 100).toDouble(), // Value in percent
          title: '${(percentage * 100).toStringAsFixed(0)}%',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      i++;
    });

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Completion Rate',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                        startDegreeOffset: 180,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Legend
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: data.keys.toList().asMap().entries.map((entry) {
                      int index = entry.key;
                      String category = entry.value;
                      return _buildLegendItem(
                        color: categoryColors[index % categoryColors.length],
                        title: category,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Overall Status Bar Chart ---
  Widget _buildStatusBarChart(BuildContext context, TaskManager taskManager) {
    final data = taskManager.statusCountData;
    final total = taskManager.tasks.length;

    List<BarChartGroupData> barGroups = [
      _makeBarGroup(0, data['Pending']?.toDouble() ?? 0, total, Colors.orange),
      _makeBarGroup(1, data['Completed']?.toDouble() ?? 0, total, Colors.green),
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Status Count',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: total.toDouble() == 0 ? 1 : total.toDouble(),
                  barGroups: barGroups,
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true, horizontalInterval: total.toDouble() / 4),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0: return const Text('Pending');
                            case 1: return const Text('Completed');
                            default: return const Text('');
                          }
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          rod.toY.toInt().toString(),
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, int total, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 30,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
          // Tooltip text showing count and percentage
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: total.toDouble() == 0 ? 1 : total.toDouble(),
            color: color.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem({required Color color, required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
    );
  }
}