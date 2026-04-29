import 'package:flutter/material.dart';
import '../../data/models/teacher_model.dart';

class TeacherCard extends StatelessWidget {
  final Teacher teacher;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onCall;
  final VoidCallback? onEmail;

  const TeacherCard({
    super.key,
    required this.teacher,
    this.onEdit,
    this.onDelete,
    this.onCall,
    this.onEmail,
  });

  bool _isValidEmail(String email) {
    if (email.isEmpty) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    if (phone.isEmpty) return false;
    return RegExp(r'^[\d\s\-\+\(\)]{10,}$').hasMatch(phone);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.grey[700];
    
    final hasValidPhone = _isValidPhone(teacher.phone);
    final hasValidEmail = _isValidEmail(teacher.email);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    teacher.fullName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: textColor),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Редактировать'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Удалить', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') onEdit?.call();
                    if (value == 'delete') onDelete?.call();
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Предметы (список)
            if (teacher.subjects.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: teacher.subjects.map((subject) {
                  return Chip(
                    label: Text(
                      subject,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
            
            // Телефон (если есть)
            if (teacher.phone.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone, size: 18, color: subtitleColor),
                  const SizedBox(width: 8),
                  Text(
                    teacher.phone,
                    style: TextStyle(
                      color: hasValidPhone ? subtitleColor : Colors.grey,
                      fontStyle: hasValidPhone ? FontStyle.normal : FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
            
            // Email (если есть)
            if (teacher.email.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.email, size: 18, color: subtitleColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      teacher.email,
                      style: TextStyle(
                        color: hasValidEmail ? subtitleColor : Colors.grey,
                        fontStyle: hasValidEmail ? FontStyle.normal : FontStyle.italic,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Кнопки действий
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: hasValidPhone ? onCall : null,
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Позвонить'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: hasValidPhone 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey,
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: hasValidEmail ? onEmail : null,
                    icon: const Icon(Icons.email, size: 18),
                    label: const Text('Написать'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: hasValidEmail 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}