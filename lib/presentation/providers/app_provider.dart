import 'package:flutter/material.dart';
import '../../data/models/lesson_model.dart';
import '../../data/models/task_model.dart';
import '../../data/models/teacher_model.dart';

class AppProvider with ChangeNotifier {
  // Списки данных
  final List<Lesson> _lessons = [];
  final List<Task> _tasks = [];
  final List<Teacher> _teachers = [];

  // Счётчик ID для новых записей
  int _lessonIdCounter = 1;
  int _taskIdCounter = 1;
  int _teacherIdCounter = 1;

  // Геттеры
  List<Lesson> get lessons => _lessons;
  List<Task> get tasks => _tasks;
  List<Teacher> get teachers => _teachers;

  // Получить пары на конкретный день недели
  List<Lesson> getLessonsByDay(int dayOfWeek) {
    return _lessons
        .where((lesson) => lesson.dayOfWeek == dayOfWeek)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // Получить активные задачи (не выполненные)
  List<Task> get activeTasks {
    return _tasks
        .where((task) => !task.isCompleted)
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  // Получить выполненные задачи
  List<Task> get completedTasks {
    return _tasks.where((task) => task.isCompleted).toList();
  }

  // ==================== LESSONS ====================

  void addLesson(Lesson lesson) {
    _lessons.add(lesson);
    notifyListeners();
  }

  void updateLesson(Lesson updatedLesson) {
    final index = _lessons.indexWhere((l) => l.id == updatedLesson.id);
    if (index != -1) {
      _lessons[index] = updatedLesson;
      notifyListeners();
    }
  }

  void deleteLesson(int id) {
    _lessons.removeWhere((lesson) => lesson.id == id);
    notifyListeners();
  }

  // ==================== TASKS ====================

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  void toggleTaskCompletion(int id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      notifyListeners();
    }
  }

  void deleteTask(int id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  void clearCompletedTasks() {
    _tasks.removeWhere((task) => task.isCompleted);
    notifyListeners();
  }

  // ==================== TEACHERS ====================

  void addTeacher(Teacher teacher) {
    _teachers.add(teacher);
    notifyListeners();
  }

  void updateTeacher(Teacher updatedTeacher) {
    final index = _teachers.indexWhere((t) => t.id == updatedTeacher.id);
    if (index != -1) {
      _teachers[index] = updatedTeacher;
      notifyListeners();
    }
  }

  void deleteTeacher(int id) {
    _teachers.removeWhere((teacher) => teacher.id == id);
    notifyListeners();
  }

  // ==================== UTILS ====================

  int generateLessonId() => _lessonIdCounter++;
  int generateTaskId() => _taskIdCounter++;
  int generateTeacherId() => _teacherIdCounter++;

  // Получить название дня недели
  String getDayName(int dayOfWeek) {
    const days = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье'
    ];
    return days[dayOfWeek - 1];
  }

  // Получить короткое название дня
  String getDayShortName(int dayOfWeek) {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days[dayOfWeek - 1];
  }

  // Очистить все данные (для настроек)
  void clearAllData() {
    _lessons.clear();
    _tasks.clear();
    _teachers.clear();
    _lessonIdCounter = 1;
    _taskIdCounter = 1;
    _teacherIdCounter = 1;
    notifyListeners();
  }

  // Заполнить тестовыми данными (для демонстрации)
  void fillTestData() {
    // Тестовые пары
    addLesson(Lesson(
      id: generateLessonId(),
      subjectName: 'Высшая математика',
      teacherName: 'Иванов И.И.',
      roomNumber: '305',
      startTime: '10:00',
      endTime: '11:30',
      dayOfWeek: 1,
    ));

    addLesson(Lesson(
      id: generateLessonId(),
      subjectName: 'Программирование',
      teacherName: 'Петров П.П.',
      roomNumber: '201',
      startTime: '12:00',
      endTime: '13:30',
      dayOfWeek: 1,
    ));

    addLesson(Lesson(
      id: generateLessonId(),
      subjectName: 'Физика',
      teacherName: 'Сидоров С.С.',
      roomNumber: '410',
      startTime: '14:00',
      endTime: '15:30',
      dayOfWeek: 2,
    ));

    // Тестовые задачи
    addTask(Task(
      id: generateTaskId(),
      title: 'Курсовая работа',
      description: 'Сделать 3 главы',
      deadline: DateTime.now().add(const Duration(days: 3)),
    ));

    addTask(Task(
      id: generateTaskId(),
      title: 'Лабораторная №5',
      description: 'Отчёт по физике',
      deadline: DateTime.now().add(const Duration(days: 7)),
    ));

    // Тестовые преподаватели
    addTeacher(Teacher(
      id: generateTeacherId(),
      fullName: 'Иванов Иван Иванович',
      subject: 'Высшая математика',
      phone: '+7 (999) 000-00-01',
      email: 'ivanov@university.ru',
    ));

    addTeacher(Teacher(
      id: generateTeacherId(),
      fullName: 'Петров Пётр Петрович',
      subject: 'Программирование',
      phone: '+7 (999) 000-00-02',
      email: 'petrov@university.ru',
    ));

    notifyListeners();
  }
}