import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../widgets/lesson_card.dart';
import 'add_lesson_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime _selectedDate;
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _weekStart = _getWeekStart(DateTime.now());
  }

  // Получить начало недели (Понедельник)
  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // Получить конец недели (Воскресенье)
  DateTime _getWeekEnd() {
    return _weekStart.add(const Duration(days: 6));
  }

  // Переключиться на предыдущую неделю
  void _previousWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
    });
  }

  // Переключиться на следующую неделю
  void _nextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
      _selectedDate = _selectedDate.add(const Duration(days: 7));
    });
  }

  // Перейти к текущей неделе
  void _goToToday() {
    setState(() {
      _weekStart = _getWeekStart(DateTime.now());
      _selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Расписание'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: _goToToday,
            tooltip: 'Сегодня',
          ),
        ],
      ),
      body: Column(
        children: [
          // Навигация по неделям
          _buildWeekNavigation(),
          
          // Выбор дня недели
          _buildDaySelector(),
          
          // Список пар
          Expanded(
            child: Consumer<AppProvider>(
              builder: (context, provider, child) {
                final lessons = provider.getLessonsByDate(_selectedDate);
                
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

  Widget _buildWeekNavigation() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weekEnd = _getWeekEnd();
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousWeek,
            tooltip: 'Предыдущая неделя',
          ),
          Column(
            children: [
              Text(
                '${_weekStart.day}.${_weekStart.month} - ${weekEnd.day}.${weekEnd.month}.${weekEnd.year}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                'Неделя',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.grey[600],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextWeek,
            tooltip: 'Следующая неделя',
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = _weekStart.add(Duration(days: index));
          final isSelected = date.day == _selectedDate.day && 
                             date.month == _selectedDate.month &&
                             date.year == _selectedDate.year;
          final isToday = date.day == DateTime.now().day && 
                          date.month == DateTime.now().month &&
                          date.year == DateTime.now().year;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _selectedDate = date),
              child: Container(
                width: 56,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : (isToday 
                          ? Theme.of(context).primaryColor.withOpacity(0.2)
                          : (Theme.of(context).brightness == Brightness.dark 
                              ? const Color(0xFF2D2D2D) 
                              : Colors.grey[200])),
                  borderRadius: BorderRadius.circular(12),
                  border: isToday && !isSelected
                      ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getDayShortName(date.weekday),
                      style: TextStyle(
                        color: isSelected 
                            ? Colors.white 
                            : (Theme.of(context).brightness == Brightness.dark 
                                ? Colors.white70 
                                : Colors.black54),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isSelected 
                            ? Colors.white 
                            : (Theme.of(context).brightness == Brightness.dark 
                                ? Colors.white 
                                : Colors.black87),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(height: 2),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? Colors.white 
                              : Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getDayShortName(int weekday) {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days[weekday - 1];
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 80,
            color: isDark ? Colors.white24 : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'На ${_selectedDate.day}.${_selectedDate.month} пар нет',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Нажми + чтобы добавить',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _editLesson(lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddLessonScreen(lesson: lesson),
      ),
    ).then((_) {
      context.read<AppProvider>().loadData();
    });
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