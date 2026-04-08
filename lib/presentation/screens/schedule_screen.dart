import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/lesson_card.dart';
import '../../data/models/lesson_model.dart';
import 'add_lesson_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _selectedDay = DateTime.now().weekday; // 1 = Пн, 7 = Вс

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Расписание'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fillTestData(),
            tooltip: 'Тестовые данные',
          ),
        ],
      ),
      body: Column(
        children: [
          // Выбор дня недели
          _buildDaySelector(),
          
          // Список пар
          Expanded(
            child: Consumer<AppProvider>(
              builder: (context, provider, child) {
                final lessons = provider.getLessonsByDay(_selectedDay);
                
                if (lessons.isEmpty) {
                  return _buildEmptyState();
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = lessons[index];
                    return LessonCard(
                      lesson: lesson,
                      onEdit: () => _editLesson(lesson),
                      onDelete: () => _deleteLesson(lesson),
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

  Widget _buildDaySelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: 7,
            itemBuilder: (context, index) {
              final day = index + 1;
              final isSelected = day == _selectedDay;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDay = day),
                  child: Container(
                    width: 50,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          provider.getDayShortName(day),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$day',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'На этот день пар нет',
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

  void _fillTestData() {
    context.read<AppProvider>().fillTestData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Тестовые данные добавлены')),
    );
  }

  void _editLesson(Lesson lesson) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AddLessonScreen(lesson: lesson),
    ),
  );
}

  void _deleteLesson(lesson) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить пару?'),
        content: Text('Вы уверены, что хотите удалить "${lesson.subjectName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().deleteLesson(lesson.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Пара удалена')),
              );
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}