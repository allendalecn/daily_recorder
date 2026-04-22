import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class SettingsState {
  final int waterGoalML;

  const SettingsState({
    this.waterGoalML = AppConstants.defaultWaterGoalML,
  });

  SettingsState copyWith({int? waterGoalML}) {
    return SettingsState(
      waterGoalML: waterGoalML ?? this.waterGoalML,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  static const _keyWaterGoal = 'water_goal_ml';

  SettingsNotifier() : super(const SettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final waterGoal = prefs.getInt(_keyWaterGoal);
    if (waterGoal != null) {
      state = state.copyWith(waterGoalML: waterGoal);
    }
  }

  Future<void> setWaterGoal(int ml) async {
    state = state.copyWith(waterGoalML: ml);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyWaterGoal, ml);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
