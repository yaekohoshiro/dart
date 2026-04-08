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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    teacher.fullName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                PopupMenuButton(
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
            
            // Предмет
            Row(
              children: [
                Icon(Icons.book, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  teacher.subject,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Контакты
            Row(
              children: [
                // Кнопка звонка
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCall,
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Позвонить'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Кнопка почты
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEmail,
                    icon: const Icon(Icons.email, size: 18),
                    label: const Text('Написать'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
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