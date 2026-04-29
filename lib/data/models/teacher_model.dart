import 'dart:convert';

class Teacher {
  final int id;
  final String fullName;
  final List<String> subjects; // Теперь список предметов!
  final String phone;
  final String email;

  Teacher({
    required this.id,
    required this.fullName,
    required this.subjects,
    required this.phone,
    required this.email,
  });

  Teacher copyWith({
    int? id,
    String? fullName,
    List<String>? subjects,
    String? phone,
    String? email,
  }) {
    return Teacher(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      subjects: subjects ?? this.subjects,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap({bool forInsert = false}) {
    final map = <String, dynamic>{
      'full_name': fullName,
      'subjects': jsonEncode(subjects), // Сохраняем как JSON
      'phone': phone,
      'email': email,
    };
    
    if (!forInsert) {
      map['id'] = id;
    }
    
    return map;
  }

  factory Teacher.fromMap(Map<String, dynamic> map) {
    List<String> subjectsList;
    if (map['subjects'] is String) {
      subjectsList = List<String>.from(jsonDecode(map['subjects'] as String));
    } else if (map['subjects'] is List) {
      subjectsList = List<String>.from(map['subjects']);
    } else {
      subjectsList = [];
    }
    
    return Teacher(
      id: map['id'] as int,
      fullName: map['full_name'] as String,
      subjects: subjectsList,
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
    );
  }
}