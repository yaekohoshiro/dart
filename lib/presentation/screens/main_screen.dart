import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'schedule_screen.dart';
import 'deadlines_screen.dart';
import 'teachers_screen.dart';
import 'settings_screen.dart';
import 'add_lesson_screen.dart';
import 'add_task_screen.dart';
import 'add_teacher_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ScheduleScreen(),
    const DeadlinesScreen(),
    const TeachersScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Загружаем данные из БД после первого фрейма
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: 'Расписание'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Дедлайны'),
          NavigationDestination(icon: Icon(Icons.people_outlined), selectedIcon: Icon(Icons.people), label: 'Преподав.'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Настройки'),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget? _buildFAB() {
  switch (_currentIndex) {
    case 0: // Расписание
      return FloatingActionButton(
        onPressed: _navigateToAddLesson,
        child: const Icon(Icons.add),
        tooltip: 'Добавить пару',
      );
    case 1: // Дедлайны
      return FloatingActionButton(
        onPressed: _navigateToAddTask,
        child: const Icon(Icons.add_task),
        tooltip: 'Добавить задачу',
      );
    case 2: // Преподаватели
      return FloatingActionButton(
        onPressed: _navigateToAddTeacher,
        child: const Icon(Icons.person_add),
        tooltip: 'Добавить преподавателя',
      );
    default:
      return null;
  }
}

void _navigateToAddLesson() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const AddLessonScreen()),
  ).then((_) {
    context.read<AppProvider>().loadData();
  });
}

void _navigateToAddTask() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const AddTaskScreen()),
  ).then((_) {
    context.read<AppProvider>().loadData();
  });
}

void _navigateToAddTeacher() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const AddTeacherScreen()),
  ).then((_) {
    context.read<AppProvider>().loadData();
  });
}
}