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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fillTestData,
            tooltip: 'Тестовые данные',
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
                List tasks;
                
                if (_filter == 'active') {
                  tasks = provider.activeTasks;
                } else if (_filter == 'completed') {
                  tasks = provider.completedTasks;
                } else {
                  tasks = provider.tasks
                    ..sort((a, b) => a.deadline.compareTo(b.deadline));
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
          _buildFilterChip('Все', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('Активные', 'active'),
          const SizedBox(width: 8),
          _buildFilterChip('Выполненые', 'completed'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filter = value);
      },
      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
      checkmarkColor: Theme.of(context).primaryColor,
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

  void _fillTestData() {
    context.read<AppProvider>().fillTestData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Тестовые данные добавлены')),
    );
  }
}