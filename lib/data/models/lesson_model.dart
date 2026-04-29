class Lesson {
  final int id;
  final String subjectName;
  final String teacherName;
  final String roomNumber;
  final String startTime;
  final String endTime;
  final DateTime date;

  Lesson({
    required this.id,
    required this.subjectName,
    required this.teacherName,
    required this.roomNumber,
    required this.startTime,
    required this.endTime,
    required this.date,
  });

  Lesson copyWith({
    int? id,
    String? subjectName,
    String? teacherName,
    String? roomNumber,
    String? startTime,
    String? endTime,
    DateTime? date,
  }) {
    return Lesson(
      id: id ?? this.id,
      subjectName: subjectName ?? this.subjectName,
      teacherName: teacherName ?? this.teacherName,
      roomNumber: roomNumber ?? this.roomNumber,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap({bool forInsert = false}) {
    final map = <String, dynamic>{
      'subject_name': subjectName,
      'teacher_name': teacherName,
      'room_number': roomNumber,
      'start_time': startTime,
      'end_time': endTime,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD
    };
    
    if (!forInsert) {
      map['id'] = id;
    }
    
    return map;
  }

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] as int,
      subjectName: map['subject_name'] as String,
      teacherName: map['teacher_name'] as String,
      roomNumber: map['room_number'] as String,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      date: DateTime.parse(map['date'] as String),
    );
  }

  String get formattedDate {
    return '${date.day}.${date.month}.${date.year}';
  }

  String get dayName {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days[date.weekday - 1];
  }
}