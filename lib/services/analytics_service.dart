import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/body_metrics_model.dart';
import '../models/workout_log_model.dart';
import '../models/personal_record_model.dart';
import '../exceptions/app_exceptions.dart';
import '../utils/result.dart';
import 'firestore_service.dart';
import 'workout_service.dart';
import 'metrics_service.dart';

class AnalyticsService {
  final FirestoreService _firestoreService = FirestoreService();
  final WorkoutService _workoutService = WorkoutService();
  final MetricsService _metricsService = MetricsService();

  /// Get body analytics (weight, BMI, body fat over time)
  Future<Result<List<BodyMetricsModel>>> getBodyAnalytics(
    String clientId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await _metricsService.getMetricsHistory(clientId);
      if (result.isFailure) {
        return Failure(result.errorMessage!);
      }

      var metrics = result.dataOrNull ?? [];
      
      if (startDate != null) {
        metrics = metrics.where((m) => 
          m.date.isAfter(startDate.subtract(const Duration(days: 1))) || 
          m.date.isAtSameMomentAs(startDate)
        ).toList();
      }
      if (endDate != null) {
        metrics = metrics.where((m) => 
          m.date.isBefore(endDate.add(const Duration(days: 1))) || 
          m.date.isAtSameMomentAs(endDate)
        ).toList();
      }

      return Success(metrics);
    } catch (e) {
      return Failure('Failed to get body analytics: $e');
    }
  }

  /// Get exercise analytics for a specific exercise
  Future<Result<List<Map<String, dynamic>>>> getExerciseAnalytics(
    String clientId,
    String exerciseName,
  ) async {
    try {
      final result = await _workoutService.getWorkoutHistory(clientId);
      if (result.isFailure) {
        return Failure(result.errorMessage!);
      }

      final logs = result.dataOrNull ?? [];
      final exerciseData = <Map<String, dynamic>>[];

      for (final log in logs) {
        for (final exercise in log.exercises) {
          if (exercise.exerciseName.toLowerCase() == exerciseName.toLowerCase()) {
            // Calculate max weight, total volume, estimated 1RM
            double? maxWeight;
            double totalVolume = 0;
            
            for (final set in exercise.sets) {
              if (set.weight != null && set.reps != null) {
                if (maxWeight == null || set.weight! > maxWeight) {
                  maxWeight = set.weight;
                }
                totalVolume += set.weight! * set.reps!;
              }
            }

            // Estimate 1RM using Epley formula: 1RM = weight × (1 + reps/30)
            double? estimated1RM;
            if (maxWeight != null) {
              final bestSet = exercise.sets
                  .where((s) => s.weight != null && s.reps != null)
                  .reduce((a, b) => (a.weight ?? 0) > (b.weight ?? 0) ? a : b);
              if (bestSet.weight != null && bestSet.reps != null) {
                estimated1RM = bestSet.weight! * (1 + bestSet.reps! / 30);
              }
            }

            exerciseData.add({
              'date': log.date,
              'maxWeight': maxWeight,
              'totalVolume': totalVolume,
              'estimated1RM': estimated1RM,
            });
          }
        }
      }

      return Success(exerciseData);
    } catch (e) {
      return Failure('Failed to get exercise analytics: $e');
    }
  }

  /// Get compliance data for coach dashboard
  Future<Result<Map<String, dynamic>>> getComplianceData(String coachId) async {
    try {
      // Get all clients
      final clientsData = await _firestoreService.queryCollection(
        'clients',
        whereField: 'coachId',
        whereValue: coachId,
      );

      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      int totalClients = clientsData.length;
      int clientsWithWorkout = 0;
      int clientsWithDiet = 0;

      for (final clientData in clientsData) {
        final clientId = clientData['id'] as String;

        // Check workout compliance
        final workoutLogs = await _firestoreService.queryCollection(
          'workout_logs',
          whereField: 'clientId',
          whereValue: clientId,
        );
        final hasWorkoutYesterday = workoutLogs.any((log) {
          final dateValue = log['date'];
          final logDate = dateValue is String 
              ? DateTime.parse(dateValue)
              : (dateValue as Timestamp).toDate();
          return logDate.year == yesterday.year &&
              logDate.month == yesterday.month &&
              logDate.day == yesterday.day;
        });
        if (hasWorkoutYesterday) clientsWithWorkout++;

        // Check diet compliance
        final foodLogs = await _firestoreService.queryCollection(
          'food_logs',
          whereField: 'clientId',
          whereValue: clientId,
        );
        final hasDietYesterday = foodLogs.any((log) {
          final dateValue = log['date'];
          final logDate = dateValue is String 
              ? DateTime.parse(dateValue)
              : (dateValue as Timestamp).toDate();
          return logDate.year == yesterday.year &&
              logDate.month == yesterday.month &&
              logDate.day == yesterday.day;
        });
        if (hasDietYesterday) clientsWithDiet++;
      }

      final workoutCompliance = totalClients > 0 ? (clientsWithWorkout / totalClients * 100) : 0.0;
      final dietCompliance = totalClients > 0 ? (clientsWithDiet / totalClients * 100) : 0.0;

      return Success({
        'totalClients': totalClients,
        'workoutCompliance': workoutCompliance,
        'dietCompliance': dietCompliance,
      });
    } catch (e) {
      return Failure('Failed to get compliance data: $e');
    }
  }

  /// Calculate progress score (0-100) based on compliance
  Future<Result<double>> calculateProgressScore(String clientId) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      // Get workout logs
      final workoutLogs = await _firestoreService.queryCollection(
        'workout_logs',
        whereField: 'clientId',
        whereValue: clientId,
      );
      
      // Get assigned workouts
      final assignedWorkouts = await _firestoreService.queryCollection(
        'assigned_workouts',
        whereField: 'clientId',
        whereValue: clientId,
      );

      // Calculate workout completion rate
      final recentWorkouts = assignedWorkouts.where((w) {
        final startDate = DateTime.parse(w['startDate']);
        return startDate.isAfter(thirtyDaysAgo);
      }).length;

      final completedWorkouts = workoutLogs.where((log) {
        final logDate = DateTime.parse(log['date']);
        return logDate.isAfter(thirtyDaysAgo) && log['completed'] == true;
      }).length;

      final workoutScore = recentWorkouts > 0 ? (completedWorkouts / recentWorkouts * 50) : 0.0;

      // Calculate diet adherence (simplified)
      final foodLogs = await _firestoreService.queryCollection(
        'food_logs',
        whereField: 'clientId',
        whereValue: clientId,
      );
      
      final recentDietLogs = foodLogs.where((log) {
        final logDate = DateTime.parse(log['date']);
        return logDate.isAfter(thirtyDaysAgo);
      }).length;

      final dietScore = (recentDietLogs / 30 * 50).clamp(0.0, 50.0);

      final totalScore = (workoutScore + dietScore).clamp(0.0, 100.0);
      return Success(totalScore);
    } catch (e) {
      return Failure('Failed to calculate progress score: $e');
    }
  }

  /// Get personal records
  Future<Result<List<PersonalRecordModel>>> getPersonalRecords(String clientId) async {
    try {
      final dataList = await _firestoreService.queryCollection(
        'personal_records',
        whereField: 'clientId',
        whereValue: clientId,
        orderBy: 'date',
        descending: true,
      );
      final records = dataList.map((data) => PersonalRecordModel.fromJson(data)).toList();
      return Success(records);
    } catch (e) {
      return Failure('Failed to get personal records: $e');
    }
  }
}

