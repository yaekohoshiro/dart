class Teacher {
  final int id;
  final String fullName;
  final String subject;
  final String phone;
  final String email;

  Teacher({
    required this.id,
    required this.fullName,
    required this.subject,
    required this.phone,
    required this.email,
  });

  Teacher copyWith({
    int? id,
    String? fullName,
    String? subject,
    String? phone,
    String? email,
  }) {
    return Teacher(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      subject: subject ?? this.subject,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'subject': subject,
      'phone': phone,
      'email': email,
    };
  }

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      id: map['id'],
      fullName: map['fullName'],
      subject: map['subject'],
      phone: map['phone'],
      email: map['email'],
    );
  }
}