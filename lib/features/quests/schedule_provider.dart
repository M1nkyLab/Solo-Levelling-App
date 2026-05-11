import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  final _supabase = Supabase.instance.client;
  static const String _scheduleKeyPrefix = 'workout_schedule_';
  static const String _configuredKeyPrefix = 'is_schedule_configured_';
  String? _currentUserId;

  Future<void> loadForUser(String userId) async {
    _currentUserId = userId;
    
    // 1. Try local cache first
    await _loadFromLocal(userId);

    // 2. Fetch from Supabase to sync
    await _fetchFromSupabase(userId);
  }

  Future<void> _loadFromLocal(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final schedule = prefs.getStringList('$_scheduleKeyPrefix$userId');
      final isConfigured = prefs.getBool('$_configuredKeyPrefix$userId') ?? false;
      
      if (schedule != null) {
        state = state.copyWith(
          days: schedule.map((s) => int.parse(s)).toList()..sort(),
          isConfigured: isConfigured,
        );
      }
    } catch (e) {
      debugPrint('Error loading schedule from local: $e');
    }
  }

  Future<void> _fetchFromSupabase(String userId) async {
    try {
      // Get player_id first
      final playerRes = await _supabase
          .from('players')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();
      
      if (playerRes == null) return;
      final playerId = playerRes['id'];

      final response = await _supabase
          .from('workout_schedules')
          .select()
          .eq('player_id', playerId)
          .maybeSingle();

      if (response != null) {
        final List<dynamic> daysRaw = response['days_of_week'];
        final List<int> days = daysRaw.map((d) => d as int).toList()..sort();
        final bool isConfigured = response['is_configured'];

        state = state.copyWith(days: days, isConfigured: isConfigured);
        
        // Update local cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('$_scheduleKeyPrefix$userId', days.map((d) => d.toString()).toList());
        await prefs.setBool('$_configuredKeyPrefix$userId', isConfigured);
      }
    } catch (e) {
      debugPrint('Error fetching schedule from Supabase: $e');
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
    // Note: We don't sync on every toggle to avoid noise, 
    // we sync when confirmSchedule is called or when the user navigates away.
  }

  Future<void> confirmSchedule() async {
    if (_currentUserId == null) return;

    try {
      // 1. Get the player ID first
      final playerRes = await _supabase
          .from('players')
          .select('id')
          .eq('user_id', _currentUserId!)
          .maybeSingle();
      
      if (playerRes == null) return;
      final playerId = playerRes['id'];

      // 2. Update the schedule in the database
      await _supabase
          .from('workout_schedules')
          .upsert({
            'player_id': playerId,
            'days_of_week': state.days,
            'is_configured': true,
            'updated_at': DateTime.now().toIso8601String(),
          });

      // 3. Update local state and cache
      state = state.copyWith(isConfigured: true);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$_configuredKeyPrefix$_currentUserId', true);
      await prefs.setStringList(
        '$_scheduleKeyPrefix$_currentUserId', 
        state.days.map((d) => d.toString()).toList(),
      );
      
    } catch (e) {
      debugPrint('Error saving schedule: $e');
    }
  }
}

final scheduleProvider = StateNotifierProvider<ScheduleNotifier, ScheduleState>((ref) {
  return ScheduleNotifier();
});
