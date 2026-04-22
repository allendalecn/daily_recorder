import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/date_extensions.dart';

class DaySummaryCard extends StatelessWidget {
  final DailyRecord record;
  final VoidCallback? onTap;

  const DaySummaryCard({
    super.key,
    required this.record,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        title: Text(
          record.date.shortFormatted,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            for (final category in RecordCategory.values)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  category.icon,
                  size: 14,
                  color: category.color.withOpacity(0.7),
                ),
              ),
          ],
        ),
        trailing: Text(
          '${record.totalEntryCount} 条',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
