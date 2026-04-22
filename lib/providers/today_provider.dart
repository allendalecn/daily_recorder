import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'database_provider.dart';

class TodayState {
  final DailyRecord? dailyRecord;
  final Map<RecordCategory, List<dynamic>> entries;
  final Map<RecordCategory, int> counts;
  final bool isLoading;

  const TodayState({
    this.dailyRecord,
    this.entries = const {},
    this.counts = const {},
    this.isLoading = true,
  });

  TodayState copyWith({
    DailyRecord? dailyRecord,
    Map<RecordCategory, List<dynamic>>? entries,
    Map<RecordCategory, int>? counts,
    bool? isLoading,
  }) {
    return TodayState(
      dailyRecord: dailyRecord ?? this.dailyRecord,
      entries: entries ?? this.entries,
      counts: counts ?? this.counts,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TodayNotifier extends StateNotifier<TodayState> {
  final Ref ref;

  TodayNotifier(this.ref) : super(const TodayState()) {
    loadToday();
  }

  Future<void> loadToday() async {
    try {
      state = state.copyWith(isLoading: true);
      final db = ref.read(databaseServiceProvider);
      final record = await db.getOrCreateDailyRecord(DateTime.now());
      await _loadEntries(record);
    } catch (e) {
      print('loadToday error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _loadEntries(DailyRecord record) async {
    final db = ref.read(databaseServiceProvider);
    final id = record.id!;

    final entries = <RecordCategory, List<dynamic>>{
      RecordCategory.sleep: await db.getSleepRecords(id),
      RecordCategory.meals: await db.getMealRecords(id),
      RecordCategory.exercise: await db.getExerciseRecords(id),
      RecordCategory.mood: await db.getMoodRecords(id),
      RecordCategory.waterIntake: await db.getWaterIntakeRecords(id),
      RecordCategory.medication: await db.getMedicationRecords(id),
      RecordCategory.notes: await db.getNoteRecords(id),
      RecordCategory.bloodPressure: await db.getBloodPressureRecords(id),
      RecordCategory.weight: await db.getWeightRecords(id),
      RecordCategory.custom: await db.getCustomRecords(id),
    };

    final counts = <RecordCategory, int>{};
    for (final entry in entries.entries) {
      counts[entry.key] = entry.value.length;
    }

    state = TodayState(
      dailyRecord: record,
      entries: entries,
      counts: counts,
      isLoading: false,
    );
  }

  Future<void> deleteEntry(RecordCategory category, int entryId) async {
    final db = ref.read(databaseServiceProvider);
    await db.deleteRecord(category, entryId);
    if (state.dailyRecord != null) {
      await _loadEntries(state.dailyRecord!);
    }
  }

  Future<void> refresh() async {
    await loadToday();
  }
}

final todayProvider =
    StateNotifierProvider<TodayNotifier, TodayState>((ref) {
  return TodayNotifier(ref);
});
