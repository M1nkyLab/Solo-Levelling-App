import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleState {
  final List<int> days;
  final bool isConfigured;

  ScheduleState({
    required this.days,
    this.isConfigured = false,
  });

  ScheduleState copyWith({
    List<int>? days,
    bool? isConfigured,
  }) {
    return ScheduleState(
      days: days ?? this.days,
      isConfigured: isConfigured ?? this.isConfigured,
    );
  }
}

class ScheduleNotifier extends StateNotifier<ScheduleState> {
  ScheduleNotifier() : super(ScheduleState(days: [1, 3, 5])) {
    _loadState();
  }

  static const String _scheduleKey = 'workout_schedule';
  static const String _configuredKey = 'is_schedule_configured';

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final schedule = prefs.getStringList(_scheduleKey);
      final isConfigured = prefs.getBool(_configuredKey) ?? false;
      
      if (schedule != null) {
        state = state.copyWith(
          days: schedule.map((s) => int.parse(s)).toList()..sort(),
          isConfigured: isConfigured,
        );
      } else {
        state = state.copyWith(isConfigured: isConfigured);
      }
    } catch (e) {
      // Handle or log error
    }
  }

  void toggleDay(int day) {
    List<int> newDays;
    if (state.days.contains(day)) {
      newDays = state.days.where((d) => d != day).toList();
    } else {
      newDays = [...state.days, day]..sort();
    }
    
    state = state.copyWith(days: newDays);
    _saveState();
  }

  Future<void> confirmSchedule() async {
    state = state.copyWith(isConfigured: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_configuredKey, true);
    _saveState();
  }

  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _scheduleKey, 
        state.days.map((d) => d.toString()).toList(),
      );
    } catch (e) {
      // Handle save error
    }
  }
}

final scheduleProvider = StateNotifierProvider<ScheduleNotifier, ScheduleState>((ref) {
  return ScheduleNotifier();
});
