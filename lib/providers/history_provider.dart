import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'database_provider.dart';

class HistoryState {
  final List<DailyRecord> records;
  final bool isLoading;

  const HistoryState({
    this.records = const [],
    this.isLoading = true,
  });

  HistoryState copyWith({
    List<DailyRecord>? records,
    bool? isLoading,
  }) {
    return HistoryState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  final Ref ref;

  HistoryNotifier(this.ref) : super(const HistoryState()) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true);
    final db = ref.read(databaseServiceProvider);
    final records = await db.getAllDailyRecords();
    state = HistoryState(records: records, isLoading: false);
  }

  Future<void> deleteRecord(int id) async {
    final db = ref.read(databaseServiceProvider);
    await db.deleteDailyRecord(id);
    await loadAll();
  }

  Future<void> refresh() async {
    await loadAll();
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier(ref);
});
