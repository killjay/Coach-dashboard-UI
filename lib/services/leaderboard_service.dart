import '../models/leaderboard_entry_model.dart';
import '../models/badge_model.dart';
import '../models/user_badge_model.dart';
import '../exceptions/app_exceptions.dart';
import '../utils/result.dart';
import 'firestore_service.dart';
import 'analytics_service.dart';

class LeaderboardService {
  final FirestoreService _firestoreService = FirestoreService();
  final AnalyticsService _analyticsService = AnalyticsService();

  /// Get leaderboard for a coach's clients
  Future<Result<List<LeaderboardEntryModel>>> getLeaderboard(
    String coachId,
    LeaderboardMetric metric,
  ) async {
    try {
      // Get all clients for this coach
      final clientsData = await _firestoreService.queryCollection(
        'clients',
        whereField: 'coachId',
        whereValue: coachId,
      );

      final entries = <LeaderboardEntryModel>[];

      for (final clientData in clientsData) {
        final clientId = clientData['id'] as String;
        final name = clientData['name'] as String;
        final isAnonymous = clientData['isAnonymous'] ?? false;

        double score = 0.0;

        switch (metric) {
          case LeaderboardMetric.dailySteps:
            // Get today's steps (would need step tracking integration)
            score = 0.0; // Placeholder
            break;
          case LeaderboardMetric.monthlySteps:
            // Get monthly steps
            score = 0.0; // Placeholder
            break;
          case LeaderboardMetric.workoutConsistency:
            // Calculate workout consistency
            final workoutLogs = await _firestoreService.queryCollection(
              'workout_logs',
              whereField: 'clientId',
              whereValue: clientId,
            );
            final completedWorkouts = workoutLogs.where((log) => log['completed'] == true).length;
            final totalWorkouts = workoutLogs.length;
            score = totalWorkouts > 0 ? (completedWorkouts / totalWorkouts * 100) : 0.0;
            break;
          case LeaderboardMetric.progressScore:
            final result = await _analyticsService.calculateProgressScore(clientId);
            score = result.dataOrNull ?? 0.0;
            break;
        }

        entries.add(LeaderboardEntryModel(
          clientId: clientId,
          name: isAnonymous ? 'Anonymous' : name,
          score: score,
          metric: metric,
          rank: 0, // Will be set after sorting
          date: DateTime.now(),
          isAnonymous: isAnonymous,
        ));
      }

      // Sort by score descending and assign ranks
      entries.sort((a, b) => b.score.compareTo(a.score));
      for (int i = 0; i < entries.length; i++) {
        entries[i] = LeaderboardEntryModel(
          clientId: entries[i].clientId,
          name: entries[i].name,
          score: entries[i].score,
          metric: entries[i].metric,
          rank: i + 1,
          date: entries[i].date,
          isAnonymous: entries[i].isAnonymous,
        );
      }

      return Success(entries);
    } catch (e) {
      return Failure('Failed to get leaderboard: $e');
    }
  }

  /// Stream leaderboard (real-time)
  Stream<List<LeaderboardEntryModel>> streamLeaderboard(
    String coachId,
    LeaderboardMetric metric,
  ) {
    // Poll every 30 seconds for updates
    // In production, you'd want a more efficient real-time solution
    return Stream.periodic(const Duration(seconds: 30), (_) {
      return getLeaderboard(coachId, metric);
    }).asyncMap((future) async {
      final result = await future;
      return result.isSuccess ? result.dataOrNull ?? [] : [];
    });
  }

  /// Update progress score for a client
  Future<Result<void>> updateProgressScore(String clientId) async {
    try {
      final result = await _analyticsService.calculateProgressScore(clientId);
      if (result.isFailure) {
        return Failure(result.errorMessage!);
      }

      final score = result.dataOrNull ?? 0.0;
      
      // Store progress score (could be in a separate collection or in client doc)
      await _firestoreService.updateDocument(
        'clients/$clientId',
        {'progressScore': score, 'progressScoreUpdatedAt': DateTime.now().toIso8601String()},
      );

      return const Success(null);
    } catch (e) {
      return Failure('Failed to update progress score: $e');
    }
  }

  /// Get badges
  Future<Result<List<BadgeModel>>> getBadges() async {
    try {
      final dataList = await _firestoreService.getCollection('badges');
      final badges = dataList.map((data) => BadgeModel.fromJson(data)).toList();
      return Success(badges);
    } catch (e) {
      return Failure('Failed to get badges: $e');
    }
  }

  /// Get user's badges
  Future<Result<List<UserBadgeModel>>> getUserBadges(String userId) async {
    try {
      final dataList = await _firestoreService.queryCollection(
        'user_badges',
        whereField: 'userId',
        whereValue: userId,
        orderBy: 'earnedDate',
        descending: true,
      );
      final badges = dataList.map((data) => UserBadgeModel.fromJson(data)).toList();
      return Success(badges);
    } catch (e) {
      return Failure('Failed to get user badges: $e');
    }
  }

  /// Check badge eligibility and award if eligible
  Future<Result<List<BadgeModel>>> checkBadgeEligibility(String userId) async {
    try {
      // Get all badges
      final badgesResult = await getBadges();
      if (badgesResult.isFailure) {
        return Failure(badgesResult.errorMessage!);
      }

      final badges = badgesResult.dataOrNull ?? [];
      final earnedBadges = <BadgeModel>[];

      // Check each badge criteria
      for (final badge in badges) {
        // Check if user already has this badge
        final userBadgesResult = await getUserBadges(userId);
        final userBadges = userBadgesResult.dataOrNull ?? [];
        if (userBadges.any((ub) => ub.badgeId == badge.id)) {
          continue; // Already earned
        }

        // Check criteria (simplified - would need actual logic based on criteria)
        bool eligible = false;
        // TODO: Implement actual criteria checking based on badge.criteria

        if (eligible) {
          // Award badge
          final userBadge = UserBadgeModel(
            id: _firestoreService.generateId('user_badges'),
            userId: userId,
            badgeId: badge.id,
            earnedDate: DateTime.now(),
          );
          await _firestoreService.setDocument(
            'user_badges/${userBadge.id}',
            userBadge.toJson(),
          );
          earnedBadges.add(badge);
        }
      }

      return Success(earnedBadges);
    } catch (e) {
      return Failure('Failed to check badge eligibility: $e');
    }
  }

  /// Award a badge to a user
  Future<Result<void>> awardBadge(String userId, String badgeId) async {
    try {
      final userBadge = UserBadgeModel(
        id: _firestoreService.generateId('user_badges'),
        userId: userId,
        badgeId: badgeId,
        earnedDate: DateTime.now(),
      );
      await _firestoreService.setDocument(
        'user_badges/${userBadge.id}',
        userBadge.toJson(),
      );
      return const Success(null);
    } catch (e) {
      return Failure('Failed to award badge: $e');
    }
  }
}




