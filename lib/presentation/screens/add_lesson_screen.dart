import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/lesson_model.dart';
import '../providers/app_provider.dart';

class AddLessonScreen extends StatefulWidget {
  final Lesson? lesson; // Если null - создание, иначе - редактирование

  const AddLessonScreen({super.key, this.lesson});

  @override
  State<AddLessonScreen> createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends State<AddLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _subjectController;
  late TextEditingController _teacherController;
  late TextEditingController _roomController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  
  int _selectedDay = 1;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.lesson != null;
    
    _subjectController = TextEditingController(text: widget.lesson?.subjectName ?? '');
    _teacherController = TextEditingController(text: widget.lesson?.teacherName ?? '');
    _roomController = TextEditingController(text: widget.lesson?.roomNumber ?? '');
    _startTimeController = TextEditingController(text: widget.lesson?.startTime ?? '');
    _endTimeController = TextEditingController(text: widget.lesson?.endTime ?? '');
    
    if (widget.lesson != null) {
      _selectedDay = widget.lesson!.dayOfWeek;
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _teacherController.dispose();
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

  void _saveLesson() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<AppProvider>();
      
      final lesson = Lesson(
        id: widget.lesson?.id ?? provider.generateLessonId(),
        subjectName: _subjectController.text.trim(),
        teacherName: _teacherController.text.trim(),
        roomNumber: _roomController.text.trim(),
        startTime: _startTimeController.text,
        endTime: _endTimeController.text,
        dayOfWeek: _selectedDay,
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
              // Название предмета
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Предмет *',
                  prefixIcon: Icon(Icons.book),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите название предмета';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Преподаватель
              TextFormField(
                controller: _teacherController,
                decoration: const InputDecoration(
                  labelText: 'Преподаватель *',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите имя преподавателя';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Аудитория
              TextFormField(
                controller: _roomController,
                decoration: const InputDecoration(
                  labelText: 'Аудитория *',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите номер аудитории';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // День недели
              Text(
                'День недели',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _selectedDay,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Понедельник')),
                  DropdownMenuItem(value: 2, child: Text('Вторник')),
                  DropdownMenuItem(value: 3, child: Text('Среда')),
                  DropdownMenuItem(value: 4, child: Text('Четверг')),
                  DropdownMenuItem(value: 5, child: Text('Пятница')),
                  DropdownMenuItem(value: 6, child: Text('Суббота')),
                  DropdownMenuItem(value: 7, child: Text('Воскресенье')),
                ],
                onChanged: (value) {
                  setState(() => _selectedDay = value!);
                },
              ),
              
              const SizedBox(height: 24),
              
              // Время начала
              Text(
                'Время проведения',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startTimeController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Начало *',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      onTap: () => _selectTime(true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Выберите время';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('—'),
                  ),
                  
                  Expanded(
                    child: TextFormField(
                      controller: _endTimeController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Конец *',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      onTap: () => _selectTime(false),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Выберите время';
                        }
                        return null;
                      },
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
}