import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init() {
    // Инициализация FFI для desktop (Windows/Mac/Linux)
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'studentflow.db');

    return await openDatabase(
      path,
      version: 4, 
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Таблица пар
    await db.execute('''
      CREATE TABLE lessons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_name TEXT NOT NULL,
        teacher_name TEXT NOT NULL,
        teacher_id INTEGER,
        room_number TEXT,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    // Таблица задач
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        deadline TEXT NOT NULL,
        priority INTEGER NOT NULL DEFAULT 1,
        is_completed INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Таблица преподавателей
    await db.execute('''
      CREATE TABLE teachers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        subjects TEXT NOT NULL,
        phone TEXT,
        email TEXT
      )
    ''');
  }

  // Миграция
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final tableInfo = await db.rawQuery('PRAGMA table_info(tasks)');
      final hasPriorityColumn = tableInfo.any((column) => column['name'] == 'priority');

      if (!hasPriorityColumn) {
        await db.execute('ALTER TABLE tasks ADD COLUMN priority INTEGER NOT NULL DEFAULT 1');
      }
    }

    if (oldVersion < 3) {
      await db.execute('ALTER TABLE lessons ADD COLUMN teacher_id INTEGER');

      await db.execute('''
        CREATE TABLE teachers_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          full_name TEXT NOT NULL,
          subjects TEXT NOT NULL,
          phone TEXT,
          email TEXT
        )
      ''');

      final oldTeachers = await db.query('teachers');
      for (var teacher in oldTeachers) {
        await db.insert('teachers_new', {
          'id': teacher['id'],
          'full_name': teacher['full_name'],
          'subjects': jsonEncode([teacher['subject']]),
          'phone': teacher['phone'] ?? '',
          'email': teacher['email'] ?? '',
        });
      }

      await db.execute('DROP TABLE teachers');
      await db.execute('ALTER TABLE teachers_new RENAME TO teachers');
    }

    if (oldVersion < 4) {
      // Добавляем колонку subject в tasks
      final tableInfo = await db.rawQuery('PRAGMA table_info(tasks)');
      final hasSubjectColumn = tableInfo.any((column) => column['name'] == 'subject');

      if (!hasSubjectColumn) {
        await db.execute('ALTER TABLE tasks ADD COLUMN subject TEXT NOT NULL DEFAULT ""');
      }
    }
  }

  // ==================== LESSONS ====================

  Future<int> createLesson(Map<String, dynamic> lesson) async {
    final db = await database;
    return await db.insert('lessons', lesson);
  }

  Future<List<Map<String, dynamic>>> getLessons() async {
    final db = await database;
    return await db.query('lessons', orderBy: 'date, start_time');
  }

  Future<List<Map<String, dynamic>>> getLessonsByDate(String date) async {
    final db = await database;
    return await db.query(
      'lessons',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'start_time',
    );
  }

  Future<int> updateLesson(Map<String, dynamic> lesson) async {
    final db = await database;
    return await db.update(
      'lessons',
      lesson,
      where: 'id = ?',
      whereArgs: [lesson['id']],
    );
  }

  Future<int> deleteLesson(int id) async {
    final db = await database;
    return await db.delete('lessons', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllTables() async {
    final db = await database;
    await db.delete('lessons');
    await db.delete('tasks');
    await db.delete('teachers');
  }

  Future<void> deleteDatabaseFile() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'studentflow.db');
    await deleteDatabase(path);
  }

  // ==================== TASKS ====================

  Future<int> createTask(Map<String, dynamic> task) async {
    final db = await database;
    return await db.insert('tasks', task);
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;
    // Сортируем: сначала по приоритету (DESC), потом по дедлайну (ASC)
    return await db.query('tasks', orderBy: 'priority DESC, deadline ASC');
  }

  Future<int> updateTask(Map<String, dynamic> task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task,
      where: 'id = ?',
      whereArgs: [task['id']],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCompletedTasks() async {
    final db = await database;
    return await db.delete('tasks', where: 'is_completed = ?', whereArgs: [1]);
  }

  // ==================== TEACHERS ====================

  Future<int> createTeacher(Map<String, dynamic> teacher) async {
    final db = await database;
    return await db.insert('teachers', teacher);
  }

  Future<List<Map<String, dynamic>>> getTeachers() async {
    final db = await database;
    return await db.query('teachers');
  }

  Future<int> updateTeacher(Map<String, dynamic> teacher) async {
    final db = await database;
    return await db.update(
      'teachers',
      teacher,
      where: 'id = ?',
      whereArgs: [teacher['id']],
    );
  }

  Future<int> deleteTeacher(int id) async {
    final db = await database;
    return await db.delete('teachers', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== UTILS ====================

  Future<int> getCount(String table) async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM $table');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}