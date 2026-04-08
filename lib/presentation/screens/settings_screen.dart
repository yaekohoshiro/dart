import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/app_provider.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemeSetting();
  }

  Future<void> _loadThemeSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _toggleTheme(bool value) async {
    setState(() => _isDarkMode = value);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    
    // Примечание: для полного переключения темы нужно обновить MaterialApp
    // В реальном проекте это делается через провайдер тем
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Раздел: Внешний вид
          _buildSectionTitle('Внешний вид'),
          Card(
            child: SwitchListTile(
              title: const Text('Тёмная тема'),
              subtitle: const Text('Включить тёмный режим'),
              value: _isDarkMode,
              onChanged: _toggleTheme,
              secondary: const Icon(Icons.dark_mode),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Раздел: Данные
          _buildSectionTitle('Данные'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Просмотреть данные'),
              subtitle: const Text('Показать всю информацию'),
              onTap: () => _showDataSummary(),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Очистить все данные'),
              subtitle: const Text('Удалить всё безвозвратно'),
              onTap: () => _confirmClearAll(),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Раздел: О приложении
          _buildSectionTitle('О приложении'),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Версия'),
                  subtitle: Text('1.0.0'),
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Разработчик'),
                  subtitle: Text('Студент'),
                ),
                ListTile(
                  leading: Icon(Icons.school),
                  title: Text('Учебный проект'),
                  subtitle: Text('Flutter 2024'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Кнопка сброса онбординга
          Card(
            child: ListTile(
              leading: const Icon(Icons.restart_alt),
              title: const Text('Показать приветствие снова'),
              onTap: () => _resetOnboarding(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(), // Преобразуй текст напрямую
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  void _showDataSummary() {
    final provider = context.read<AppProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Статистика'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Пар', provider.lessons.length),
            _buildStatRow('Задач', provider.tasks.length),
            _buildStatRow('Преподавателей', provider.teachers.length),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '$count',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить все данные?'),
        content: const Text(
          'Это действие нельзя отменить. Все пары, задачи и преподаватели будут удалены.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().clearAllData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Все данные очищены'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Очистить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', true);
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        (route) => false,
      );
    }
  }
}