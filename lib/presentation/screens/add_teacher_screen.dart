import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/teacher_model.dart';
import '../providers/app_provider.dart';

class AddTeacherScreen extends StatefulWidget {
  final Teacher? teacher;

  const AddTeacherScreen({super.key, this.teacher});

  @override
  State<AddTeacherScreen> createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _subjectController;
  
  List<String> _subjects = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.teacher != null;
    
    _nameController = TextEditingController(text: widget.teacher?.fullName ?? '');
    _phoneController = TextEditingController(text: widget.teacher?.phone ?? '');
    _emailController = TextEditingController(text: widget.teacher?.email ?? '');
    _subjectController = TextEditingController();
    
    if (widget.teacher != null) {
      _subjects = List.from(widget.teacher!.subjects);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  void _addSubject() {
    final subject = _subjectController.text.trim();
    if (subject.isNotEmpty && !_subjects.contains(subject)) {
      setState(() {
        _subjects.add(subject);
        _subjectController.clear();
      });
    }
  }

  void _removeSubject(String subject) {
    setState(() {
      _subjects.remove(subject);
    });
  }

  void _saveTeacher() {
    if (_formKey.currentState!.validate()) {
      if (_subjects.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Добавьте хотя бы один предмет')),
        );
        return;
      }

      final provider = context.read<AppProvider>();
      
      final teacher = Teacher(
        id: widget.teacher?.id ?? 0,
        fullName: _nameController.text.trim(),
        subjects: _subjects,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
      );
      
      if (_isEditing) {
        provider.updateTeacher(teacher);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Преподаватель обновлён')),
        );
      } else {
        provider.addTeacher(teacher);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Преподаватель добавлен')),
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
        title: Text(_isEditing ? 'Редактировать' : 'Добавить преподавателя'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ФИО
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: textColor),
                decoration: const InputDecoration(
                  labelText: 'ФИО *',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите ФИО';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Предметы
              Text(
                'Предметы *',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _subjectController,
                      style: TextStyle(color: textColor),
                      decoration: const InputDecoration(
                        labelText: 'Добавить предмет',
                        prefixIcon: Icon(Icons.book),
                        hintText: 'Например: Математика',
                      ),
                      onFieldSubmitted: (_) => _addSubject(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _addSubject,
                    icon: const Icon(Icons.add),
                    label: const Text('Добавить'),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Список добавленных предметов
              if (_subjects.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _subjects.map((subject) {
                    return Chip(
                      label: Text(subject),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => _removeSubject(subject),
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    );
                  }).toList(),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Телефон
              TextFormField(
                controller: _phoneController,
                style: TextStyle(color: textColor),
                decoration: const InputDecoration(
                  labelText: 'Телефон',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              
              const SizedBox(height: 16),
              
              // Email
              TextFormField(
                controller: _emailController,
                style: TextStyle(color: textColor),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              
              const SizedBox(height: 32),
              
              // Кнопка сохранения
              ElevatedButton(
                onPressed: _saveTeacher,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isEditing ? 'Сохранить изменения' : 'Добавить преподавателя',
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