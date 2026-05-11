import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:solo_levelling_app/features/player/player.dart';
import 'package:solo_levelling_app/core/models/api_response.dart';

/// PlayerService
/// 
/// System service for managing player state via Supabase.
class PlayerService {
  final _supabase = Supabase.instance.client;

  /// Fetch player profile from Supabase
  Future<ApiResponse<Player>> getPlayerProfile(String userId) async {
    try {
      final response = await _supabase
          .from('players')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return ApiResponse.error('PLAYER_NOT_FOUND');
      }

      final player = Player.fromJson(response);
      return ApiResponse.success(player);

    } catch (e) {
      debugPrint('System Error fetching player profile: $e');
      return ApiResponse.error('Failed to synchronize with the System: ${e.toString()}');
    }
  }

  /// Initialize a new player record for a user
  Future<ApiResponse<Player>> initializePlayer(String userId) async {
    try {
      final response = await _supabase
          .from('players')
          .insert({
            'user_id': userId,
            'level': 1,
            'rank': 'E',
            'current_exp': 0,
            'max_exp': 100,
            'current_hp': 100,
            'max_hp': 100,
            'strength': 10,
            'agility': 10,
            'vitality': 10,
            'intelligence': 10,
            'sense': 10,
          })
          .select()
          .single();

      final player = Player.fromJson(response);
      
      // Also ensure a default schedule exists
      await _supabase.from('workout_schedules').upsert({
        'player_id': player.id,
        'days_of_week': [1, 3, 5],
        'is_configured': false,
      });

      return ApiResponse.success(player);
    } catch (e) {
      debugPrint('Error initializing player: $e');
      return ApiResponse.error('System initialization failure: ${e.toString()}');
    }
  }

  /// Add XP to player via Supabase RPC (Server-side level up logic)
  Future<ApiResponse<Player>> addExperience(String playerId, int amount) async {
    try {
      if (amount <= 0) {
        return ApiResponse.error('Invalid essence amount');
      }

      // Call the PL/pgSQL function we defined in the schema
      final response = await _supabase.rpc(
        'add_player_xp',
        params: {
          'p_id': playerId,
          'xp_amount': amount,
        },
      );

      // RPC returns a list of rows, we want the first one
      if (response is List && response.isNotEmpty) {
        final player = Player.fromJson(response.first);
        return ApiResponse.success(player);
      } else if (response is Map<String, dynamic>) {
        final player = Player.fromJson(response);
        return ApiResponse.success(player);
      }

      return ApiResponse.error('System failed to process experience.');

    } catch (e) {
      debugPrint('XP Synchronization Error: $e');
      return ApiResponse.error('Connection to the System lost.');
    }
  }

  /// Apply failure penalty to player in Supabase
  Future<ApiResponse<Player>> applyPenalty(Player currentPlayer) async {
    try {
      final hpLoss = (currentPlayer.maxHp * 0.3).round();
      final xpLoss = (currentPlayer.currentExp * 0.2).round();

      final newHp = (currentPlayer.currentHp - hpLoss).clamp(0, currentPlayer.maxHp);
      final newXp = (currentPlayer.currentExp - xpLoss).clamp(0, currentPlayer.maxExp);

      final response = await _supabase
          .from('players')
          .update({
            'current_hp': newHp,
            'current_exp': newXp,
            'trial_status': 'penalty',
            'last_penalty_check': DateTime.now().toIso8601String(),
          })
          .eq('id', currentPlayer.id)
          .select()
          .single();

      final updatedPlayer = Player.fromJson(response);
      return ApiResponse.success(updatedPlayer);
    } catch (e) {
      debugPrint('Penalty Application Error: $e');
      return ApiResponse.error('System error applying penalty');
    }
  }
}

