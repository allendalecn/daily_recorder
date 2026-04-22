class ExerciseRecord {
  final int? id;
  final int dailyRecordId;
  final DateTime timestamp;
  final String activityType;
  final int durationMinutes;
  final String intensity;
  final int? caloriesBurned;
  final String notes;

  ExerciseRecord({
    this.id,
    required this.dailyRecordId,
    DateTime? timestamp,
    this.activityType = '',
    this.durationMinutes = 30,
    this.intensity = '中',
    this.caloriesBurned,
    this.notes = '',
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'daily_record_id': dailyRecordId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'activity_type': activityType,
      'duration_minutes': durationMinutes,
      'intensity': intensity,
      'calories_burned': caloriesBurned,
      'notes': notes,
    };
  }

  factory ExerciseRecord.fromMap(Map<String, dynamic> map) {
    return ExerciseRecord(
      id: map['id'] as int,
      dailyRecordId: map['daily_record_id'] as int,
      timestamp:
          DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      activityType: map['activity_type'] as String? ?? '',
      durationMinutes: map['duration_minutes'] as int,
      intensity: map['intensity'] as String? ?? '中',
      caloriesBurned: map['calories_burned'] as int?,
      notes: map['notes'] as String? ?? '',
    );
  }
}
