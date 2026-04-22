class SleepRecord {
  final int? id;
  final int dailyRecordId;
  final DateTime timestamp;
  final DateTime bedtime;
  final DateTime wakeTime;
  final int qualityRating;
  final String notes;

  SleepRecord({
    this.id,
    required this.dailyRecordId,
    DateTime? timestamp,
    required this.bedtime,
    required this.wakeTime,
    this.qualityRating = 3,
    this.notes = '',
  }) : timestamp = timestamp ?? DateTime.now();

  double get durationHours =>
      wakeTime.difference(bedtime).inMinutes / 60.0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'daily_record_id': dailyRecordId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'bedtime': bedtime.millisecondsSinceEpoch,
      'wake_time': wakeTime.millisecondsSinceEpoch,
      'quality_rating': qualityRating,
      'notes': notes,
    };
  }

  factory SleepRecord.fromMap(Map<String, dynamic> map) {
    return SleepRecord(
      id: map['id'] as int,
      dailyRecordId: map['daily_record_id'] as int,
      timestamp:
          DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      bedtime:
          DateTime.fromMillisecondsSinceEpoch(map['bedtime'] as int),
      wakeTime:
          DateTime.fromMillisecondsSinceEpoch(map['wake_time'] as int),
      qualityRating: map['quality_rating'] as int,
      notes: map['notes'] as String? ?? '',
    );
  }
}
