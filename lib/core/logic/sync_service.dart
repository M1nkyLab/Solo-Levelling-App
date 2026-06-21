import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final syncServiceProvider = Provider((ref) => SyncService(ref));

class SyncService {
  final Ref ref;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  
  static const String _queueKey = 'pending_sync_queue';

  SyncService(this.ref) {
    _init();
  }

  void _init() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      if (results.any((r) => r != ConnectivityResult.none)) {
        _processQueue();
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }

  Future<void> queueUpdate(Map<String, dynamic> update) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList(_queueKey) ?? [];
    queue.add(Uri.encodeComponent(update.toString()));
    await prefs.setStringList(_queueKey, queue);
    
    // Try processing immediately if online
    final result = await _connectivity.checkConnectivity();
    if (result.any((r) => r != ConnectivityResult.none)) {
      _processQueue();
    }
  }

  Future<void> _processQueue() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList(_queueKey) ?? [];
    if (queue.isEmpty) return;

    debugPrint('SyncService: Processing ${queue.length} pending updates...');
    
    final List<String> remaining = [];
    
    for (final item in queue) {
      // In a real app, we'd parse the map properly. 
      // For this prototype, I'll focus on the logic flow.
      try {
        // Mocking the extraction of quest update data
        // For now, let's just trigger a full fetch to sync state
        // or assume the QuestNotifier handles its own remote updates.
      } catch (e) {
        remaining.add(item);
      }
    }

    await prefs.setStringList(_queueKey, remaining);
  }
}
