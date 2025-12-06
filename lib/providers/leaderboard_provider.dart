import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/leaderboard_entry_model.dart';
import '../models/badge_model.dart';
import '../models/user_badge_model.dart';
import '../services/leaderboard_service.dart';
import '../services/analytics_service.dart';

class LeaderboardProvider with ChangeNotifier {
  final LeaderboardService _leaderboardService = LeaderboardService();
  final AnalyticsService _analyticsService = AnalyticsService();
  
  List<LeaderboardEntryModel> _leaderboard = [];
  List<BadgeModel> _badges = [];
  List<UserBadgeModel> _userBadges = [];
  double _progressScore = 0.0;
  bool _isLoading = false;
  StreamSubscription? _leaderboardSubscription;

  List<LeaderboardEntryModel> get leaderboard => _leaderboard;
  List<BadgeModel> get badges => _badges;
  List<UserBadgeModel> get userBadges => _userBadges;
  double get progressScore => _progressScore;
  bool get isLoading => _isLoading;

  /// Load leaderboard
  Future<void> loadLeaderboard(String coachId, LeaderboardMetric metric) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _leaderboardService.getLeaderboard(coachId, metric);
      if (result.isSuccess) {
        _leaderboard = result.dataOrNull ?? [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Subscribe to leaderboard (real-time)
  void subscribeToLeaderboard(String coachId, LeaderboardMetric metric) {
    _leaderboardSubscription?.cancel();
    _leaderboardSubscription = _leaderboardService.streamLeaderboard(coachId, metric).listen((entries) {
      _leaderboard = entries;
      notifyListeners();
    });
  }

  /// Update progress score
  Future<void> updateProgressScore(String clientId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _leaderboardService.updateProgressScore(clientId);
      if (result.isSuccess) {
        // Reload progress score
        final scoreResult = await _analyticsService.calculateProgressScore(clientId);
        if (scoreResult.isSuccess) {
          _progressScore = scoreResult.dataOrNull ?? 0.0;
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load badges
  Future<void> loadBadges() async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _leaderboardService.getBadges();
      if (result.isSuccess) {
        _badges = result.dataOrNull ?? [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load user badges
  Future<void> loadUserBadges(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _leaderboardService.getUserBadges(userId);
      if (result.isSuccess) {
        _userBadges = result.dataOrNull ?? [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check badge eligibility
  Future<void> checkBadges(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _leaderboardService.checkBadgeEligibility(userId);
      if (result.isSuccess && result.dataOrNull!.isNotEmpty) {
        // New badges earned, reload user badges
        await loadUserBadges(userId);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _leaderboardSubscription?.cancel();
    super.dispose();
  }
}




