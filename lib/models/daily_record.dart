class DailyRecord {
  final int? id;
  final DateTime date;
  int totalEntryCount;

  DailyRecord({
    this.id,
    required this.date,
    this.totalEntryCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': DateTime(date.year, date.month, date.day)
          .millisecondsSinceEpoch,
    };
  }

  factory DailyRecord.fromMap(Map<String, dynamic> map) {
    return DailyRecord(
      id: map['id'] as int,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      totalEntryCount: map['total_count'] as int? ?? 0,
    );
  }

  DailyRecord copyWith({int? id, DateTime? date}) {
    return DailyRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      totalEntryCount: totalEntryCount,
    );
  }
}
