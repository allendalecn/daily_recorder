import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/category_section.dart';
import '../add_entry/add_entry_screen.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(todayProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('今天'),
        centerTitle: true,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(todayProvider.notifier).refresh(),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(DateTime.now()),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        _buildCalorieSummary(context, state),
                      ],
                    ),
                  ),
                  for (final category in RecordCategory.values)
                    CategorySection(
                      category: category,
                      entries: state.entries[category] ?? [],
                      onAdd: () => _showEntrySheet(context, ref, category),
                      onDelete: (id) => ref
                          .read(todayProvider.notifier)
                          .deleteEntry(category, id),
                      onEdit: (entry) =>
                          _showEntrySheet(context, ref, category, entry),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  void _showEntrySheet(
    BuildContext context,
    WidgetRef ref,
    RecordCategory category, [
    dynamic existingRecord,
  ]) {
    final dailyRecord = ref.read(todayProvider).dailyRecord;
    if (dailyRecord == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddEntryScreen(
        category: category,
        dailyRecordId: dailyRecord.id!,
        existingRecord: existingRecord,
        onSaved: () => ref.read(todayProvider.notifier).refresh(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return '${date.year}年${date.month}月${date.day}日 '
        '星期${weekdays[date.weekday - 1]}';
  }

  Widget _buildCalorieSummary(BuildContext context, TodayState state) {
    final meals = state.entries[RecordCategory.meals] ?? [];
    final total = meals.fold<int>(
      0,
      (sum, r) => sum + ((r as MealRecord).calories ?? 0),
    );
    if (total == 0) return const SizedBox.shrink();
    return Text(
      '今日摄入: $total 千卡',
      style: TextStyle(
        fontSize: 14,
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
