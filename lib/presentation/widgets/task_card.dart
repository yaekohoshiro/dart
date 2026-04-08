import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Цвет в зависимости от срочности
    Color urgencyColor;
    String urgencyText;
    
    switch (task.urgencyStatus) {
      case 'today':
        urgencyColor = Colors.red;
        urgencyText = 'Сегодня!';
        break;
      case 'urgent':
        urgencyColor = Colors.orange;
        urgencyText = '${task.daysUntilDeadline} дн.';
        break;
      case 'soon':
        urgencyColor = Colors.amber;
        urgencyText = '${task.daysUntilDeadline} дн.';
        break;
      case 'done':
        urgencyColor = Colors.green;
        urgencyText = 'Выполнено';
        break;
      default:
        urgencyColor = Colors.grey;
        urgencyText = '${task.daysUntilDeadline} дн.';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(task.id.toString()),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete?.call(),
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Чекбокс
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (_) => onToggle?.call(),
                  activeColor: Colors.green,
                ),
                
                const SizedBox(width: 12),
                
                // Контент
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.isCompleted ? Colors.grey : null,
                            ),
                      ),
                      
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 8),
                      
                      // Дедлайн и статус
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: urgencyColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${task.deadline.day}.${task.deadline.month}.${task.deadline.year}',
                            style: TextStyle(
                              color: urgencyColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: urgencyColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              urgencyText,
                              style: TextStyle(
                                color: urgencyColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Кнопка меню
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
          ),
        ),
      ),
    );
  }
}