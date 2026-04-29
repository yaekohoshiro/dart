import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';
import '../../data/models/task_model.dart';

class DeadlinesScreen extends StatefulWidget {
  const DeadlinesScreen({super.key});

  @override
  State<DeadlinesScreen> createState() => _DeadlinesScreenState();
}

class _DeadlinesScreenState extends State<DeadlinesScreen> {
  String _filter = 'all'; // all, active, completed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Дедлайны'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearCompleted,
            tooltip: 'Очистить выполненные',
          ),
        ],
      ),
      body: Column(
        children: [
          // Фильтры
          _buildFilterChips(),
          
          // Список задач
          Expanded(
            child: Consumer<AppProvider>(
              builder: (context, provider, child) {
                List<Task> tasks;
                
                if (_filter == 'active') {
                  tasks = provider.activeTasks;
                } else if (_filter == 'completed') {
                  tasks = provider.completedTasks;
                } else {
                  // Все задачи: сортируем по приоритету, потом по дате
                  tasks = provider.tasks
                    ..sort((a, b) {
                      final priorityCompare = b.priority.index.compareTo(a.priority.index);
                      if (priorityCompare != 0) return priorityCompare;
                      return a.deadline.compareTo(b.deadline);
                    });
                }
                
                if (tasks.isEmpty) {
                  return _buildEmptyState();
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskCard(
                      task: task,
                      onToggle: () => _toggleTask(task),
                      onEdit: () => _editTask(task),
                      onDelete: () => _deleteTask(task),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(child: _buildFilterChip('Все', 'all')),
          const SizedBox(width: 8),
          Expanded(child: _buildFilterChip('Активные', 'active')),
          const SizedBox(width: 8),
          Expanded(child: _buildFilterChip('Выполненные', 'completed')),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isSelected 
            ? Theme.of(context).primaryColor 
            : (isDark ? const Color(0xFF2D2D2D) : Colors.grey[200]),
        borderRadius: BorderRadius.circular(12),
        border: isSelected 
            ? null 
            : Border.all(
                color: isDark ? Colors.white24 : Colors.grey[400]!,
                width: 1.5,
              ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _filter = value),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(Icons.check, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected 
                          ? Colors.white 
                          : (isDark ? Colors.white : Colors.black87),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _filter == 'completed' 
                ? 'Нет выполненных задач' 
                : 'Задач пока нет',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Нажми + чтобы добавить',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleTask(task) {
    context.read<AppProvider>().toggleTaskCompletion(task.id);
  }

  void _editTask(Task task) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AddTaskScreen(task: task),
    ),
  );
}

  void _deleteTask(task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить задачу?'),
        content: Text('Вы уверены, что хотите удалить "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().deleteTask(task.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Задача удалена')),
              );
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _clearCompleted() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить выполненные?'),
        content: const Text('Все выполненные задачи будут удалены.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().clearCompletedTasks();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Выполненные задачи удалены')),
              );
            },
            child: const Text('Очистить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}