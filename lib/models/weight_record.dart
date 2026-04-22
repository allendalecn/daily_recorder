class WeightRecord {
  final int? id;
  final int dailyRecordId;
  final DateTime timestamp;
  final double weight;
  final String unit;
  final String notes;

  WeightRecord({
    this.id,
    required this.dailyRecordId,
    DateTime? timestamp,
    required this.weight,
    this.unit = 'kg',
    this.notes = '',
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'daily_record_id': dailyRecordId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'weight': weight,
      'unit': unit,
      'notes': notes,
    };
  }

  factory WeightRecord.fromMap(Map<String, dynamic> map) {
    return WeightRecord(
      id: map['id'] as int,
      dailyRecordId: map['daily_record_id'] as int,
      timestamp:
          DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      weight: (map['weight'] as num).toDouble(),
      unit: map['unit'] as String? ?? 'kg',
      notes: map['notes'] as String? ?? '',
    );
  }
}
