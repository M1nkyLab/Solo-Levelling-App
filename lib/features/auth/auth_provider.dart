import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthState {
  final bool isAuthenticated;
  final User? user;
  final bool isLoading;
  final String? error;
  final bool needsScheduleSetup;

  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.error,
    this.needsScheduleSetup = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    bool? isLoading,
    String? error,
    bool? needsScheduleSetup,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      needsScheduleSetup: needsScheduleSetup ?? this.needsScheduleSetup,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _init();
  }

  final _supabase = Supabase.instance.client;

  void _init() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      state = state.copyWith(
        isAuthenticated: session != null,
        user: session?.user,
        isLoading: false,
        // We don't set needsScheduleSetup here because this triggers on app launch too
      );
    });
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null, needsScheduleSetup: false);
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      state = state.copyWith(
        isAuthenticated: response.session != null,
        user: response.user,
        needsScheduleSetup: true, 
        isLoading: false
      );
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred');
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String username) async {
    state = state.copyWith(isLoading: true, error: null, needsScheduleSetup: false);
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );
      state = state.copyWith(
        isAuthenticated: response.session != null,
        user: response.user,
        isLoading: false, 
        needsScheduleSetup: true
      );
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred');
      return false;
    }
  }

  void completeSetup() {
    state = state.copyWith(needsScheduleSetup: false);
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    state = AuthState();
  }

  Future<bool> updateUsername(String newUsername) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(data: {'username': newUsername}),
      );
      state = state.copyWith(user: response.user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to update profile');
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;
      
      // Try calling an RPC if available (requires setting up a delete_user RPC in Supabase)
      try {
        await _supabase.rpc('delete_user');
      } catch (_) {
        // Fallback: Delete the user data from 'players' if we can't delete auth user directly
        // The cascading deletes will remove their data, though auth record remains
        await _supabase.from('players').delete().eq('user_id', userId);
      }
      
      await logout();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to delete account');
      return false;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
