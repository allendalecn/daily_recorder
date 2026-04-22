import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/models.dart';
import 'category_icon.dart';
import 'empty_state.dart';

class CategorySection extends StatelessWidget {
  final RecordCategory category;
  final List<dynamic> entries;
  final VoidCallback onAdd;
  final void Function(int id)? onDelete;
  final void Function(dynamic entry)? onEdit;

  const CategorySection({
    super.key,
    required this.category,
    required this.entries,
    required this.onAdd,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CategoryIcon(category: category),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    category.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (entries.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '${entries.length}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: category.color,
                  onPressed: onAdd,
                ),
              ],
            ),
            if (entries.isEmpty)
              EmptyStateWidget(category: category)
            else
              ...entries.map((entry) => _buildEntryRow(context, entry)),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryRow(BuildContext context, dynamic entry) {
    final (String title, String subtitle, int id) = _extractInfo(entry);

    return Dismissible(
      key: ValueKey('${category.name}_$id'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete?.call(id),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        subtitle: subtitle.isNotEmpty
            ? Text(subtitle, style: const TextStyle(fontSize: 12))
            : null,
        onTap: () => onEdit?.call(entry),
      ),
    );
  }

  (String, String, int) _extractInfo(dynamic entry) {
    switch (category) {
      case RecordCategory.sleep:
        final e = entry as SleepRecord;
        return (
          '${e.durationHours.toStringAsFixed(1)} 小时',
          '质量: ${e.qualityRating}/5',
          e.id!,
        );
      case RecordCategory.meals:
        final e = entry as MealRecord;
        String title;
        try {
          final decoded = jsonDecode(e.content);
          if (decoded is List && decoded.isNotEmpty) {
            final names = decoded
                .map((item) => item['name'] as String? ?? '')
                .where((n) => n.isNotEmpty)
                .join(', ');
            title = '${e.mealType}: $names';
          } else {
            title = '${e.mealType}: ${e.content}';
          }
        } catch (_) {
          title = '${e.mealType}: ${e.content}';
        }
        return (
          title,
          e.calories != null ? '${e.calories} 千卡' : '',
          e.id!,
        );
      case RecordCategory.exercise:
        final e = entry as ExerciseRecord;
        return (
          '${e.activityType} ${e.durationMinutes}分钟',
          '强度: ${e.intensity}',
          e.id!,
        );
      case RecordCategory.mood:
        final e = entry as MoodRecord;
        return (
          '心情 ${e.moodLevel}/5',
          e.emotions.join(', '),
          e.id!,
        );
      case RecordCategory.waterIntake:
        final e = entry as WaterIntakeRecord;
        return ('${e.amountML} ml', '', e.id!);
      case RecordCategory.medication:
        final e = entry as MedicationRecord;
        return (
          '${e.medicationName} ${e.dosage}',
          e.taken ? '已服用' : '未服用',
          e.id!,
        );
      case RecordCategory.notes:
        final e = entry as NoteRecord;
        return (e.title, e.content, e.id!);
      case RecordCategory.bloodPressure:
        final e = entry as BloodPressureRecord;
        return (
          '${e.systolic}/${e.diastolic} mmHg',
          e.heartRate != null ? '心率 ${e.heartRate} 次/分' : '',
          e.id!,
        );
      case RecordCategory.weight:
        final e = entry as WeightRecord;
        return (
          '${e.weight.toStringAsFixed(1)} ${e.unit}',
          '',
          e.id!,
        );
      case RecordCategory.custom:
        final e = entry as CustomRecord;
        return (
          '${e.name}: ${e.value} ${e.unit}',
          '',
          e.id!,
        );
    }
  }
}
