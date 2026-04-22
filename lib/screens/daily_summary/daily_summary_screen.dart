import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/category_section.dart';
import '../add_entry/add_entry_screen.dart';

class DailySummaryScreen extends ConsumerStatefulWidget {
  final DailyRecord dailyRecord;

  const DailySummaryScreen({super.key, required this.dailyRecord});

  @override
  ConsumerState<DailySummaryScreen> createState() =>
      _DailySummaryScreenState();
}

class _DailySummaryScreenState extends ConsumerState<DailySummaryScreen> {
  Map<RecordCategory, List<dynamic>> _entries = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    final db = ref.read(databaseServiceProvider);
    final id = widget.dailyRecord.id!;

    _entries = {
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
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dailyRecord.date.toString().substring(0, 10)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildSummaryHeader(context),
                for (final category in RecordCategory.values)
                  CategorySection(
                    category: category,
                    entries: _entries[category] ?? [],
                    onAdd: () => _showEntrySheet(category),
                    onDelete: (id) => _deleteEntry(category, id),
                    onEdit: (entry) => _showEntrySheet(category, entry),
                  ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildSummaryHeader(BuildContext context) {
    final waterRecords =
        (_entries[RecordCategory.waterIntake] as List<WaterIntakeRecord>?) ??
            [];
    final totalWater = waterRecords.fold<int>(0, (sum, r) => sum + r.amountML);

    final exerciseRecords =
        (_entries[RecordCategory.exercise] as List<ExerciseRecord>?) ?? [];
    final totalExercise =
        exerciseRecords.fold<int>(0, (sum, r) => sum + r.durationMinutes);

    final sleepRecords =
        (_entries[RecordCategory.sleep] as List<SleepRecord>?) ?? [];
    final totalSleep =
        sleepRecords.fold<double>(0, (sum, r) => sum + r.durationHours);

    final mealRecords =
        (_entries[RecordCategory.meals] as List<MealRecord>?) ?? [];
    final totalCalories =
        mealRecords.fold<int>(0, (sum, r) => sum + (r.calories ?? 0));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat('睡眠', '${totalSleep.toStringAsFixed(1)}h'),
            _buildStat('饮水', '${totalWater}ml'),
            _buildStat('运动', '${totalExercise}min'),
            _buildStat('饮食', '${totalCalories}千卡'),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }

  void _showEntrySheet(RecordCategory category, [dynamic existingRecord]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddEntryScreen(
        category: category,
        dailyRecordId: widget.dailyRecord.id!,
        existingRecord: existingRecord,
        onSaved: _loadEntries,
      ),
    );
  }

  Future<void> _deleteEntry(RecordCategory category, int id) async {
    final db = ref.read(databaseServiceProvider);
    await db.deleteRecord(category, id);
    await _loadEntries();
  }
}
