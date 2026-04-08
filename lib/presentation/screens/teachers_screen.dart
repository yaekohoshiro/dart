import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../widgets/teacher_card.dart';
import '../../data/models/teacher_model.dart';
import 'add_teacher_screen.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Преподаватели'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fillTestData,
            tooltip: 'Тестовые данные',
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final teachers = provider.teachers;
          
          if (teachers.isEmpty) {
            return _buildEmptyState();
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final teacher = teachers[index];
              return TeacherCard(
                teacher: teacher,
                onEdit: () => _editTeacher(teacher),
                onDelete: () => _deleteTeacher(teacher),
                onCall: () => _makeCall(teacher.phone),
                onEmail: () => _sendEmail(teacher.email),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Преподавателей пока нет',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Нажми + чтобы добавить',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _editTeacher(Teacher teacher) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AddTeacherScreen(teacher: teacher),
    ),
  );
}

  void _deleteTeacher(teacher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить преподавателя?'),
        content: Text('Вы уверены, что хотите удалить "${teacher.fullName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().deleteTeacher(teacher.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Преподаватель удалён')),
              );
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (mounted) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось совершить звонок')),
      );
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть почту')),
      );
    }
  }

  void _fillTestData() {
    context.read<AppProvider>().fillTestData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Тестовые данные добавлены')),
    );
  }
}