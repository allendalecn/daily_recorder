class MoodRecord {
  final int? id;
  final int dailyRecordId;
  final DateTime timestamp;
  final int moodLevel;
  final List<String> emotions;
  final String notes;

  MoodRecord({
    this.id,
    required this.dailyRecordId,
    DateTime? timestamp,
    this.moodLevel = 3,
    this.emotions = const [],
    this.notes = '',
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'daily_record_id': dailyRecordId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'mood_level': moodLevel,
      'emotions': emotions.join(','),
      'notes': notes,
    };
  }

  factory MoodRecord.fromMap(Map<String, dynamic> map) {
    final emotionsStr = map['emotions'] as String? ?? '';
    return MoodRecord(
      id: map['id'] as int,
      dailyRecordId: map['daily_record_id'] as int,
      timestamp:
          DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      moodLevel: map['mood_level'] as int,
      emotions:
          emotionsStr.isEmpty ? [] : emotionsStr.split(','),
      notes: map['notes'] as String? ?? '',
    );
  }
}
