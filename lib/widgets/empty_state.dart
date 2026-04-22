import 'package:flutter/material.dart';
import '../models/record_category.dart';

class EmptyStateWidget extends StatelessWidget {
  final RecordCategory category;

  const EmptyStateWidget({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 32,
              color: category.color.withOpacity(0.4),
            ),
            const SizedBox(height: 8),
            Text(
              '暂无${category.displayName}记录',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
