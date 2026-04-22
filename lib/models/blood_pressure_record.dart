class BloodPressureRecord {
  final int? id;
  final int dailyRecordId;
  final DateTime timestamp;
  final int systolic;
  final int diastolic;
  final int? heartRate;
  final String notes;

  BloodPressureRecord({
    this.id,
    required this.dailyRecordId,
    DateTime? timestamp,
    required this.systolic,
    required this.diastolic,
    this.heartRate,
    this.notes = '',
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'daily_record_id': dailyRecordId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'systolic': systolic,
      'diastolic': diastolic,
      'heart_rate': heartRate,
      'notes': notes,
    };
  }

  factory BloodPressureRecord.fromMap(Map<String, dynamic> map) {
    return BloodPressureRecord(
      id: map['id'] as int,
      dailyRecordId: map['daily_record_id'] as int,
      timestamp:
          DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      systolic: map['systolic'] as int,
      diastolic: map['diastolic'] as int,
      heartRate: map['heart_rate'] as int?,
      notes: map['notes'] as String? ?? '',
    );
  }
}
