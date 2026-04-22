class WaterIntakeRecord {
  final int? id;
  final int dailyRecordId;
  final DateTime timestamp;
  final int amountML;
  final String notes;

  WaterIntakeRecord({
    this.id,
    required this.dailyRecordId,
    DateTime? timestamp,
    this.amountML = 250,
    this.notes = '',
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'daily_record_id': dailyRecordId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'amount_ml': amountML,
      'notes': notes,
    };
  }

  factory WaterIntakeRecord.fromMap(Map<String, dynamic> map) {
    return WaterIntakeRecord(
      id: map['id'] as int,
      dailyRecordId: map['daily_record_id'] as int,
      timestamp:
          DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      amountML: map['amount_ml'] as int,
      notes: map['notes'] as String? ?? '',
    );
  }
}
