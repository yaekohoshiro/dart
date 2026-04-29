import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          _buildSectionTitle('Внешний вид', context),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              
              return Card(
                child: SwitchListTile(
                  title: Text(
                    'Тёмная тема',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Включить тёмный режим',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.grey[600],
                    ),
                  ),
                  value: themeProvider.isDarkMode,
                  onChanged: themeProvider.toggleTheme,
                  secondary: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: isDark ? Colors.white70 : Colors.grey[600],
                  ),
                  activeColor: Theme.of(context).primaryColor,
                  activeTrackColor: Theme.of(context).primaryColor.withOpacity(0.5),
                  hoverColor: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Раздел: Данные
          _buildSectionTitle('Данные', context),
          Card(
            child: ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Просмотреть данные'),
              subtitle: const Text('Показать всю информацию'),
              onTap: () => _showDataSummary(context),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Очистить все данные'),
              subtitle: const Text('Удалить всё безвозвратно'),
              onTap: () => _confirmClearAll(context),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[400]
              : Colors.grey[600],
        ),
      ),
    );
  }

  void _showDataSummary(BuildContext context) {
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

  void _confirmClearAll(BuildContext context) {
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
}