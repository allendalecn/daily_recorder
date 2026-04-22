import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSection(context, '通用', [
            ListTile(
              leading: const Icon(Icons.water_drop),
              title: const Text('每日饮水目标'),
              subtitle: Text('${settings.waterGoalML} ml'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showWaterGoalDialog(context, ref, settings.waterGoalML),
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('提醒设置'),
              subtitle: const Text('未开启'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('提醒功能即将推出')),
              ),
            ),
          ]),
          _buildSection(context, '数据', [
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('导出数据'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('导出功能即将推出')),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title:
                  const Text('清除所有数据', style: TextStyle(color: Colors.red)),
              onTap: () => _showClearDataDialog(context, ref),
            ),
          ]),
          _buildSection(context, '关于', [
            const ListTile(
              leading: Icon(Icons.info),
              title: Text('版本'),
              subtitle: Text('1.0.0'),
            ),
          ]),
        ],
      ),
    );
  }

  void _showWaterGoalDialog(
      BuildContext context, WidgetRef ref, int currentGoal) {
    final controller = TextEditingController(text: currentGoal.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('设置每日饮水目标'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            suffixText: 'ml',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                ref.read(settingsProvider.notifier).setWaterGoal(value);
                Navigator.pop(ctx);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清除所有数据'),
        content: const Text('此操作不可撤销，确定要清除所有记录数据吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final db = ref.read(databaseServiceProvider);
              await db.clearAllData();
              ref.read(todayProvider.notifier).refresh();
              ref.read(historyProvider.notifier).refresh();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('所有数据已清除')),
                );
              }
            },
            child: const Text('确定清除'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
}
