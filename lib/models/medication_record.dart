class MedicationRecord {
  final int? id;
  final int dailyRecordId;
  final DateTime timestamp;
  final String medicationName;
  final String dosage;
  final bool taken;
  final String notes;

  MedicationRecord({
    this.id,
    required this.dailyRecordId,
    DateTime? timestamp,
    this.medicationName = '',
    this.dosage = '',
    this.taken = true,
    this.notes = '',
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'daily_record_id': dailyRecordId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'medication_name': medicationName,
      'dosage': dosage,
      'taken': taken ? 1 : 0,
      'notes': notes,
    };
  }

  factory MedicationRecord.fromMap(Map<String, dynamic> map) {
    return MedicationRecord(
      id: map['id'] as int,
      dailyRecordId: map['daily_record_id'] as int,
      timestamp:
          DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      medicationName: map['medication_name'] as String? ?? '',
      dosage: map['dosage'] as String? ?? '',
      taken: (map['taken'] as int) == 1,
      notes: map['notes'] as String? ?? '',
    );
  }
}
