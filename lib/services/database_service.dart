import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._();
  static Database? _database;

  DatabaseService._();
  factory DatabaseService() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'daily_recorder.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE daily_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date INTEGER NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE sleep_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        daily_record_id INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        bedtime INTEGER NOT NULL,
        wake_time INTEGER NOT NULL,
        quality_rating INTEGER NOT NULL DEFAULT 3,
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (daily_record_id) REFERENCES daily_records(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE meal_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        daily_record_id INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        meal_type TEXT NOT NULL DEFAULT '早餐',
        content TEXT NOT NULL DEFAULT '',
        calories INTEGER,
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (daily_record_id) REFERENCES daily_records(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE exercise_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        daily_record_id INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        activity_type TEXT NOT NULL DEFAULT '',
        duration_minutes INTEGER NOT NULL DEFAULT 30,
        intensity TEXT NOT NULL DEFAULT '中',
        calories_burned INTEGER,
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (daily_record_id) REFERENCES daily_records(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE mood_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        daily_record_id INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        mood_level INTEGER NOT NULL DEFAULT 3,
        emotions TEXT NOT NULL DEFAULT '',
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (daily_record_id) REFERENCES daily_records(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE water_intake_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        daily_record_id INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        amount_ml INTEGER NOT NULL DEFAULT 250,
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (daily_record_id) REFERENCES daily_records(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE medication_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        daily_record_id INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        medication_name TEXT NOT NULL DEFAULT '',
        dosage TEXT NOT NULL DEFAULT '',
        taken INTEGER NOT NULL DEFAULT 1,
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (daily_record_id) REFERENCES daily_records(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE note_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        daily_record_id INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        title TEXT NOT NULL DEFAULT '',
        content TEXT NOT NULL DEFAULT '',
        tags TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (daily_record_id) REFERENCES daily_records(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE blood_pressure_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        daily_record_id INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        systolic INTEGER NOT NULL,
        diastolic INTEGER NOT NULL,
        heart_rate INTEGER,
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (daily_record_id) REFERENCES daily_records(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE weight_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        daily_record_id INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        weight REAL NOT NULL,
        unit TEXT NOT NULL DEFAULT 'kg',
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (daily_record_id) REFERENCES daily_records(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE custom_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        daily_record_id INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        name TEXT NOT NULL DEFAULT '',
        value TEXT NOT NULL DEFAULT '',
        unit TEXT NOT NULL DEFAULT '',
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (daily_record_id) REFERENCES daily_records(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE blood_pressure_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          daily_record_id INTEGER NOT NULL,
          timestamp INTEGER NOT NULL,
          systolic INTEGER NOT NULL,
          diastolic INTEGER NOT NULL,
          heart_rate INTEGER,
          notes TEXT NOT NULL DEFAULT '',
          FOREIGN KEY (daily_record_id) REFERENCES daily_records(id) ON DELETE CASCADE
        )
      ''');
      await db.execute('''
        CREATE TABLE weight_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          daily_record_id INTEGER NOT NULL,
          timestamp INTEGER NOT NULL,
          weight REAL NOT NULL,
          unit TEXT NOT NULL DEFAULT 'kg',
          notes TEXT NOT NULL DEFAULT '',
          FOREIGN KEY (daily_record_id) REFERENCES daily_records(id) ON DELETE CASCADE
        )
      ''');
      await db.execute('''
        CREATE TABLE custom_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          daily_record_id INTEGER NOT NULL,
          timestamp INTEGER NOT NULL,
          name TEXT NOT NULL DEFAULT '',
          value TEXT NOT NULL DEFAULT '',
          unit TEXT NOT NULL DEFAULT '',
          notes TEXT NOT NULL DEFAULT '',
          FOREIGN KEY (daily_record_id) REFERENCES daily_records(id) ON DELETE CASCADE
        )
      ''');
    }
  }

  // --- DailyRecord ---

  Future<DailyRecord> getOrCreateDailyRecord(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final dateMs = startOfDay.millisecondsSinceEpoch;

    final results = await db.query(
      'daily_records',
      where: 'date = ?',
      whereArgs: [dateMs],
    );

    if (results.isNotEmpty) {
      return DailyRecord.fromMap(results.first);
    }

    final id = await db.insert('daily_records', {'date': dateMs});
    return DailyRecord(id: id, date: startOfDay);
  }

  Future<List<DailyRecord>> getAllDailyRecords() async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT dr.*,
        (SELECT COUNT(*) FROM sleep_records WHERE daily_record_id = dr.id) +
        (SELECT COUNT(*) FROM meal_records WHERE daily_record_id = dr.id) +
        (SELECT COUNT(*) FROM exercise_records WHERE daily_record_id = dr.id) +
        (SELECT COUNT(*) FROM mood_records WHERE daily_record_id = dr.id) +
        (SELECT COUNT(*) FROM water_intake_records WHERE daily_record_id = dr.id) +
        (SELECT COUNT(*) FROM medication_records WHERE daily_record_id = dr.id) +
        (SELECT COUNT(*) FROM note_records WHERE daily_record_id = dr.id) +
        (SELECT COUNT(*) FROM blood_pressure_records WHERE daily_record_id = dr.id) +
        (SELECT COUNT(*) FROM weight_records WHERE daily_record_id = dr.id) +
        (SELECT COUNT(*) FROM custom_records WHERE daily_record_id = dr.id)
        AS total_count
      FROM daily_records dr
      ORDER BY dr.date DESC
    ''');
    return results.map(DailyRecord.fromMap).toList();
  }

  Future<void> deleteDailyRecord(int id) async {
    final db = await database;
    await db.delete('daily_records', where: 'id = ?', whereArgs: [id]);
  }

  // --- Sleep ---

  Future<List<SleepRecord>> getSleepRecords(int dailyRecordId) async {
    final db = await database;
    final results = await db.query(
      'sleep_records',
      where: 'daily_record_id = ?',
      whereArgs: [dailyRecordId],
      orderBy: 'timestamp DESC',
    );
    return results.map(SleepRecord.fromMap).toList();
  }

  Future<int> insertSleepRecord(SleepRecord record) async {
    final db = await database;
    return db.insert('sleep_records', record.toMap()..remove('id'));
  }

  Future<void> updateSleepRecord(SleepRecord record) async {
    final db = await database;
    await db.update(
      'sleep_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteSleepRecord(int id) async {
    final db = await database;
    await db.delete('sleep_records', where: 'id = ?', whereArgs: [id]);
  }

  // --- Meal ---

  Future<List<MealRecord>> getMealRecords(int dailyRecordId) async {
    final db = await database;
    final results = await db.query(
      'meal_records',
      where: 'daily_record_id = ?',
      whereArgs: [dailyRecordId],
      orderBy: 'timestamp DESC',
    );
    return results.map(MealRecord.fromMap).toList();
  }

  Future<int> insertMealRecord(MealRecord record) async {
    final db = await database;
    return db.insert('meal_records', record.toMap()..remove('id'));
  }

  Future<void> updateMealRecord(MealRecord record) async {
    final db = await database;
    await db.update(
      'meal_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteMealRecord(int id) async {
    final db = await database;
    await db.delete('meal_records', where: 'id = ?', whereArgs: [id]);
  }

  // --- Exercise ---

  Future<List<ExerciseRecord>> getExerciseRecords(int dailyRecordId) async {
    final db = await database;
    final results = await db.query(
      'exercise_records',
      where: 'daily_record_id = ?',
      whereArgs: [dailyRecordId],
      orderBy: 'timestamp DESC',
    );
    return results.map(ExerciseRecord.fromMap).toList();
  }

  Future<int> insertExerciseRecord(ExerciseRecord record) async {
    final db = await database;
    return db.insert('exercise_records', record.toMap()..remove('id'));
  }

  Future<void> updateExerciseRecord(ExerciseRecord record) async {
    final db = await database;
    await db.update(
      'exercise_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteExerciseRecord(int id) async {
    final db = await database;
    await db.delete('exercise_records', where: 'id = ?', whereArgs: [id]);
  }

  // --- Mood ---

  Future<List<MoodRecord>> getMoodRecords(int dailyRecordId) async {
    final db = await database;
    final results = await db.query(
      'mood_records',
      where: 'daily_record_id = ?',
      whereArgs: [dailyRecordId],
      orderBy: 'timestamp DESC',
    );
    return results.map(MoodRecord.fromMap).toList();
  }

  Future<int> insertMoodRecord(MoodRecord record) async {
    final db = await database;
    return db.insert('mood_records', record.toMap()..remove('id'));
  }

  Future<void> updateMoodRecord(MoodRecord record) async {
    final db = await database;
    await db.update(
      'mood_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteMoodRecord(int id) async {
    final db = await database;
    await db.delete('mood_records', where: 'id = ?', whereArgs: [id]);
  }

  // --- Water Intake ---

  Future<List<WaterIntakeRecord>> getWaterIntakeRecords(
      int dailyRecordId) async {
    final db = await database;
    final results = await db.query(
      'water_intake_records',
      where: 'daily_record_id = ?',
      whereArgs: [dailyRecordId],
      orderBy: 'timestamp DESC',
    );
    return results.map(WaterIntakeRecord.fromMap).toList();
  }

  Future<int> insertWaterIntakeRecord(WaterIntakeRecord record) async {
    final db = await database;
    return db.insert('water_intake_records', record.toMap()..remove('id'));
  }

  Future<void> updateWaterIntakeRecord(WaterIntakeRecord record) async {
    final db = await database;
    await db.update(
      'water_intake_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteWaterIntakeRecord(int id) async {
    final db = await database;
    await db.delete('water_intake_records', where: 'id = ?', whereArgs: [id]);
  }

  // --- Medication ---

  Future<List<MedicationRecord>> getMedicationRecords(
      int dailyRecordId) async {
    final db = await database;
    final results = await db.query(
      'medication_records',
      where: 'daily_record_id = ?',
      whereArgs: [dailyRecordId],
      orderBy: 'timestamp DESC',
    );
    return results.map(MedicationRecord.fromMap).toList();
  }

  Future<int> insertMedicationRecord(MedicationRecord record) async {
    final db = await database;
    return db.insert('medication_records', record.toMap()..remove('id'));
  }

  Future<void> updateMedicationRecord(MedicationRecord record) async {
    final db = await database;
    await db.update(
      'medication_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteMedicationRecord(int id) async {
    final db = await database;
    await db.delete('medication_records', where: 'id = ?', whereArgs: [id]);
  }

  // --- Notes ---

  Future<List<NoteRecord>> getNoteRecords(int dailyRecordId) async {
    final db = await database;
    final results = await db.query(
      'note_records',
      where: 'daily_record_id = ?',
      whereArgs: [dailyRecordId],
      orderBy: 'timestamp DESC',
    );
    return results.map(NoteRecord.fromMap).toList();
  }

  Future<int> insertNoteRecord(NoteRecord record) async {
    final db = await database;
    return db.insert('note_records', record.toMap()..remove('id'));
  }

  Future<void> updateNoteRecord(NoteRecord record) async {
    final db = await database;
    await db.update(
      'note_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteNoteRecord(int id) async {
    final db = await database;
    await db.delete('note_records', where: 'id = ?', whereArgs: [id]);
  }

  // --- Generic update/delete by category ---

  Future<void> updateRecord(RecordCategory category, dynamic record) async {
    switch (category) {
      case RecordCategory.sleep:
        await updateSleepRecord(record as SleepRecord);
      case RecordCategory.meals:
        await updateMealRecord(record as MealRecord);
      case RecordCategory.exercise:
        await updateExerciseRecord(record as ExerciseRecord);
      case RecordCategory.mood:
        await updateMoodRecord(record as MoodRecord);
      case RecordCategory.waterIntake:
        await updateWaterIntakeRecord(record as WaterIntakeRecord);
      case RecordCategory.medication:
        await updateMedicationRecord(record as MedicationRecord);
      case RecordCategory.notes:
        await updateNoteRecord(record as NoteRecord);
      case RecordCategory.bloodPressure:
        await updateBloodPressureRecord(record as BloodPressureRecord);
      case RecordCategory.weight:
        await updateWeightRecord(record as WeightRecord);
      case RecordCategory.custom:
        await updateCustomRecord(record as CustomRecord);
    }
  }

  Future<void> deleteRecord(RecordCategory category, int id) async {
    switch (category) {
      case RecordCategory.sleep:
        await deleteSleepRecord(id);
      case RecordCategory.meals:
        await deleteMealRecord(id);
      case RecordCategory.exercise:
        await deleteExerciseRecord(id);
      case RecordCategory.mood:
        await deleteMoodRecord(id);
      case RecordCategory.waterIntake:
        await deleteWaterIntakeRecord(id);
      case RecordCategory.medication:
        await deleteMedicationRecord(id);
      case RecordCategory.notes:
        await deleteNoteRecord(id);
      case RecordCategory.bloodPressure:
        await deleteBloodPressureRecord(id);
      case RecordCategory.weight:
        await deleteWeightRecord(id);
      case RecordCategory.custom:
        await deleteCustomRecord(id);
    }
  }

  // --- Clear all data ---

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('sleep_records');
    await db.delete('meal_records');
    await db.delete('exercise_records');
    await db.delete('mood_records');
    await db.delete('water_intake_records');
    await db.delete('medication_records');
    await db.delete('note_records');
    await db.delete('blood_pressure_records');
    await db.delete('weight_records');
    await db.delete('custom_records');
    await db.delete('daily_records');
  }

  // --- Entry counts for a day ---

  Future<Map<RecordCategory, int>> getEntryCounts(int dailyRecordId) async {
    final db = await database;
    final tables = {
      RecordCategory.sleep: 'sleep_records',
      RecordCategory.meals: 'meal_records',
      RecordCategory.exercise: 'exercise_records',
      RecordCategory.mood: 'mood_records',
      RecordCategory.waterIntake: 'water_intake_records',
      RecordCategory.medication: 'medication_records',
      RecordCategory.notes: 'note_records',
      RecordCategory.bloodPressure: 'blood_pressure_records',
      RecordCategory.weight: 'weight_records',
      RecordCategory.custom: 'custom_records',
    };

    final counts = <RecordCategory, int>{};
    for (final entry in tables.entries) {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as cnt FROM ${entry.value} WHERE daily_record_id = ?',
        [dailyRecordId],
      );
      counts[entry.key] = result.first['cnt'] as int;
    }
    return counts;
  }

  // --- Blood Pressure ---

  Future<List<BloodPressureRecord>> getBloodPressureRecords(int dailyRecordId) async {
    final db = await database;
    final results = await db.query(
      'blood_pressure_records',
      where: 'daily_record_id = ?',
      whereArgs: [dailyRecordId],
      orderBy: 'timestamp DESC',
    );
    return results.map(BloodPressureRecord.fromMap).toList();
  }

  Future<int> insertBloodPressureRecord(BloodPressureRecord record) async {
    final db = await database;
    return db.insert('blood_pressure_records', record.toMap()..remove('id'));
  }

  Future<void> updateBloodPressureRecord(BloodPressureRecord record) async {
    final db = await database;
    await db.update(
      'blood_pressure_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteBloodPressureRecord(int id) async {
    final db = await database;
    await db.delete('blood_pressure_records', where: 'id = ?', whereArgs: [id]);
  }

  // --- Weight ---

  Future<List<WeightRecord>> getWeightRecords(int dailyRecordId) async {
    final db = await database;
    final results = await db.query(
      'weight_records',
      where: 'daily_record_id = ?',
      whereArgs: [dailyRecordId],
      orderBy: 'timestamp DESC',
    );
    return results.map(WeightRecord.fromMap).toList();
  }

  Future<int> insertWeightRecord(WeightRecord record) async {
    final db = await database;
    return db.insert('weight_records', record.toMap()..remove('id'));
  }

  Future<void> updateWeightRecord(WeightRecord record) async {
    final db = await database;
    await db.update(
      'weight_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteWeightRecord(int id) async {
    final db = await database;
    await db.delete('weight_records', where: 'id = ?', whereArgs: [id]);
  }

  // --- Custom ---

  Future<List<CustomRecord>> getCustomRecords(int dailyRecordId) async {
    final db = await database;
    final results = await db.query(
      'custom_records',
      where: 'daily_record_id = ?',
      whereArgs: [dailyRecordId],
      orderBy: 'timestamp DESC',
    );
    return results.map(CustomRecord.fromMap).toList();
  }

  Future<int> insertCustomRecord(CustomRecord record) async {
    final db = await database;
    return db.insert('custom_records', record.toMap()..remove('id'));
  }

  Future<void> updateCustomRecord(CustomRecord record) async {
    final db = await database;
    await db.update(
      'custom_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteCustomRecord(int id) async {
    final db = await database;
    await db.delete('custom_records', where: 'id = ?', whereArgs: [id]);
  }
}
