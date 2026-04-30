import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScheduleNotifier extends StateNotifier<List<int>> {
  ScheduleNotifier() : super([1, 3, 5]) {
    // Initial fetch from Supabase if possible
    _fetchRemoteSchedule();
  }

  final _supabase = Supabase.instance.client;

  Future<void> _fetchRemoteSchedule() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase
          .from('users')
          .select('workout_days')
          .eq('id', user.id)
          .single();
      
      if (response['workout_days'] != null) {
        state = List<int>.from(response['workout_days']);
      }
    } catch (e) {
      // Handle or log error
    }
  }

  void toggleDay(int day) {
    if (state.contains(day)) {
      state = state.where((d) => d != day).toList();
    } else {
      state = [...state, day]..sort();
    }
    
    // Sync with Supabase
    _syncWithSupabase();
  }

  Future<void> _syncWithSupabase() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('users').upsert({
        'id': user.id,
        'workout_days': state,
      });
    } catch (e) {
      // Handle sync error (e.g., show a snackbar or retry logic)
    }
  }
}

final scheduleProvider = StateNotifierProvider<ScheduleNotifier, List<int>>((ref) {
  return ScheduleNotifier();
});
