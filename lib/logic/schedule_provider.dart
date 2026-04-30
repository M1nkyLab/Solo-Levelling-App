import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScheduleNotifier extends StateNotifier<List<int>> {
  ScheduleNotifier() : super([1, 3, 5]); // Default: Mon, Wed, Fri

  void toggleDay(int day) {
    if (state.contains(day)) {
      state = state.where((d) => d != day).toList();
    } else {
      state = [...state, day]..sort();
    }
    // TODO: In the future, sync with Supabase here
  }
}

final scheduleProvider = StateNotifierProvider<ScheduleNotifier, List<int>>((ref) {
  return ScheduleNotifier();
});
