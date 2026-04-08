class Task {
  final int id;
  final String title;
  final String description;
  final DateTime deadline;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    this.isCompleted = false,
  });

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? deadline,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      deadline: DateTime.parse(map['deadline']),
      isCompleted: map['isCompleted'],
    );
  }

  // Получаем количество дней до дедлайна
  int get daysUntilDeadline {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;
    return difference < 0 ? 0 : difference;
  }

  // Получаем статус срочности
  String get urgencyStatus {
    if (isCompleted) return 'done';
    if (daysUntilDeadline == 0) return 'today';
    if (daysUntilDeadline <= 2) return 'urgent';
    if (daysUntilDeadline <= 5) return 'soon';
    return 'normal';
  }
}