import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState {
  final bool isAuthenticated;
  final String? username;
  final bool isLoading;

  AuthState({
    this.isAuthenticated = false,
    this.username,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? username,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      username: username ?? this.username,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _checkAuth();
  }

  static const String _authKey = 'is_authenticated';
  static const String _userKey = 'username';

  Future<void> _checkAuth() async {
    state = state.copyWith(isLoading: true);
    final prefs = await SharedPreferences.getInstance();
    final isAuthenticated = prefs.getBool(_authKey) ?? false;
    final username = prefs.getString(_userKey);
    
    state = state.copyWith(
      isAuthenticated: isAuthenticated,
      username: username,
      isLoading: false,
    );
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true);
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Temporary credentials
    if (username == 'JinWoo' && password == 'level_up') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_authKey, true);
      await prefs.setString(_userKey, username);

      state = state.copyWith(
        isAuthenticated: true,
        username: username,
        isLoading: false,
      );
      return true;
    }

    state = state.copyWith(isLoading: false);
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authKey);
    await prefs.remove(_userKey);
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
