import 'package:flutter/material.dart';

enum RecordCategory {
  sleep(
    displayName: '睡眠',
    icon: Icons.bed,
    color: Colors.indigo,
  ),
  meals(
    displayName: '饮食',
    icon: Icons.restaurant,
    color: Colors.orange,
  ),
  exercise(
    displayName: '运动',
    icon: Icons.directions_run,
    color: Colors.green,
  ),
  mood(
    displayName: '心情',
    icon: Icons.sentiment_satisfied_alt,
    color: Colors.amber,
  ),
  waterIntake(
    displayName: '饮水',
    icon: Icons.water_drop,
    color: Colors.cyan,
  ),
  medication(
    displayName: '用药',
    icon: Icons.medication,
    color: Colors.red,
  ),
  notes(
    displayName: '笔记',
    icon: Icons.note_alt,
    color: Colors.grey,
  ),
  bloodPressure(
    displayName: '血压',
    icon: Icons.favorite,
    color: Colors.pink,
  ),
  weight(
    displayName: '体重',
    icon: Icons.monitor_weight,
    color: Colors.brown,
  ),
  custom(
    displayName: '自定义',
    icon: Icons.tune,
    color: Colors.teal,
  );

  const RecordCategory({
    required this.displayName,
    required this.icon,
    required this.color,
  });

  final String displayName;
  final IconData icon;
  final Color color;
}
