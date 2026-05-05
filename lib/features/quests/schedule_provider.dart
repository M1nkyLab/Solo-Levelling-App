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
  ScheduleNotifier() : super(ScheduleState(days: [1, 3, 5]));

  static const String _scheduleKeyPrefix = 'workout_schedule_';
  static const String _configuredKeyPrefix = 'is_schedule_configured_';
  String? _currentUserId;

  Future<void> loadForUser(String userId) async {
    _currentUserId = userId;
    try {
      final prefs = await SharedPreferences.getInstance();
      final schedule = prefs.getStringList('${_scheduleKeyPrefix}$userId');
      final isConfigured = prefs.getBool('${_configuredKeyPrefix}$userId') ?? false;
      
      if (schedule != null) {
        state = state.copyWith(
          days: schedule.map((s) => int.parse(s)).toList()..sort(),
          isConfigured: isConfigured,
        );
      } else {
        state = state.copyWith(days: [1, 3, 5], isConfigured: isConfigured);
      }
    } catch (e) {
      // Handle or log error
    }
  }

  void reset() {
    _currentUserId = null;
    state = ScheduleState(days: [1, 3, 5], isConfigured: false);
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
    if (_currentUserId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('${_configuredKeyPrefix}$_currentUserId', true);
      _saveState();
    }
  }

  Future<void> _saveState() async {
    if (_currentUserId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        '${_scheduleKeyPrefix}$_currentUserId', 
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
