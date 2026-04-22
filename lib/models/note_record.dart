class NoteRecord {
  final int? id;
  final int dailyRecordId;
  final DateTime timestamp;
  final String title;
  final String content;
  final List<String> tags;

  NoteRecord({
    this.id,
    required this.dailyRecordId,
    DateTime? timestamp,
    this.title = '',
    this.content = '',
    this.tags = const [],
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'daily_record_id': dailyRecordId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'title': title,
      'content': content,
      'tags': tags.join(','),
    };
  }

  factory NoteRecord.fromMap(Map<String, dynamic> map) {
    final tagsStr = map['tags'] as String? ?? '';
    return NoteRecord(
      id: map['id'] as int,
      dailyRecordId: map['daily_record_id'] as int,
      timestamp:
          DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      tags: tagsStr.isEmpty ? [] : tagsStr.split(','),
    );
  }
}
