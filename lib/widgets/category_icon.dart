import 'package:flutter/material.dart';
import '../models/record_category.dart';

class CategoryIcon extends StatelessWidget {
  final RecordCategory category;
  final double size;

  const CategoryIcon({
    super.key,
    required this.category,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Icon(
        category.icon,
        size: size * 0.55,
        color: category.color,
      ),
    );
  }
}
