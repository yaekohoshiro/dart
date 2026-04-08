class Lesson {
  final int id;
  final String subjectName;
  final String teacherName;
  final String roomNumber;
  final String startTime;
  final String endTime;
  final int dayOfWeek; // 1 = Пн, 2 = Вт, ..., 7 = Вс

  Lesson({
    required this.id,
    required this.subjectName,
    required this.teacherName,
    required this.roomNumber,
    required this.startTime,
    required this.endTime,
    required this.dayOfWeek,
  });

  // Создаём копию объекта (для редактирования)
  Lesson copyWith({
    int? id,
    String? subjectName,
    String? teacherName,
    String? roomNumber,
    String? startTime,
    String? endTime,
    int? dayOfWeek,
  }) {
    return Lesson(
      id: id ?? this.id,
      subjectName: subjectName ?? this.subjectName,
      teacherName: teacherName ?? this.teacherName,
      roomNumber: roomNumber ?? this.roomNumber,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
    );
  }

  // Преобразуем в Map (для сохранения в будущем, если понадобится)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectName': subjectName,
      'teacherName': teacherName,
      'roomNumber': roomNumber,
      'startTime': startTime,
      'endTime': endTime,
      'dayOfWeek': dayOfWeek,
    };
  }

  // Создаём из Map
  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'],
      subjectName: map['subjectName'],
      teacherName: map['teacherName'],
      roomNumber: map['roomNumber'],
      startTime: map['startTime'],
      endTime: map['endTime'],
      dayOfWeek: map['dayOfWeek'],
    );
  }
}