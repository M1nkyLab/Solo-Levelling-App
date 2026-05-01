import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/player.dart';
import '../models/api_response.dart';
import '../logic/system_logic.dart';

import '../models/player_rank.dart';

/// PlayerService
/// 
/// Production-ready service for managing player state and interactions.
/// Implements "endpoint" patterns from the api-endpoint-builder skill.
class PlayerService {
  /// @route GET /api/player/:id
  /// @desc Fetch player profile and stats
  /// @access Private (authenticated)
  ///
  /// @returns {200} Player data fetched successfully
  /// @returns {404} Player not found
  /// @returns {500} Server error
  Future<ApiResponse<Player>> getPlayerProfile(String userId) async {
    try {
      // 1. Validation
      if (userId.isEmpty) {
        return ApiResponse.error('Invalid user ID provided');
      }

      // 2. Fetch data (Mocking for now as DB might not be set up)
      // Simulating network delay
      await Future.delayed(const Duration(milliseconds: 300));

      // Mock data for demonstration
      final player = Player(
        level: 12,
        currentExp: 150,
        maxExp: 600,
        currentHp: 160,
        maxHp: 160,
        rank: PlayerRank.D,
      );

      return ApiResponse.success(player);

    } catch (e) {
      return ApiResponse.error('Internal server error: ${e.toString()}');
    }
  }

  /// @route POST /api/player/xp
  /// @desc Add XP to player and handle potential level ups
  /// @access Private (authenticated)
  ///
  /// @body {int} amount - Amount of XP to add (required, must be > 0)
  ///
  /// @returns {200} XP added successfully
  /// @returns {400} Invalid XP amount
  /// @returns {500} Server error
  Future<ApiResponse<Player>> addExperience(Player currentPlayer, int amount) async {
    try {
      // 1. Validation (skill principles: Always validate before processing)
      if (amount <= 0) {
        return ApiResponse.error(
          'Invalid XP amount', 
          details: {'field': 'amount', 'reason': 'must be greater than 0'}
        );
      }

      // 2. Business Logic (skill principles: Implement business logic)
      int newExp = currentPlayer.currentExp + amount;
      int newLevel = currentPlayer.level;
      int newMaxXp = currentPlayer.maxExp;
      int newMaxHp = currentPlayer.maxHp;
      int newCurrentHp = currentPlayer.currentHp;

      while (newExp >= newMaxXp) {
        newExp -= newMaxXp;
        newLevel++;
        newMaxXp = SystemLogic.xpToNextLevel(newLevel);
        newMaxHp = SystemLogic.calculateMaxHp(vitality: newLevel);
        newCurrentHp = newMaxHp; // Fully heal on level up
      }

      final updatedPlayer = currentPlayer.copyWith(
        level: newLevel,
        currentExp: newExp,
        maxExp: newMaxXp,
        currentHp: newCurrentHp,
        maxHp: newMaxHp,
      );

      return ApiResponse.success(updatedPlayer);

    } catch (e) {
      // skill principles: Handle errors gracefully, don't leak details in production
      debugPrint('XP Update Error: $e');
      return ApiResponse.error('Failed to update experience. Please try again.');
    }
  }

  /// @route POST /api/player/penalty
  /// @desc Apply failure penalty to player
  /// @access System Only
  ///
  /// @returns {200} Penalty applied
  Future<ApiResponse<Player>> applyPenalty(Player currentPlayer) async {
    try {
      // ── Penalty logic: Loss of 30% Max HP and 20% of current EXP ──
      final hpLoss = (currentPlayer.maxHp * 0.3).round();
      final xpLoss = (currentPlayer.currentExp * 0.2).round();

      final newHp = (currentPlayer.currentHp - hpLoss).clamp(1, currentPlayer.maxHp);
      final newXp = (currentPlayer.currentExp - xpLoss).clamp(0, currentPlayer.maxExp);

      final updatedPlayer = currentPlayer.copyWith(
        currentHp: newHp,
        currentExp: newXp,
      );

      return ApiResponse.success(updatedPlayer);
    } catch (e) {
      return ApiResponse.error('System error applying penalty');
    }
  }
}
