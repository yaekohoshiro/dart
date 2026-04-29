import 'package:flutter/material.dart';

enum TaskPriority { low, medium, high }

class Task {
  final int id;
  final String title;
  final String description;
  final DateTime deadline;
  final TaskPriority priority;
  final String subject; // ← Добавил поле предмета
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    this.priority = TaskPriority.medium,
    this.subject = '', // По умолчанию пустой
    this.isCompleted = false,
  });

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? deadline,
    TaskPriority? priority,
    String? subject,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      subject: subject ?? this.subject,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap({bool forInsert = false}) {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'priority': priority.index,
      'subject': subject,
      'is_completed': isCompleted ? 1 : 0,
    };
    
    if (!forInsert) {
      map['id'] = id;
    }
    
    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      deadline: DateTime.parse(map['deadline'] as String),
      priority: TaskPriority.values[map['priority'] as int? ?? 1],
      subject: map['subject'] as String? ?? '',
      isCompleted: map['is_completed'] as int == 1,
    );
  }

  int get daysUntilDeadline {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;
    return difference < 0 ? 0 : difference;
  }

  String get urgencyStatus {
    if (isCompleted) return 'done';
    if (daysUntilDeadline == 0) return 'today';
    if (daysUntilDeadline <= 2) return 'urgent';
    if (daysUntilDeadline <= 5) return 'soon';
    return 'normal';
  }

  Color getPriorityColor() {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  String getPriorityText() {
    switch (priority) {
      case TaskPriority.high:
        return 'Высокий';
      case TaskPriority.medium:
        return 'Средний';
      case TaskPriority.low:
        return 'Низкий';
    }
  }

  IconData getPriorityIcon() {
    switch (priority) {
      case TaskPriority.high:
        return Icons.arrow_upward;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.low:
        return Icons.arrow_downward;
    }
  }
}