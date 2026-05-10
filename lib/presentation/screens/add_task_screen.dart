import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/task_model.dart';
import '../providers/app_provider.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;

  const AddTaskScreen({super.key, this.task});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  
  DateTime _selectedDate = DateTime.now();
  TaskPriority _selectedPriority = TaskPriority.medium;
  String? _selectedSubject;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.task != null;
    
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    
    if (widget.task != null) {
      _selectedDate = widget.task!.deadline;
      _selectedPriority = widget.task!.priority;
      _selectedSubject = widget.task!.subject.isNotEmpty ? widget.task!.subject : null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<AppProvider>();
      
      final task = Task(
        id: widget.task?.id ?? 0,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        deadline: _selectedDate,
        priority: _selectedPriority,
        subject: _selectedSubject ?? '',
        isCompleted: widget.task?.isCompleted ?? false,
      );
      
      if (_isEditing) {
        provider.updateTask(task);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Задача обновлена')),
        );
      } else {
        provider.addTask(task);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Задача добавлена')),
        );
      }
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редактировать задачу' : 'Добавить задачу'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Название задачи
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: textColor),
                decoration: const InputDecoration(
                  labelText: 'Название *',
                  prefixIcon: Icon(Icons.task),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите название задачи';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Описание
              TextFormField(
                controller: _descriptionController,
                style: TextStyle(color: textColor),
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 24),
              
              // Выбор предмета
              Text(
                'Предмет',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor),
              ),
              const SizedBox(height: 8),
              Consumer<AppProvider>(
                builder: (context, provider, child) {
                  // Собираем все уникальные предметы от всех преподавателей
                  final allSubjects = <String>{};
                  for (var teacher in provider.teachers) {
                    allSubjects.addAll(teacher.subjects);
                  }
                  final subjectsList = allSubjects.toList()..sort();
                  
                  if (subjectsList.isEmpty) {
                    return Card(
                      color: Colors.orange.withOpacity(0.2),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.orange),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Нет предметов',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const Text(
                                    'Сначала добавьте преподавателей с предметами',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return DropdownButtonFormField<String>(
                    value: _selectedSubject,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.book),
                    ),
                    isExpanded: true,
                    hint: const Text('Выберите предмет'),
                    items: subjectsList.map((subject) {
                      return DropdownMenuItem(
                        value: subject,
                        child: Text(
                          subject,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedSubject = value);
                    },
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Приоритет
              Text(
                'Приоритет',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildPriorityChip(
                      'Низкий',
                      Icons.arrow_downward,
                      Colors.green,
                      TaskPriority.low,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPriorityChip(
                      'Средний',
                      Icons.remove,
                      Colors.orange,
                      TaskPriority.medium,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPriorityChip(
                      'Высокий',
                      Icons.arrow_upward,
                      Colors.red,
                      TaskPriority.high,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Выбор даты дедлайна
              Text(
                'Дедлайн *',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                    color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 16),
                      Text(
                        DateFormat('d MMMM yyyy', 'ru_RU').format(_selectedDate),
                        style: TextStyle(fontSize: 16, color: textColor),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Кнопка сохранения
              ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isEditing ? 'Сохранить изменения' : 'Добавить задачу',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String label, IconData icon, Color color, TaskPriority priority) {
    final isSelected = _selectedPriority == priority;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? color : (isDark ? const Color(0xFF2C2C2C) : Colors.grey[200]),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? null : Border.all(color: Colors.grey),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() => _selectedPriority = priority);
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    const Icon(Icons.check, size: 12, color: Colors.white),
                    const SizedBox(width: 2),
                  ],
                  Icon(icon, size: 12, color: isSelected ? Colors.white : color),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}