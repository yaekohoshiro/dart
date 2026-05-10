import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/lesson_model.dart';
import '../../data/models/teacher_model.dart';
import '../providers/app_provider.dart';

class AddLessonScreen extends StatefulWidget {
  final Lesson? lesson;

  const AddLessonScreen({super.key, this.lesson});

  @override
  State<AddLessonScreen> createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends State<AddLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _subjectController;
  late TextEditingController _roomController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  
  DateTime _selectedDate = DateTime.now();
  int? _selectedTeacherId;
  String? _selectedSubject;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.lesson != null;
    
    _subjectController = TextEditingController(text: widget.lesson?.subjectName ?? '');
    _roomController = TextEditingController(text: widget.lesson?.roomNumber ?? '');
    _startTimeController = TextEditingController(text: widget.lesson?.startTime ?? '');
    _endTimeController = TextEditingController(text: widget.lesson?.endTime ?? '');
    
    if (widget.lesson != null) {
      _selectedDate = widget.lesson!.date;
      // Ищем ID преподавателя по имени
      final providers = context.read<AppProvider>();
      final teacher = providers.teachers.firstWhere(
        (t) => t.fullName == widget.lesson!.teacherName,
        orElse: () => Teacher(id: 0, fullName: '', subjects: [], phone: '', email: ''),
      );
      _selectedTeacherId = teacher.id > 0 ? teacher.id : null;
      _selectedSubject = widget.lesson!.subjectName;
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _roomController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(bool isStart) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (time != null) {
      final formatted = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isStart) {
          _startTimeController.text = formatted;
        } else {
          _endTimeController.text = formatted;
        }
      });
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _onTeacherSelected(int? teacherId) {
    setState(() {
      _selectedTeacherId = teacherId;
      _selectedSubject = null;
      
      if (teacherId != null) {
        final provider = context.read<AppProvider>();
        final teacher = provider.teachers.firstWhere(
          (t) => t.id == teacherId,
          orElse: () => Teacher(id: 0, fullName: '', subjects: [], phone: '', email: ''),
        );
        if (teacher.subjects.isNotEmpty) {
          _selectedSubject = teacher.subjects.first;
          _subjectController.text = _selectedSubject!;
        }
      }
    });
  }

  void _onSubjectSelected(String? subject) {
    setState(() {
      _selectedSubject = subject;
      _subjectController.text = subject ?? '';
    });
  }

  void _saveLesson() {
    if (_formKey.currentState!.validate()) {
      if (_selectedTeacherId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Выберите преподавателя')),
        );
        return;
      }

      final provider = context.read<AppProvider>();
      
      // Находим преподавателя по ID
      final teacher = provider.teachers.firstWhere(
        (t) => t.id == _selectedTeacherId,
        orElse: () => Teacher(id: 0, fullName: '', subjects: [], phone: '', email: ''),
      );

      final lesson = Lesson(
        id: widget.lesson?.id ?? 0,
        subjectName: _subjectController.text.trim(),
        teacherName: teacher.fullName,
        roomNumber: _roomController.text.trim(),
        startTime: _startTimeController.text,
        endTime: _endTimeController.text,
        date: _selectedDate,
      );
      
      if (_isEditing) {
        provider.updateLesson(lesson);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пара обновлена')),
        );
      } else {
        provider.addLesson(lesson);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пара добавлена')),
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
        title: Text(_isEditing ? 'Редактировать пару' : 'Добавить пару'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Дата
              Text(
                'Дата *',
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
                        '${_getDayShortName(_selectedDate.weekday)}, ${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                        style: TextStyle(fontSize: 16, color: textColor),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Выбор преподавателя
              Text(
                'Преподаватель *',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor),
              ),
              const SizedBox(height: 8),
              Consumer<AppProvider>(
                builder: (context, provider, child) {
                  final teachers = provider.teachers;
                  
                  if (teachers.isEmpty) {
                    return Card(
                      color: Colors.orange.withOpacity(0.2),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Нет преподавателей',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Сначала добавьте преподавателей в разделе "Преподаватели"',
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
                  
                  return DropdownButtonFormField<int>(
                    value: _selectedTeacherId,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person),
                    ),
                    isExpanded: true,
                    hint: const Text('Выберите преподавателя'),
                    items: teachers.map((teacher) {
                      return DropdownMenuItem(
                        value: teacher.id,
                        child: Text(
                          teacher.fullName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          ),
                      );
                    }).toList(),
                    onChanged: _onTeacherSelected,
                    validator: (value) {
                      if (value == null) {
                        return 'Выберите преподавателя';
                      }
                      return null;
                    },
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Выбор предмета (из предметов преподавателя)
              if (_selectedTeacherId != null) ...[
                Consumer<AppProvider>(
                  builder: (context, provider, child) {
                    final teacher = provider.teachers.firstWhere(
                      (t) => t.id == _selectedTeacherId,
                      orElse: () => Teacher(id: 0, fullName: '', subjects: [], phone: '', email: ''),
                    );
                    
                    if (teacher.subjects.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Предмет *',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedSubject,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.book),
                          ),
                          isExpanded: true,
                          items: teacher.subjects.map((subject) {
                            return DropdownMenuItem(
                              value: subject,
                              child: Text(
                                subject,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                ),
                            );
                          }).toList(),
                          onChanged: _onSubjectSelected,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Выберите предмет';
                            }
                            return null;
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
              
              // Аудитория
              TextFormField(
                controller: _roomController,
                style: TextStyle(color: textColor),
                decoration: const InputDecoration(
                  labelText: 'Аудитория',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Время проведения
              Text(
                'Время проведения *',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(true),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                          color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time),
                            const SizedBox(width: 12),
                            Text(
                              _startTimeController.text.isEmpty ? 'Начало' : _startTimeController.text,
                              style: TextStyle(
                                fontSize: 16,
                                color: _startTimeController.text.isEmpty ? Colors.grey : textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('—'),
                  ),
                  
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(false),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                          color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time),
                            const SizedBox(width: 12),
                            Text(
                              _endTimeController.text.isEmpty ? 'Конец' : _endTimeController.text,
                              style: TextStyle(
                                fontSize: 16,
                                color: _endTimeController.text.isEmpty ? Colors.grey : textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Кнопка сохранения
              ElevatedButton(
                onPressed: _saveLesson,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isEditing ? 'Сохранить изменения' : 'Добавить пару',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDayShortName(int weekday) {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days[weekday - 1];
  }
}