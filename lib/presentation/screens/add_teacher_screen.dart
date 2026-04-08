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
  late TextEditingController _subjectController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.teacher != null;
    
    _nameController = TextEditingController(text: widget.teacher?.fullName ?? '');
    _subjectController = TextEditingController(text: widget.teacher?.subject ?? '');
    _phoneController = TextEditingController(text: widget.teacher?.phone ?? '');
    _emailController = TextEditingController(text: widget.teacher?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subjectController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveTeacher() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<AppProvider>();
      
      final teacher = Teacher(
        id: widget.teacher?.id ?? provider.generateTeacherId(),
        fullName: _nameController.text.trim(),
        subject: _subjectController.text.trim(),
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
              
              const SizedBox(height: 16),
              
              // Предмет
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Предмет *',
                  prefixIcon: Icon(Icons.book),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите предмет';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Телефон
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Телефон *',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите телефон';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите email';
                  }
                  if (!value.contains('@')) {
                    return 'Введите корректный email';
                  }
                  return null;
                },
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