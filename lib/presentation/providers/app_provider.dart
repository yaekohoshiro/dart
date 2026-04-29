import 'package:flutter/material.dart';
import '../../data/models/lesson_model.dart';
import '../../data/models/task_model.dart';
import '../../data/models/teacher_model.dart';
import '../../data/database/database_helper.dart';

class AppProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Lesson> _lessons = [];
  List<Task> _tasks = [];
  List<Teacher> _teachers = [];

  List<Lesson> get lessons => _lessons;
  List<Task> get tasks => _tasks;
  List<Teacher> get teachers => _teachers;

  // Загрузка данных (вызывать из виджета!)
  Future<void> loadData() async {
    await _loadLessons();
    await _loadTasks();
    await _loadTeachers();
    notifyListeners();
  }

  Future<void> _loadLessons() async {
    try {
      final db = await _db.database;
      final data = await db.query('lessons', orderBy: 'date, start_time');
      _lessons = data.map((item) => Lesson.fromMap(item)).toList();
    } catch (e) {
      debugPrint('Error loading lessons: $e');
    }
  }

  Future<void> _loadTasks() async {
    try {
      final data = await _db.getTasks();
      _tasks = data.map((item) => Task.fromMap(item)).toList();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    }
  }

  Future<void> _loadTeachers() async {
    try {
      final data = await _db.getTeachers();
      _teachers = data.map((item) => Teacher.fromMap(item)).toList();
    } catch (e) {
      debugPrint('Error loading teachers: $e');
    }
  }

  // Получить пары на конкретную дату
  List<Lesson> getLessonsByDate(DateTime date) {
    final dateStr = date.toIso8601String().split('T')[0];
    return _lessons
        .where((lesson) {
          final lessonDate = lesson.date.toIso8601String().split('T')[0];
          return lessonDate == dateStr;
        })
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // Получить пары на неделю
  List<Lesson> getLessonsByWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    return _lessons
        .where((lesson) {
          return lesson.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
                 lesson.date.isBefore(weekEnd.add(const Duration(days: 1)));
        })
        .toList()
      ..sort((a, b) {
        final dateCompare = a.date.compareTo(b.date);
        if (dateCompare != 0) return dateCompare;
        return a.startTime.compareTo(b.startTime);
      });
  }

  List<Task> get activeTasks {
    return _tasks
        .where((task) => !task.isCompleted)
        .toList()
      ..sort((a, b) {
        // Сначала сортируем по приоритету (высокий > средний > низкий)
        final priorityCompare = b.priority.index.compareTo(a.priority.index);
        if (priorityCompare != 0) return priorityCompare;
        
        // Затем по дедлайну (ближе раньше)
        return a.deadline.compareTo(b.deadline);
      });
  }
  
  List<Task> get completedTasks {
    return _tasks
        .where((task) => task.isCompleted)
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  // ==================== LESSONS ====================

  Future<void> addLesson(Lesson lesson) async {
    final id = await _db.createLesson(lesson.toMap(forInsert: true));
    _lessons.add(lesson.copyWith(id: id));
    notifyListeners();
  }

  Future<void> updateLesson(Lesson lesson) async {
    await _db.updateLesson(lesson.toMap());
    final index = _lessons.indexWhere((l) => l.id == lesson.id);
    if (index != -1) {
      _lessons[index] = lesson;
      notifyListeners();
    }
  }

  Future<void> deleteLesson(int id) async {
    await _db.deleteLesson(id);
    _lessons.removeWhere((lesson) => lesson.id == id);
    notifyListeners();
  }

  // ==================== TASKS ====================

  Future<void> addTask(Task task) async {
    final id = await _db.createTask(task.toMap(forInsert: true));
    _tasks.add(task.copyWith(id: id));
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await _db.updateTask(task.toMap());
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  Future<void> toggleTaskCompletion(int id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      await _db.updateTask(_tasks[index].toMap());
      notifyListeners();
    }
  }

  Future<void> deleteTask(int id) async {
    await _db.deleteTask(id);
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  Future<void> clearCompletedTasks() async {
    await _db.deleteCompletedTasks();
    _tasks.removeWhere((task) => task.isCompleted);
    notifyListeners();
  }

  // ==================== TEACHERS ====================

  Future<void> addTeacher(Teacher teacher) async {
    final id = await _db.createTeacher(teacher.toMap(forInsert: true));
    _teachers.add(teacher.copyWith(id: id));
    notifyListeners();
  }

  Future<void> updateTeacher(Teacher teacher) async {
    await _db.updateTeacher(teacher.toMap());
    final index = _teachers.indexWhere((t) => t.id == teacher.id);
    if (index != -1) {
      _teachers[index] = teacher;
      notifyListeners();
    }
  }

  Future<void> deleteTeacher(int id) async {
    await _db.deleteTeacher(id);
    _teachers.removeWhere((teacher) => teacher.id == id);
    notifyListeners();
  }

  // ==================== UTILS ====================

  String getDayName(int dayOfWeek) {
    const days = ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'];
    return days[dayOfWeek - 1];
  }

  String getDayShortName(int dayOfWeek) {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days[dayOfWeek - 1];
  }

  String getDayNameFromDate(DateTime date) {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days[date.weekday - 1];
  }

  String getFullDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  Future<void> clearAllData() async {
    await _db.clearAllTables();
    _lessons.clear();
    _tasks.clear();
    _teachers.clear();
    notifyListeners();
  }

  Future<Map<String, int>> getDataStats() async {
    return {
      'lessons': await _db.getCount('lessons'),
      'tasks': await _db.getCount('tasks'),
      'teachers': await _db.getCount('teachers'),
    };
  }
}