class MealRecord {
  final int? id;
  final int dailyRecordId;
  final DateTime timestamp;
  final String mealType;
  final String content;
  final int? calories;
  final String notes;

  MealRecord({
    this.id,
    required this.dailyRecordId,
    DateTime? timestamp,
    this.mealType = '早餐',
    this.content = '',
    this.calories,
    this.notes = '',
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'daily_record_id': dailyRecordId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'meal_type': mealType,
      'content': content,
      'calories': calories,
      'notes': notes,
    };
  }

  factory MealRecord.fromMap(Map<String, dynamic> map) {
    return MealRecord(
      id: map['id'] as int,
      dailyRecordId: map['daily_record_id'] as int,
      timestamp:
          DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      mealType: map['meal_type'] as String,
      content: map['content'] as String? ?? '',
      calories: map['calories'] as int?,
      notes: map['notes'] as String? ?? '',
    );
  }
}
