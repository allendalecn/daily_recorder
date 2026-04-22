import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/constants.dart';
import '../../widgets/food_calorie_picker.dart';

class AddEntryScreen extends ConsumerStatefulWidget {
  final RecordCategory category;
  final int dailyRecordId;
  final dynamic existingRecord;
  final VoidCallback? onSaved;

  const AddEntryScreen({
    super.key,
    required this.category,
    required this.dailyRecordId,
    this.existingRecord,
    this.onSaved,
  });

  @override
  ConsumerState<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends ConsumerState<AddEntryScreen> {
  final _notesController = TextEditingController();

  // Sleep
  TimeOfDay _bedtime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  int _sleepQuality = 3;

  // Meal
  String _mealType = AppConstants.mealTypes.first;
  final _mealContentController = TextEditingController();
  final _caloriesController = TextEditingController();
  List<MealFoodItem> _foodItems = [];

  // Exercise
  final _activityController = TextEditingController();
  int _durationMinutes = 30;
  String _intensity = AppConstants.exerciseIntensities[1];

  // Mood
  int _moodLevel = 3;
  final Set<String> _selectedEmotions = {};

  // Water
  int _waterAmount = 250;

  // Medication
  final _medNameController = TextEditingController();
  final _dosageController = TextEditingController();
  bool _taken = true;

  // Note
  final _noteTitleController = TextEditingController();
  final _noteContentController = TextEditingController();

  // Blood Pressure
  int _bpSystolic = 120;
  int _bpDiastolic = 80;
  int _bpHeartRate = 70;

  // Weight
  double _weight = 60.0;
  String _weightUnit = 'kg';

  // Custom
  final _customNameController = TextEditingController();
  final _customValueController = TextEditingController();
  final _customUnitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final record = widget.existingRecord;
    if (record == null) return;

    switch (widget.category) {
      case RecordCategory.sleep:
        final r = record as SleepRecord;
        _bedtime = TimeOfDay(hour: r.bedtime.hour, minute: r.bedtime.minute);
        _wakeTime = TimeOfDay(hour: r.wakeTime.hour, minute: r.wakeTime.minute);
        _sleepQuality = r.qualityRating;
        _notesController.text = r.notes;
      case RecordCategory.meals:
        final r = record as MealRecord;
        _mealType = r.mealType;
        _notesController.text = r.notes;
        if (r.content.isNotEmpty) {
          try {
            final decoded = jsonDecode(r.content);
            if (decoded is List) {
              _foodItems = decoded
                  .map((e) => MealFoodItem.fromJson(e as Map<String, dynamic>))
                  .toList();
            } else {
              _foodItems = _legacyToFoodItems(r.content, r.calories);
            }
          } catch (_) {
            _foodItems = _legacyToFoodItems(r.content, r.calories);
          }
        }
      case RecordCategory.exercise:
        final r = record as ExerciseRecord;
        _activityController.text = r.activityType;
        _durationMinutes = r.durationMinutes;
        _intensity = r.intensity;
        _notesController.text = r.notes;
      case RecordCategory.mood:
        final r = record as MoodRecord;
        _moodLevel = r.moodLevel;
        _selectedEmotions.addAll(r.emotions);
        _notesController.text = r.notes;
      case RecordCategory.waterIntake:
        final r = record as WaterIntakeRecord;
        _waterAmount = r.amountML;
        _notesController.text = r.notes;
      case RecordCategory.medication:
        final r = record as MedicationRecord;
        _medNameController.text = r.medicationName;
        _dosageController.text = r.dosage;
        _taken = r.taken;
        _notesController.text = r.notes;
      case RecordCategory.notes:
        final r = record as NoteRecord;
        _noteTitleController.text = r.title;
        _noteContentController.text = r.content;
      case RecordCategory.bloodPressure:
        final r = record as BloodPressureRecord;
        _bpSystolic = r.systolic;
        _bpDiastolic = r.diastolic;
        _bpHeartRate = r.heartRate ?? 70;
        _notesController.text = r.notes;
      case RecordCategory.weight:
        final r = record as WeightRecord;
        _weight = r.weight;
        _weightUnit = r.unit;
        _notesController.text = r.notes;
      case RecordCategory.custom:
        final r = record as CustomRecord;
        _customNameController.text = r.name;
        _customValueController.text = r.value;
        _customUnitController.text = r.unit;
        _notesController.text = r.notes;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _mealContentController.dispose();
    _caloriesController.dispose();
    _activityController.dispose();
    _medNameController.dispose();
    _dosageController.dispose();
    _noteTitleController.dispose();
    _noteContentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(widget.category.icon, color: widget.category.color),
                const SizedBox(width: 8),
                Text(
                  '${widget.existingRecord == null ? '添加' : '编辑'}${widget.category.displayName}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildForm(),
            const SizedBox(height: 12),
            if (widget.category != RecordCategory.notes)
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: '备注',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _save,
              child: const Text('保存'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    switch (widget.category) {
      case RecordCategory.sleep:
        return _buildSleepForm();
      case RecordCategory.meals:
        return _buildMealForm();
      case RecordCategory.exercise:
        return _buildExerciseForm();
      case RecordCategory.mood:
        return _buildMoodForm();
      case RecordCategory.waterIntake:
        return _buildWaterForm();
      case RecordCategory.medication:
        return _buildMedicationForm();
      case RecordCategory.notes:
        return _buildNoteForm();
      case RecordCategory.bloodPressure:
        return _buildBloodPressureForm();
      case RecordCategory.weight:
        return _buildWeightForm();
      case RecordCategory.custom:
        return _buildCustomForm();
    }
  }

  Widget _buildSleepForm() {
    return Column(
      children: [
        ListTile(
          title: const Text('就寝时间'),
          trailing: Text(_bedtime.format(context)),
          onTap: () async {
            final t = await showTimePicker(
                context: context, initialTime: _bedtime);
            if (t != null) setState(() => _bedtime = t);
          },
        ),
        ListTile(
          title: const Text('起床时间'),
          trailing: Text(_wakeTime.format(context)),
          onTap: () async {
            final t = await showTimePicker(
                context: context, initialTime: _wakeTime);
            if (t != null) setState(() => _wakeTime = t);
          },
        ),
        Row(
          children: [
            const Text('睡眠质量: '),
            Expanded(
              child: Slider(
                value: _sleepQuality.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: '$_sleepQuality',
                onChanged: (v) =>
                    setState(() => _sleepQuality = v.round()),
              ),
            ),
            Text('$_sleepQuality/5'),
          ],
        ),
      ],
    );
  }

  Widget _buildMealForm() {
    final totalCalories = _foodItems.fold<int>(0, (s, e) => s + e.calories);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _mealType,
          decoration: const InputDecoration(
            labelText: '餐次',
            border: OutlineInputBorder(),
          ),
          items: AppConstants.mealTypes
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => setState(() => _mealType = v!),
        ),
        const SizedBox(height: 12),
        if (_foodItems.isNotEmpty) ...[
          ..._foodItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                dense: true,
                title: Text(
                    '${item.name} ${item.amount.toStringAsFixed(0)}${item.unit}'),
                subtitle: Text('${item.calories} 千卡'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => setState(() => _foodItems.removeAt(index)),
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
        ],
        OutlinedButton.icon(
          onPressed: _addFoodItem,
          icon: const Icon(Icons.add),
          label: const Text('添加食物'),
        ),
        const SizedBox(height: 12),
        Text(
          '总热量: $totalCalories 千卡',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Future<void> _addFoodItem() async {
    final result = await showModalBottomSheet<(String, int)?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const FoodCaloriePicker(),
    );
    if (result == null) return;
    if (!mounted) return;

    final amount = await showDialog<double>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController(text: '100');
        return AlertDialog(
          title: const Text('输入数量'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              labelText: '克数',
              suffixText: '克',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, double.tryParse(ctrl.text)),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );

    if (amount == null || amount <= 0) return;

    setState(() {
      final calories = (result.$2 * amount / 100).round();
      _foodItems.add(MealFoodItem(
        name: result.$1,
        amount: amount,
        unit: '克',
        calories: calories,
      ));
    });
  }

  List<MealFoodItem> _legacyToFoodItems(String content, int? calories) {
    if (content.isEmpty) return [];
    return [
      MealFoodItem(
        name: content,
        amount: 1,
        unit: '份',
        calories: calories ?? 0,
      ),
    ];
  }

  Widget _buildExerciseForm() {
    return Column(
      children: [
        TextField(
          controller: _activityController,
          decoration: const InputDecoration(
            labelText: '运动类型',
            hintText: '如: 跑步、游泳、瑜伽',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('时长: '),
            Expanded(
              child: Slider(
                value: _durationMinutes.toDouble(),
                min: 5,
                max: 180,
                divisions: 35,
                label: '$_durationMinutes 分钟',
                onChanged: (v) =>
                    setState(() => _durationMinutes = v.round()),
              ),
            ),
            Text('$_durationMinutes min'),
          ],
        ),
        DropdownButtonFormField<String>(
          value: _intensity,
          decoration: const InputDecoration(
            labelText: '强度',
            border: OutlineInputBorder(),
          ),
          items: AppConstants.exerciseIntensities
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
          onChanged: (v) => setState(() => _intensity = v!),
        ),
      ],
    );
  }

  Widget _buildMoodForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('心情: '),
            Expanded(
              child: Slider(
                value: _moodLevel.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: AppConstants.moodEmojis[_moodLevel - 1],
                onChanged: (v) =>
                    setState(() => _moodLevel = v.round()),
              ),
            ),
            Text(
              AppConstants.moodEmojis[_moodLevel - 1],
              style: const TextStyle(fontSize: 24),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text('情绪标签:'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.commonEmotions.map((emotion) {
            final selected = _selectedEmotions.contains(emotion);
            return FilterChip(
              label: Text(emotion),
              selected: selected,
              onSelected: (v) {
                setState(() {
                  if (v) {
                    _selectedEmotions.add(emotion);
                  } else {
                    _selectedEmotions.remove(emotion);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWaterForm() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_waterAmount',
              style: const TextStyle(
                  fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const Text(' ml', style: TextStyle(fontSize: 20)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: AppConstants.waterPresets.map((amount) {
            return OutlinedButton(
              onPressed: () => setState(() => _waterAmount = amount),
              style: OutlinedButton.styleFrom(
                backgroundColor: _waterAmount == amount
                    ? RecordCategory.waterIntake.color.withOpacity(0.1)
                    : null,
              ),
              child: Text('$amount ml'),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Slider(
          value: _waterAmount.toDouble(),
          min: 50,
          max: 1000,
          divisions: 19,
          label: '$_waterAmount ml',
          onChanged: (v) => setState(() => _waterAmount = v.round()),
        ),
      ],
    );
  }

  Widget _buildMedicationForm() {
    return Column(
      children: [
        TextField(
          controller: _medNameController,
          decoration: const InputDecoration(
            labelText: '药品名称',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _dosageController,
          decoration: const InputDecoration(
            labelText: '剂量',
            hintText: '如: 500mg, 1片',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('已服用'),
          value: _taken,
          onChanged: (v) => setState(() => _taken = v),
        ),
      ],
    );
  }

  Widget _buildNoteForm() {
    return Column(
      children: [
        TextField(
          controller: _noteTitleController,
          decoration: const InputDecoration(
            labelText: '标题',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteContentController,
          decoration: const InputDecoration(
            labelText: '内容',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
        ),
      ],
    );
  }

  Widget _buildBloodPressureForm() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: '收缩压 (高压)',
                  border: const OutlineInputBorder(),
                  suffixText: 'mmHg',
                  helperText: '$_bpSystolic',
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  final val = int.tryParse(v);
                  if (val != null) setState(() => _bpSystolic = val);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: '舒张压 (低压)',
                  border: const OutlineInputBorder(),
                  suffixText: 'mmHg',
                  helperText: '$_bpDiastolic',
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  final val = int.tryParse(v);
                  if (val != null) setState(() => _bpDiastolic = val);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            labelText: '心率',
            border: const OutlineInputBorder(),
            suffixText: '次/分',
            helperText: '$_bpHeartRate',
          ),
          keyboardType: TextInputType.number,
          onChanged: (v) {
            final val = int.tryParse(v);
            if (val != null) setState(() => _bpHeartRate = val);
          },
        ),
      ],
    );
  }

  Widget _buildWeightForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: '体重',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                controller: TextEditingController(text: '$_weight'),
                onChanged: (v) {
                  final val = double.tryParse(v);
                  if (val != null) setState(() => _weight = val);
                },
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: DropdownButtonFormField<String>(
                value: _weightUnit,
                decoration: const InputDecoration(
                  labelText: '单位',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'kg', child: Text('kg')),
                  DropdownMenuItem(value: '斤', child: Text('斤')),
                ],
                onChanged: (v) => setState(() => _weightUnit = v!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomForm() {
    return Column(
      children: [
        TextField(
          controller: _customNameController,
          decoration: const InputDecoration(
            labelText: '记录名称',
            hintText: '如: 血糖、体温、步数',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _customValueController,
                decoration: const InputDecoration(
                  labelText: '数值',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _customUnitController,
                decoration: const InputDecoration(
                  labelText: '单位',
                  hintText: '如: mmol/L',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _save() async {
    final db = ref.read(databaseServiceProvider);
    final notes = _notesController.text;
    final existing = widget.existingRecord;

    switch (widget.category) {
      case RecordCategory.sleep:
        final now = DateTime.now();
        final bedtime = DateTime(now.year, now.month, now.day,
            _bedtime.hour, _bedtime.minute);
        var wakeTime = DateTime(now.year, now.month, now.day,
            _wakeTime.hour, _wakeTime.minute);
        if (wakeTime.isBefore(bedtime)) {
          wakeTime = wakeTime.add(const Duration(days: 1));
        }
        if (existing == null) {
          await db.insertSleepRecord(SleepRecord(
            dailyRecordId: widget.dailyRecordId,
            bedtime: bedtime,
            wakeTime: wakeTime,
            qualityRating: _sleepQuality,
            notes: notes,
          ));
        } else {
          final r = existing as SleepRecord;
          final b = DateTime(r.bedtime.year, r.bedtime.month, r.bedtime.day,
              _bedtime.hour, _bedtime.minute);
          var w = DateTime(r.wakeTime.year, r.wakeTime.month, r.wakeTime.day,
              _wakeTime.hour, _wakeTime.minute);
          if (w.isBefore(b)) {
            w = w.add(const Duration(days: 1));
          }
          await db.updateSleepRecord(SleepRecord(
            id: r.id,
            dailyRecordId: r.dailyRecordId,
            timestamp: r.timestamp,
            bedtime: b,
            wakeTime: w,
            qualityRating: _sleepQuality,
            notes: notes,
          ));
        }

      case RecordCategory.meals:
        final totalCalories =
            _foodItems.fold<int>(0, (sum, item) => sum + item.calories);
        final contentJson = _foodItems.isEmpty
            ? ''
            : jsonEncode(_foodItems.map((e) => e.toJson()).toList());
        if (existing == null) {
          await db.insertMealRecord(MealRecord(
            dailyRecordId: widget.dailyRecordId,
            mealType: _mealType,
            content: contentJson,
            calories: totalCalories,
            notes: notes,
          ));
        } else {
          final r = existing as MealRecord;
          await db.updateMealRecord(MealRecord(
            id: r.id,
            dailyRecordId: r.dailyRecordId,
            timestamp: r.timestamp,
            mealType: _mealType,
            content: contentJson,
            calories: totalCalories,
            notes: notes,
          ));
        }

      case RecordCategory.exercise:
        if (existing == null) {
          await db.insertExerciseRecord(ExerciseRecord(
            dailyRecordId: widget.dailyRecordId,
            activityType: _activityController.text,
            durationMinutes: _durationMinutes,
            intensity: _intensity,
            notes: notes,
          ));
        } else {
          final r = existing as ExerciseRecord;
          await db.updateExerciseRecord(ExerciseRecord(
            id: r.id,
            dailyRecordId: r.dailyRecordId,
            timestamp: r.timestamp,
            activityType: _activityController.text,
            durationMinutes: _durationMinutes,
            intensity: _intensity,
            caloriesBurned: r.caloriesBurned,
            notes: notes,
          ));
        }

      case RecordCategory.mood:
        if (existing == null) {
          await db.insertMoodRecord(MoodRecord(
            dailyRecordId: widget.dailyRecordId,
            moodLevel: _moodLevel,
            emotions: _selectedEmotions.toList(),
            notes: notes,
          ));
        } else {
          final r = existing as MoodRecord;
          await db.updateMoodRecord(MoodRecord(
            id: r.id,
            dailyRecordId: r.dailyRecordId,
            timestamp: r.timestamp,
            moodLevel: _moodLevel,
            emotions: _selectedEmotions.toList(),
            notes: notes,
          ));
        }

      case RecordCategory.waterIntake:
        if (existing == null) {
          await db.insertWaterIntakeRecord(WaterIntakeRecord(
            dailyRecordId: widget.dailyRecordId,
            amountML: _waterAmount,
            notes: notes,
          ));
        } else {
          final r = existing as WaterIntakeRecord;
          await db.updateWaterIntakeRecord(WaterIntakeRecord(
            id: r.id,
            dailyRecordId: r.dailyRecordId,
            timestamp: r.timestamp,
            amountML: _waterAmount,
            notes: notes,
          ));
        }

      case RecordCategory.medication:
        if (existing == null) {
          await db.insertMedicationRecord(MedicationRecord(
            dailyRecordId: widget.dailyRecordId,
            medicationName: _medNameController.text,
            dosage: _dosageController.text,
            taken: _taken,
            notes: notes,
          ));
        } else {
          final r = existing as MedicationRecord;
          await db.updateMedicationRecord(MedicationRecord(
            id: r.id,
            dailyRecordId: r.dailyRecordId,
            timestamp: r.timestamp,
            medicationName: _medNameController.text,
            dosage: _dosageController.text,
            taken: _taken,
            notes: notes,
          ));
        }

      case RecordCategory.notes:
        if (existing == null) {
          await db.insertNoteRecord(NoteRecord(
            dailyRecordId: widget.dailyRecordId,
            title: _noteTitleController.text,
            content: _noteContentController.text,
          ));
        } else {
          final r = existing as NoteRecord;
          await db.updateNoteRecord(NoteRecord(
            id: r.id,
            dailyRecordId: r.dailyRecordId,
            timestamp: r.timestamp,
            title: _noteTitleController.text,
            content: _noteContentController.text,
            tags: r.tags,
          ));
        }

      case RecordCategory.bloodPressure:
        if (existing == null) {
          await db.insertBloodPressureRecord(BloodPressureRecord(
            dailyRecordId: widget.dailyRecordId,
            systolic: _bpSystolic,
            diastolic: _bpDiastolic,
            heartRate: _bpHeartRate,
            notes: notes,
          ));
        } else {
          final r = existing as BloodPressureRecord;
          await db.updateBloodPressureRecord(BloodPressureRecord(
            id: r.id,
            dailyRecordId: r.dailyRecordId,
            timestamp: r.timestamp,
            systolic: _bpSystolic,
            diastolic: _bpDiastolic,
            heartRate: _bpHeartRate,
            notes: notes,
          ));
        }

      case RecordCategory.weight:
        if (existing == null) {
          await db.insertWeightRecord(WeightRecord(
            dailyRecordId: widget.dailyRecordId,
            weight: _weight,
            unit: _weightUnit,
            notes: notes,
          ));
        } else {
          final r = existing as WeightRecord;
          await db.updateWeightRecord(WeightRecord(
            id: r.id,
            dailyRecordId: r.dailyRecordId,
            timestamp: r.timestamp,
            weight: _weight,
            unit: _weightUnit,
            notes: notes,
          ));
        }

      case RecordCategory.custom:
        if (existing == null) {
          await db.insertCustomRecord(CustomRecord(
            dailyRecordId: widget.dailyRecordId,
            name: _customNameController.text,
            value: _customValueController.text,
            unit: _customUnitController.text,
            notes: notes,
          ));
        } else {
          final r = existing as CustomRecord;
          await db.updateCustomRecord(CustomRecord(
            id: r.id,
            dailyRecordId: r.dailyRecordId,
            timestamp: r.timestamp,
            name: _customNameController.text,
            value: _customValueController.text,
            unit: _customUnitController.text,
            notes: notes,
          ));
        }
    }

    widget.onSaved?.call();
    if (mounted) Navigator.pop(context);
  }
}
