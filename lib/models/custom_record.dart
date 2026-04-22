class CustomRecord {
  final int? id;
  final int dailyRecordId;
  final DateTime timestamp;
  final String name;
  final String value;
  final String unit;
  final String notes;

  CustomRecord({
    this.id,
    required this.dailyRecordId,
    DateTime? timestamp,
    required this.name,
    required this.value,
    this.unit = '',
    this.notes = '',
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'daily_record_id': dailyRecordId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'name': name,
      'value': value,
      'unit': unit,
      'notes': notes,
    };
  }

  factory CustomRecord.fromMap(Map<String, dynamic> map) {
    return CustomRecord(
      id: map['id'] as int,
      dailyRecordId: map['daily_record_id'] as int,
      timestamp:
          DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      name: map['name'] as String? ?? '',
      value: map['value'] as String? ?? '',
      unit: map['unit'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
    );
  }
}
