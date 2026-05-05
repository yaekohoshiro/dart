import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init() {
    // Инициализация FFI ТОЛЬКО для Desktop
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Для Desktop нужен sqflite_common_ffi
      // Но на мобильных используем стандартный sqflite
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path;
    
    // Правильный путь для каждой платформы
    if (Platform.isAndroid || Platform.isIOS) {
      // Мобильные: стандартный путь для баз данных
      final dbPath = await getDatabasesPath();
      path = join(dbPath, 'studentflow.db');
    } else {
      // Desktop: путь в документах приложения
      final appDir = await getApplicationDocumentsDirectory();
      path = join(appDir.path, 'studentflow.db');
    }

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
        subject TEXT NOT NULL DEFAULT '',
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

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final tableInfo = await db.rawQuery('PRAGMA table_info(tasks)');
      final hasPriority = tableInfo.any((c) => c['name'] == 'priority');
      if (!hasPriority) {
        await db.execute('ALTER TABLE tasks ADD COLUMN priority INTEGER NOT NULL DEFAULT 1');
      }
    }
    
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE lessons ADD COLUMN teacher_id INTEGER');
      
      // Миграция teachers: subject → subjects (JSON)
      await db.execute('''
        CREATE TABLE teachers_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          full_name TEXT NOT NULL,
          subjects TEXT NOT NULL,
          phone TEXT,
          email TEXT
        )
      ''');
      
      final old = await db.query('teachers');
      for (var t in old) {
        await db.insert('teachers_new', {
          'id': t['id'],
          'full_name': t['full_name'],
          'subjects': jsonEncode([t['subject']]),
          'phone': t['phone'] ?? '',
          'email': t['email'] ?? '',
        });
      }
      await db.execute('DROP TABLE teachers');
      await db.execute('ALTER TABLE teachers_new RENAME TO teachers');
    }
    
    if (oldVersion < 4) {
      final tableInfo = await db.rawQuery('PRAGMA table_info(tasks)');
      final hasSubject = tableInfo.any((c) => c['name'] == 'subject');
      if (!hasSubject) {
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
    return await db.query('lessons', where: 'date = ?', whereArgs: [date], orderBy: 'start_time');
  }

  Future<int> updateLesson(Map<String, dynamic> lesson) async {
    final db = await database;
    return await db.update('lessons', lesson, where: 'id = ?', whereArgs: [lesson['id']]);
  }

  Future<int> deleteLesson(int id) async {
    final db = await database;
    return await db.delete('lessons', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== TASKS ====================
  Future<int> createTask(Map<String, dynamic> task) async {
    final db = await database;
    return await db.insert('tasks', task);
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;
    return await db.query('tasks', orderBy: 'priority DESC, deadline ASC');
  }

  Future<int> updateTask(Map<String, dynamic> task) async {
    final db = await database;
    return await db.update('tasks', task, where: 'id = ?', whereArgs: [task['id']]);
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
    return await db.update('teachers', teacher, where: 'id = ?', whereArgs: [teacher['id']]);
  }

  Future<int> deleteTeacher(int id) async {
    final db = await database;
    return await db.delete('teachers', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== UTILS ====================
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

  Future<int> getCount(String table) async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM $table');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}